function saveFilePaths = createSpikeVars(dataDir, sessionName, ...
        areaName, eventInfo, doOverwrite, isZeroDistractors, procDataDir, v)
% Create spike data mat file in chronux format for a given recording 
% session
% 
% Inputs:
% - dataDir = base directory where one would find the session-named
%   recording data directories
% - sessionName = name of the session data directory in dataDir
% - areaName = name of the directory in the spike data directory where one
%   would find the spike data for the area being looked at here
% - eventInfo = struct containing the times of all events of interest
% - doOverwrite = whether to overwrite the existing .mat file if it exists
% - procDataDir = processed data dir to save spike variables to
% - v = version number
% 
% Outputs:
% - saveFilePaths = names of the .mat files to which the spike time data 
%   was saved

fprintf('%s', sessionName);
allSpikesFileName = [dataDir sessionName filesep sessionName '_allSpikes.mat'];
allSpikesContents = whos('-file', allSpikesFileName);
if ~isZeroDistractors
    E = load([dataDir sessionName filesep 'StimuliOnset_5D.mat']);
    fprintf(' 5D');
else
    E = load([dataDir sessionName filesep 'StimuliOnset_0D.mat']);
    fprintf(' 0D');
end
fprintf(' data loaded...\n');

saveFilePaths = {};

% Load spike data
if strcmp(areaName, 'LIP')
    spikeSigNames = {'sig003a','sig003b','sig003c','sig003d'};
elseif strcmp(areaName, 'V4')
    spikeSigNames = {'sig004a','sig004b','sig004c'};
elseif strcmp(areaName, 'PUL')
    spikeSigNames = {'sig001a','sig001b','sig001c'};
end

spikeTimeVarNames = eventInfo.spikeTimeVarNames;
windows = eventInfo.eventWindows;

addInd = 1;

for i = 1:numel(spikeSigNames)
    % drop the 0s for shorter var names: sig003a -> sig3a
    newSpikeSigName = ['sig' spikeSigNames{i}(end-1:end)];

    % e.g. C110531_sig3a.mat
    if ~isZeroDistractors
        saveFilePath = sprintf('%s/%s_%s_5D_v%d.mat', procDataDir, sessionName, newSpikeSigName, v);
    else
        saveFilePath = sprintf('%s/%s_%s_0D_v%d.mat', procDataDir, sessionName, newSpikeSigName, v);
    end
    
    % don't overwrite files if that flag is off
    if ~doOverwrite && exist(saveFilePath, 'file') == 2
        saveFilePaths{addInd} = saveFilePath; %#ok<AGROW>
        addInd = addInd + 1;
        fprintf('\t%s exists - not overwriting.\n', saveFilePath);
        continue;
    end
    
    % if the spike sig var exists within this .mat file
    if ismember(spikeSigNames{i}, {allSpikesContents.name})
        fprintf('\tFound %s... ', spikeSigNames{i});
        sig = load(allSpikesFileName, spikeSigNames{i}); % the full spike data
        sig = sig.(spikeSigNames{i}); % unpack struct
        
        % create all variables of interest
        for j = 1:length(spikeTimeVarNames)
            if isZeroDistractors && ~strcmp(spikeTimeVarNames(j).con, '')
                continue; % skip Con/Incon vars for 0D case
            end
            if ismember(spikeTimeVarNames(j).event, {'WholeTrial', 'Delay'})
                data = createSpikeVarVariablePeriod(sessionName, newSpikeSigName, ...
                        spikeTimeVarNames(j), sig, E, windows);
            else
                window = windows(spikeTimeVarNames(j).window);
                eventTimes = unpackEventVar(E, spikeTimeVarNames(j));
                eventTimes = cleanEventTimes(sessionName, newSpikeSigName, eventTimes);
                data = createnonemptydatamatpt(sig, eventTimes, window);
            end
            % print the fraction of kept events
            % fprintf('%d/%d,',numel(data),numel(eventTimes));
            % save with new name
            SpikeTimes.(spikeTimeVarNames(j).event).(spikeTimeVarNames(j).spikeTimesName) = data;
        end
        
        % create variable with cue data where trials are sorted by time
        window = windows('Cue');
        timeSortedCueTimes = sort(reshape(E.CueP, numel(E.CueP), 1));
        timeSortedCueTimes(isnan(timeSortedCueTimes)) = []; % remove NaNs
        timeSortedCueTimes = cleanEventTimes(sessionName, newSpikeSigName, timeSortedCueTimes, 1);
        SpikeTimes.AroundCueSortedByTime = createnonemptydatamatpt(sig, ...
                timeSortedCueTimes, window);
        
        % create variable with arr data where trials are sorted by time
        window = windows('Arr');
        timeSortedArrTimes = sort(reshape(E.ArrP, numel(E.ArrP), 1));
        timeSortedArrTimes(isnan(timeSortedArrTimes)) = []; % remove NaNs
        timeSortedArrTimes = cleanEventTimes(sessionName, newSpikeSigName, timeSortedArrTimes, 1);
        SpikeTimes.AroundArrSortedByTime = createnonemptydatamatpt(sig, ...
                timeSortedArrTimes, window);
        
        % store the base information per trial as well
        TrialTable = E.TrialTable;
        TrialTable = cleanTrialTable(sessionName, newSpikeSigName, TrialTable);
        
        save(saveFilePath, 'SpikeTimes', 'TrialTable');
        clear SpikeTimes timeSortedCueTimes window eventTimes data sig j
        
        saveFilePaths{addInd} = saveFilePath; %#ok<AGROW>
        addInd = addInd + 1;
        fprintf('processed. Data matrices saved to %s.\n', getFileName(saveFilePath));
    end
end
