function preprocLFP = preprocessEvokedLfp(dataDir, sessionName, periCueWindow, periArrWindow, ...
        isZeroDistractors, bBandpass)

%% set preprocessing options
doSpikeCleaning = 0;
doDetrend = 1;
doRemoveLineNoise = 1;
doRemoveCustomSpectralNoise = 1;
doRemoveOutliers = 1;
doSubtractCAR = 0;

%% setup environment
Fs = 1000;

% params used for removing line noise
params.Fs = Fs;
params.fpass = [5 200];
params.tapers = [3 5]; % 5 tapers used for removing line noise
params.pad = 0;

% load stim onset file, and ignore the 0D case
if ~isZeroDistractors
    stimOnsetFile = [dataDir filesep sessionName filesep 'StimuliOnset_5D.mat'];
else
    stimOnsetFile = [dataDir filesep sessionName filesep 'StimuliOnset_0D.mat'];
end
SO = load(stimOnsetFile);

% load the original lfps file
lfpFile = [dataDir filesep sessionName filesep 'lfps' filesep ...
        sessionName '_lfps.mat'];
if ~exist(lfpFile, 'file')
    fprintf('Missing original LFPs file: %s\n', lfpFile)
    return;
end
L = load(lfpFile);

%% remove events if using these lfps with spikes, for which these events 
% were also removed

if doSpikeCleaning
	CueP = cleanEventTimesLfp(sessionName, SO.CueP);
    ArrP = cleanEventTimesLfp(sessionName, SO.ArrP);
    ArrBarP = cleanEventTimesLfp(sessionName, SO.ArrBarP);
    ArrBowP = cleanEventTimesLfp(sessionName, SO.ArrBowP);
    ArrBarConP = cleanEventTimesLfp(sessionName, SO.ArrBarConP);
    ArrBowConP = cleanEventTimesLfp(sessionName, SO.ArrBowConP);
else
    CueP = SO.CueP;
    ArrP = SO.ArrP;
    ArrBarP = SO.ArrBarP;
    ArrBowP = SO.ArrBowP;
    ArrBarConP = SO.ArrBarConP;
    ArrBowConP = SO.ArrBowConP;
end

%% adjust all lfps
areaNames = {'PUL', 'TEO', 'LIP', 'V4'};
ADAdj = cell(numel(areaNames), 1);
for l = 1:numel(areaNames)
    areaName = areaNames{l};
    if strcmp(areaName, 'PUL')
        if ~isfield(L, 'AD01')
            continue;
        end
        AD = L.AD01;
        AD_ts = L.AD01_ts;
        AD_ind = L.AD01_ind;
    elseif strcmp(areaName, 'TEO')
        if ~isfield(L, 'AD02')
            continue;
        end
        AD = L.AD02;
        AD_ts = L.AD02_ts;
        AD_ind = L.AD02_ind;
    elseif strcmp(areaName, 'LIP')
        if ~isfield(L, 'AD03')
            continue;
        end
        AD = L.AD03;
        AD_ts = L.AD03_ts;
        AD_ind = L.AD03_ind;
    elseif strcmp(areaName, 'V4')
        if ~isfield(L, 'AD04')
            continue;
        end
        AD = L.AD04;
        AD_ts = L.AD04_ts;
        AD_ind = L.AD04_ind;
    else
        error('Unknown area name: %s', areaName);
    end
    
    % session x area exceptions - due to noise
    if strcmp(sessionName, 'L100927') && strcmp(areaName, 'PUL')
        fprintf('Skipping %s - %s due to high noise\n', sessionName, areaName);
        continue;
    end
    if strcmp(sessionName, 'L101124') && strcmp(areaName, 'PUL')
        fprintf('Skipping %s - %s due to high noise\n', sessionName, areaName);
        continue;
    end

    % adjust for LFP offsets
    ADAdj{l} = padNaNsToAdjustLfpOffset(AD, AD_ts, AD_ind, Fs);
end

if doSubtractCAR
    commonAvgRef = nansum(cell2mat(ADAdj'),2);
    ADAdj = cellfun(@(x) x - commonAvgRef, ADAdj, 'UniformOutput', 0);
end

if bBandpass > 0
    for l = 1:numel(areaNames)
        if ~isempty(ADAdj{l})
            filtTic = tic; % very slow
            nanInd = isnan(ADAdj{l}); 
            ix = 1:numel(ADAdj{l});
            % interpolate over nans
            ADAdj{l}(nanInd) = interp1(ix(~nanInd), ADAdj{l}(~nanInd), ix(nanInd));
            % zero out remaining nans at ends
            ADAdj{l}(isnan(ADAdj{l})) = 0;
            ADAdj{l} = filtfilt(bBandpass, 1, ADAdj{l});
            toc(filtTic)
        end
    end
end

%% find outlier trials separately for each area and each window
eventNames = {'AroundCue', 'AroundArr'};
numEvents = numel(eventNames);

numCueLocs = 6;

% 2 events for alignment
% align to cue for determining RF locations
% align to array for the main delay period analysis

preprocLFP.periCueWindow = periCueWindow;
preprocLFP.periArrWindow = periArrWindow;
preprocLFP.rawByLoc = cell(numCueLocs, 1);
preprocLFP.preCleanByLoc = cell(size(preprocLFP.rawByLoc));
outlierTrialsByAreaLoc = cell(size(preprocLFP.rawByLoc));
preprocLFP.areasWithData = zeros(numel(areaNames), 1);

for m = 1:numEvents
    if m == 1
        eventTimes = CueP;
        periEventWindow = periCueWindow;
    elseif m == 2
        eventTimes = ArrP;
        periEventWindow = periArrWindow;
    else
        error('Unknown event type: %d', m);
    end

    if isempty(eventTimes)
        error(' no data for this condition\n');
    end
    
    numPointsInWindow = round(sum(periEventWindow) * Fs);

    detrendWindow = [0.3 0.05]; % in sec, TODO may reduce oscillatory activity
    rmlinesWindow = [sum(periEventWindow) 0.05]; % in sec
        
    % for each cue location
    for k = 1:numCueLocs
        eventTimesAtLoc = eventTimes(:,k);
        eventTimesAtLoc(isnan(eventTimesAtLoc)) = [];

        preprocLFP.rawByLoc{k}.(eventNames{m}) = nan(numPointsInWindow, numel(eventTimesAtLoc), numel(areaNames));
        outlierTrialsByAreaLoc{k}.(eventNames{m}) = zeros(numel(eventTimesAtLoc), numel(areaNames));

        % if no trials at this cue location
        if isempty(eventTimesAtLoc)
            preprocLFP.preCleanByLoc{k}.(eventNames{m}) = preprocLFP.rawByLoc{k}.(eventNames{m});
            outlierTrialsByAreaLoc{k}.(eventNames{m})(:,l) = 0; % logical
            continue;
        end
        
        for l = 1:numel(areaNames)            
            rawAligned = nan(numPointsInWindow, numel(eventTimesAtLoc));
            if isempty(ADAdj{l})
                preprocLFP.rawByLoc{k}.(eventNames{m})(:,:,l) = rawAligned;
                preprocLFP.preCleanByLoc{k}.(eventNames{m})(:,:,l) = rawAligned;
                outlierTrialsByAreaLoc{k}.(eventNames{m})(:,l) = zeros(1, size(rawAligned,2)); % logical
                continue;
            end
            preprocLFP.areasWithData(l) = 1;
            
            % for each event, extract the lfp data around the event
            for j = 1:numel(eventTimesAtLoc)
                % assume fixed sampling rate
                startIndex = round((round(eventTimesAtLoc(j) * Fs) - periEventWindow(1) * Fs)) + 1;
                endIndex = round((round(eventTimesAtLoc(j) * Fs) + periEventWindow(2) * Fs));
                rawAligned(:,j) = ADAdj{l}(startIndex:endIndex); 
            end

            % detrend and remove line noise
            if doDetrend
                detrended = locdetrend(rawAligned, Fs, detrendWindow);
            else
                detrended = rawAligned;
            end

            if doRemoveLineNoise
                % use p=0.05, do not plot, remove 60.025 Hz noise
                processed = fixedRmlinesmovingwinc(detrended, rmlinesWindow, 10, ...
                        params, 0.05, 0, 60.025 * [1 2]);
            else
                processed = detrended;
            end
            
            % manually remove other unusual cross-area sources of noise
            if doRemoveCustomSpectralNoise
                freqs = [];
                
                if strcmp(sessionName, 'L101222')
                    freqs = 180.075;
                end
                if ~isempty(freqs)
                    processed = fixedRmlinesmovingwinc(processed, rmlinesWindow, 10, ...
                            params, 0.05, 0, freqs);
                end
                if strcmp(sessionName, 'C110728') || strcmp(sessionName, 'C110623')
                    % noisy above 45 Hz across areas
                    % lowpass FIR filter
                    % based on eeglab, use FIR1, with filtorder 3*fix(Fs/hicutoff)
                    hiCutoffFreqCustom = 45; % low-pass filter at 45 Hz
                    bFirLowPassCustom = fir1(3*fix(Fs/hiCutoffFreqCustom), hiCutoffFreqCustom/(Fs/2), 'low');
                    processed = filtfilt(bFirLowPassCustom, 1, processed);
                end
                if strcmp(sessionName, 'L101019')
                    % noisy above 120 Hz for PUL and LIP
                    % lowpass FIR filter
                    % based on eeglab, use FIR1, with filtorder 3*fix(Fs/hicutoff)
                    hiCutoffFreqCustom = 120; % low-pass filter at 120 Hz
                    bFirLowPassCustom = fir1(3*fix(Fs/hiCutoffFreqCustom), hiCutoffFreqCustom/(Fs/2), 'low');
                    processed = filtfilt(bFirLowPassCustom, 1, processed);
                end
            end
            
            % find outliers
            if doRemoveOutliers
                [~, outlierTrialsAtLocK] = removeLfpOutliers(processed);
            else
                outlierTrialsAtLocK = zeros(1, size(processed,2));
            end
            
            % preprocLFP.rawByLoc{1}.(eventNames{2})(3,4,5) means:
            % raw LFP when cue was flashed at position 1, around the array
            % onset (event 2), at time point 3 within trial 4, for area 5
            preprocLFP.rawByLoc{k}.(eventNames{m})(:,:,l) = rawAligned;
            preprocLFP.preCleanByLoc{k}.(eventNames{m})(:,:,l) = processed;
            outlierTrialsByAreaLoc{k}.(eventNames{m})(:,l) = outlierTrialsAtLocK; % logical

        end % end area for loop
    end % end cue location for loop
end % end event for loop

%% manually remove outlier trials from certain sessions
% many of these are already removed earlier
yScale = 5;
sevenDefaultLines = lines(7);

% which trials are outliers, mark all areas
if strcmp(sessionName, 'C110524')
    outlierTrialsByAreaLoc{6}.('AroundCue')(2,:) = 1;
end
if strcmp(sessionName, 'C110603')
    outlierTrialsByAreaLoc{3}.('AroundCue')(1,:) = 1;
end
if strcmp(sessionName, 'C110610')
    outlierTrialsByAreaLoc{3}.('AroundCue')(5,:) = 1;
end
if strcmp(sessionName, 'C110617')
    % high amplitude transients in TEO, V4
end
if strcmp(sessionName, 'C110622')
    % high amplitude transients in TEO, V4
    % V4 is noisy
    % only 30 trials - exclude anyway
end
if strcmp(sessionName, 'C110629')
    outlierTrialsByAreaLoc{1}.('AroundCue')(7,:) = 1;
end
if strcmp(sessionName, 'C110701')
    % high frequency ripples in LIP
end
if strcmp(sessionName, 'C110708')
    outlierTrialsByAreaLoc{1}.('AroundCue')(6,:) = 1;
    % high frequency ripples in LIP
end
if strcmp(sessionName, 'C110712')
    % only 16 trials - exclude anyway
    outlierTrialsByAreaLoc{3}.('AroundCue')(1,:) = 1; % flat
end
if strcmp(sessionName, 'C110721')
    % only 14 trials - exclude anyway
    outlierTrialsByAreaLoc{1}.('AroundCue')(2,:) = 1; % flat
    outlierTrialsByAreaLoc{5}.('AroundCue')(1,:) = 1; % flat
end
if strcmp(sessionName, 'C110803')
    outlierTrialsByAreaLoc{6}.('AroundCue')(5,:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundCue')([2 3],:) = 1; % flat
    outlierTrialsByAreaLoc{1}.('AroundCue')(1,:) = 1;
    % almost no signal in LIP
    % only 19 trials - exclude anyway
end
if strcmp(sessionName, 'C110804')
    outlierTrialsByAreaLoc{3}.('AroundCue')([1 4],:) = 1;
    outlierTrialsByAreaLoc{5}.('AroundCue')(1,:) = 1;
end
if strcmp(sessionName, 'C110809')
    outlierTrialsByAreaLoc{4}.('AroundCue')(2,:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundCue')(3,:) = 1;
    outlierTrialsByAreaLoc{6}.('AroundCue')(7,:) = 1;
end
if strcmp(sessionName, 'C110811')
    % ripples in LIP
end
if strcmp(sessionName, 'L101001')
    % major noise, signals almost identical
end
if strcmp(sessionName, 'L101012')
    % lots of outliers, mostly caught by algorithm
    outlierTrialsByAreaLoc{3}.('AroundCue')(21,:) = 1;
    outlierTrialsByAreaLoc{5}.('AroundCue')([10 13],:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundArr')([7 15 18 23 27],:) = 1;
    outlierTrialsByAreaLoc{3}.('AroundArr')(12,:) = 1;
    outlierTrialsByAreaLoc{4}.('AroundArr')(21,:) = 1;
    outlierTrialsByAreaLoc{5}.('AroundArr')(10,:) = 1;
end
if strcmp(sessionName, 'L101018')
    outlierTrialsByAreaLoc{1}.('AroundCue')(2,:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundCue')([7 8],:) = 1;
    outlierTrialsByAreaLoc{3}.('AroundCue')([10 13],:) = 1;
    outlierTrialsByAreaLoc{4}.('AroundCue')(3,:) = 1;
    outlierTrialsByAreaLoc{6}.('AroundCue')([5 10 17],:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundArr')(12,:) = 1;
    outlierTrialsByAreaLoc{3}.('AroundArr')(3,:) = 1;
    outlierTrialsByAreaLoc{4}.('AroundArr')(4,:) = 1;
    outlierTrialsByAreaLoc{5}.('AroundArr')([5 6],:) = 1;
end
if strcmp(sessionName, 'L101123')
    outlierTrialsByAreaLoc{4}.('AroundCue')(8,:) = 1;
end
if strcmp(sessionName, 'L101221')
    % lots of outliers, not all caught by algorithm
    % or the triggers are offset
    outlierTrialsByAreaLoc{1}.('AroundCue')([5 9:15 21],:) = 1;
    outlierTrialsByAreaLoc{2}.('AroundCue')([2 4:6 11 14 19:22 28:29],:) = 1;
    outlierTrialsByAreaLoc{3}.('AroundCue')([1 6 10 11 17 20 22 26:30 32 45],:) = 1;
    outlierTrialsByAreaLoc{4}.('AroundCue')([3 12:14 16 17 19],:) = 1;
    outlierTrialsByAreaLoc{5}.('AroundCue')([3 6:10 14 15 19 23:31 33 41 42 51],:) = 1;
    outlierTrialsByAreaLoc{6}.('AroundCue')([3:7 13 17:20 24:30 39],:) = 1;
    outlierTrialsByAreaLoc{4}.('AroundArr')(6,:) = 1; % just those not above
    outlierTrialsByAreaLoc{5}.('AroundArr')(5,:) = 1;
    outlierTrialsByAreaLoc{6}.('AroundArr')([8 10 15 21 22],:) = 1;
end
if strcmp(sessionName, 'L110426')
    % outliers caught by algorithm
end
if strcmp(sessionName, 'L110531')
    % major high freq burst outliers in V4
end
if 0
    for m = 1:numEvents
        figure_tr_inch(15, 9);
        set(gcf, 'Color', 'w');
        for l = 1:numel(areaNames)
            subaxis(1, numel(areaNames), l, 'ML', 0.05, 'MR', 0.05); hold on;
            numPlotted = 1;
            for k = 1:numCueLocs
                % for each trial at cue location k
                for j = 1:size(preprocLFP.preCleanByLoc{k}.(eventNames{m}), 2)
                    lineStyle = '-';
                    if outlierTrialsByAreaLoc{k}.(eventNames{m})(j,l)
                        lineStyle = '--';
                    end
                    plot(preprocLFP.preCleanByLoc{k}.(eventNames{m})(:,j,l) * yScale + numPlotted, 'LineStyle', lineStyle);
                    text(0.02, numPlotted+0.3, sprintf('P%d t%d', k, j), ...
                            'FontSize', 8, 'Color', sevenDefaultLines(mod(numPlotted-1, 7)+1,:));
                    numPlotted = numPlotted + 1;
                end
            end % end cue location for loop
            title(sprintf('%s - %s', sessionName, areaNames{l}));
            ylim([0 numPlotted]);
        end % end area for loop
        
        suptitle(sprintf('%s - %s', sessionName, eventNames{m}));
        fileName = sprintf('%s-%s-outlierCheck.png', sessionName, eventNames{m});
        export_fig(fileName, '-nocrop');
%         pause;
        close;
    end % end event for loop
end

%% find outlier trials for whole session (all areas)
% a trial that is an outlier when aligned to cue will also be removed for
% the data aligned to array
% a trial that is an outlier for one area will also be removed for all
% other areas
% should be the same number of trials in each event

% each element is [nTrials x 1]
preprocLFP.outlierTrialsByLoc = cell(numCueLocs, 1);

for k = 1:numCueLocs
    % outlierTrialsAtK is [nTrials x nEvents] 
    outlierTrialsAtK = zeros(size(outlierTrialsByAreaLoc{k}.(eventNames{1}),1), numEvents);
    for m = 1:numEvents
        % combine across areas
        % outlierTrialsByLoc{m,k} is [nTrials x nAreas]
        % any(x,2) -> [nTrials x 1]
        outlierTrialsAtK(:,m) = any(outlierTrialsByAreaLoc{k}.(eventNames{m}), 2);
    end
    
    % combine across events
    % any(x,2) -> [nTrials x 1]
    preprocLFP.outlierTrialsByLoc{k} = any(outlierTrialsAtK, 2);
end

%% remove outlier trials for whole session (all areas, all events)

preprocLFP.postCleanByLoc = cell(size(preprocLFP.preCleanByLoc));
for k = 1:numCueLocs
    for m = 1:numEvents
        % ADAdjByLocProcessed{k}.(eventNames{m}) is [nTimePts x nTrials x
        % nAreas]
        % outlierTrialsByLoc{k} is [nTrials x 1]
        preprocLFP.postCleanByLoc{k}.(eventNames{m}) = preprocLFP.preCleanByLoc{k}.(eventNames{m});
        preprocLFP.postCleanByLoc{k}.(eventNames{m})(:,preprocLFP.outlierTrialsByLoc{k},:) = [];
    end
end

%% check on events
for k = 1:numCueLocs
    assert(sum(~isnan(CueP(:,k))) == numel(preprocLFP.outlierTrialsByLoc{k}));
    assert(sum(~isnan(ArrP(:,k))) == numel(preprocLFP.outlierTrialsByLoc{k}));
end

%% tag events as non-outlier and (barcon or bowcon)
eventNames = [eventNames, {'AroundArrBarCon', 'AroundArrBowCon'}];
numEvents = numel(eventNames);

for k = 1:numCueLocs
    ArrPk = ArrP(:,k);
    ArrPk = ArrPk(~isnan(ArrPk));
    ArrBarConPk = ArrBarConP(:,k);
    ArrBarConPk = ArrBarConPk(~isnan(ArrBarConPk));
    ArrBowConPk = ArrBowConP(:,k);
    ArrBowConPk = ArrBowConPk(~isnan(ArrBowConPk));
    
    [~,indBarConAtK] = intersect(ArrPk, ArrBarConPk);
    [~,indBowConAtK] = intersect(ArrPk, ArrBowConPk);
    assert(isempty(intersect(indBarConAtK, indBowConAtK)));
    
    isBarConAtK = zeros(sum(~isnan(ArrPk)), 1);
    isBowConAtK = zeros(sum(~isnan(ArrPk)), 1);
    isBarConAtK(indBarConAtK) = 1;
    isBowConAtK(indBowConAtK) = 1;
    isBarConAtK = logical(isBarConAtK);
    isBowConAtK = logical(isBowConAtK);
    isBarConCleanAtK = isBarConAtK & ~preprocLFP.outlierTrialsByLoc{k};
    isBowConCleanAtK = isBowConAtK & ~preprocLFP.outlierTrialsByLoc{k};
    
    % add two new events to preClean and postClean
    preprocLFP.preCleanByLoc{k}.(eventNames{3}) = preprocLFP.preCleanByLoc{k}.(eventNames{2})(:,isBarConAtK,:);
    preprocLFP.preCleanByLoc{k}.(eventNames{4}) = preprocLFP.preCleanByLoc{k}.(eventNames{2})(:,isBowConAtK,:);
    preprocLFP.postCleanByLoc{k}.(eventNames{3}) = preprocLFP.preCleanByLoc{k}.(eventNames{2})(:,isBarConCleanAtK,:);
    preprocLFP.postCleanByLoc{k}.(eventNames{4}) = preprocLFP.preCleanByLoc{k}.(eventNames{2})(:,isBowConCleanAtK,:);
    
end

%% low-pass filter both the pre clean and post clean data

% lowpass FIR filter
% based on eeglab, use FIR1, with filtorder 3*fix(Fs/hicutoff)
hiCutoffFreq = 200; % low-pass filter at 200 Hz
bFirLowPass = fir1(3*fix(Fs/hiCutoffFreq), hiCutoffFreq/(Fs/2), 'low');

preprocLFP.preCleanByLocFilt = cell(size(preprocLFP.preCleanByLoc));
preprocLFP.postCleanByLocFilt = cell(size(preprocLFP.postCleanByLoc));
for k = 1:numCueLocs
    for m = 1:numEvents
        preprocLFP.preCleanByLocFilt{k}.(eventNames{m}) = preprocLFP.preCleanByLoc{k}.(eventNames{m});
        preprocLFP.postCleanByLocFilt{k}.(eventNames{m}) = preprocLFP.postCleanByLoc{k}.(eventNames{m});
        for l = 1:numel(areaNames)
            % preprocLFP.preCleanByLoc{k}.(eventNames{m}) is 
            % [nTimePts x nTrials x nAreas]
            % TODO: test whether filtfilt works correctly when 2D data
            % passed in
            preprocLFP.preCleanByLocFilt{k}.(eventNames{m})(:,:,l) = filtfilt(...
                    bFirLowPass, 1, preprocLFP.preCleanByLoc{k}.(eventNames{m})(:,:,l));
            preprocLFP.postCleanByLocFilt{k}.(eventNames{m})(:,:,l) = filtfilt(...
                    bFirLowPass, 1, preprocLFP.postCleanByLoc{k}.(eventNames{m})(:,:,l));
        end
    end
end


%% identify array barcon vs bowcon
m = 2;

for k = 1:numCueLocs
    preprocLFP.preCleanByLocFilt{k}.(eventNames{m}) = preprocLFP.preCleanByLoc{k}.(eventNames{m});
    preprocLFP.postCleanByLocFilt{k}.(eventNames{m}) = preprocLFP.postCleanByLoc{k}.(eventNames{m});
    for l = 1:numel(areaNames)
        % preprocLFP.preCleanByLoc{k}.(eventNames{m}) is 
        % [nTimePts x nTrials x nAreas]
        % TODO: test whether filtfilt works correctly when 2D data
        % passed in
        preprocLFP.preCleanByLocFilt{k}.(eventNames{m})(:,:,l) = filtfilt(...
                bFirLowPass, 1, preprocLFP.preCleanByLoc{k}.(eventNames{m})(:,:,l));
        preprocLFP.postCleanByLocFilt{k}.(eventNames{m})(:,:,l) = filtfilt(...
                bFirLowPass, 1, preprocLFP.postCleanByLoc{k}.(eventNames{m})(:,:,l));
    end
end