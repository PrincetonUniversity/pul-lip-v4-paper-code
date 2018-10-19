function computeDelayPeriodFRStatsByArea(spikeStats5D, spikeFiles5D, areaName, outputDir, v)

fprintf('---------------- Computing delay period firing rate statistics for area %s (v = %d) ----------------\n', areaName, v);

%% get manual RF choices
rfChoicesFileName = [lower(areaName) '_rf_choices.csv'];
[rfcSession,rfcCellID,rfcInRF,rfcExRF,rfcQuality,~,~,~] = readCellRFChoices(...
        rfChoicesFileName);
fprintf('Loaded RF choices from %s (%d cells)\n', rfChoicesFileName, numel(rfcCellID));

%% get RFs per session
inRFLocs = nan(numel(spikeStats5D), 1);
exRFLocs = nan(numel(spikeStats5D), 1);
for i = 1:numel(spikeStats5D)
    spikeFileName = getFileName(spikeFiles5D{i});
    sessionName = spikeFileName(1:7);
    cellID = spikeFileName(12:13);

    rfcMatch = find(strcmp(sessionName, rfcSession) & ...
            strcmp(cellID, rfcCellID));
    assert(length(rfcMatch) == 1);

    if rfcQuality(rfcMatch) >= 1
        inRFLocs(i) = rfcInRF(rfcMatch);
        exRFLocs(i) = rfcExRF(rfcMatch);
    end
end
fprintf('RFs selected for %d/%d sessions.\n', ...
        sum(~isnan(inRFLocs)), numel(spikeStats5D));

%% exclude these sessions
excludedSessions = {'C110727_sig3b_5D'};

%% 
delayRatesInRFNorm = nan(numel(spikeStats5D), 1);
delayRatesExRFNorm = nan(numel(spikeStats5D), 1);

baselineWindowOffset = [NaN NaN]; % will set later
delayWindowOffset = [NaN NaN];

% for each 5D session where the preferred cue location could be determined
% and there are more than the minimum number of trials at the preferred and
% nonpreferred cue locations, 
% compute the normalized firing rate for pref & nonpref locations over the cue 
% period
numSessionsUsed = 0;
for i = 1:numel(spikeStats5D)
    spikeFileName = getFileName(spikeFiles5D{i});
    
    % skip excluded sessions
    if any(ismember(excludedSessions, spikeFileName(1:16)))
        fprintf('Special case: Skipping %s\n', spikeFileName);
        continue;
    end

    % skip sessions without a specified RF
    if isnan(inRFLocs(i))
        sessionName = spikeFileName(1:7);
        cellID = spikeFileName(12:13);
        fprintf('No matching RF choice for session %s, cell %s\n', sessionName, cellID);
        continue;
    end

    numSessionsUsed = numSessionsUsed + 1;
    % question: whether to do per-condition baseline correction, use all
    % trials to compute the baseline for correction (will not change stats
    % because subtracting the same number from both conditions), or don't
    % use baseline correction.
    % the baseline should be the same across conditions but often it is not
    % because of low trial numbers and random drift / environmental /
    % uninteresting changes. therefore we should use per-condition baseline
    % correction (which is the same as per-trial baseline correction),
    % though this may add noise and bias to our signal. it is common in EEG
    % analysis to do per-trial/condition and per-channel baseline 
    % correction to account for drift and channel differences. however,
    % when dealing with low trial numbers across all trials, there are even
    % fewer trials split by condition, and so the baseline will be even
    % more noisy in those cases. 
    % (another option is percent change from baseline but will be ignored
    % here)
    % another question: how best to normalize the spike density functions
    % for averaging across sessions?
    maxTrialRate = max(spikeStats5D{i}.maxTrialRates.rateByLoc([inRFLocs(i) exRFLocs(i)]));
    baselineRatesInRF = spikeStats5D{i}.averageSPDFFiringRates.preCueBaselineByLoc(inRFLocs(i));
    baselineRatesExRF = spikeStats5D{i}.averageSPDFFiringRates.preCueBaselineByLoc(exRFLocs(i));
    
    delayRatesInRF = spikeStats5D{i}.averageSPDFFiringRates.delay200ResponseByLoc(inRFLocs(i));
    delayRatesExRF = spikeStats5D{i}.averageSPDFFiringRates.delay200ResponseByLoc(exRFLocs(i));
    delayRatesInRFNorm(i) = (delayRatesInRF - baselineRatesInRF) / (maxTrialRate - baselineRatesInRF);
    delayRatesExRFNorm(i) = (delayRatesExRF - baselineRatesExRF) / (maxTrialRate - baselineRatesExRF);
    assert(~isnan(delayRatesInRFNorm(i)) & ~isnan(delayRatesExRFNorm(i)));
    
    % get the window offsets
    if numSessionsUsed == 1
        baselineWindowOffset = spikeStats5D{i}.baselineRates.baselineWindowOffset;
        delayWindowOffset = spikeStats5D{i}.averageSPDFFiringRates.delay200WindowOffset;
    else
        assert(all(baselineWindowOffset == spikeStats5D{i}.baselineRates.baselineWindowOffset));
        assert(all(delayWindowOffset == spikeStats5D{i}.averageSPDFFiringRates.delay200WindowOffset));
    end
end
sessionsToRemove = isnan(delayRatesInRFNorm) | isnan(delayRatesExRFNorm);
delayRatesInRFNorm(sessionsToRemove) = [];
delayRatesExRFNorm(sessionsToRemove) = [];
fprintf('Excluded %d/%d sessions...\n', sum(sessionsToRemove), numel(spikeStats5D));
fprintf('\n');
fprintf('-------------------------\n')
fprintf('v = %d -- %s (N=%d):\n', v, areaName, numel(delayRatesInRFNorm));

%% test delay period enhancement at RF relative to baseline
fprintf('T-Test on Baseline < Delay InRF Firing Rates in baseline window [%0.2f, %0.2f] s from cue onset, delay window [%0.2f, %0.2f] s from array onset:\n', ...
        baselineWindowOffset, delayWindowOffset);
[~,PTTest,~,STATS] = ttest(delayRatesInRFNorm, zeros(size(delayRatesInRFNorm)), 'tail', 'right');
fprintf('\tT(%d) = %0.2f, p(1-tailed) = %0.5f\n', STATS.df, STATS.tstat, PTTest);
PSignRank = signrank(delayRatesInRFNorm, zeros(size(delayRatesInRFNorm)), 'tail', 'right');
fprintf('\tsignrank(n=%d), p(1-tailed) = %0.5f\n', numel(delayRatesInRFNorm), PSignRank);

%% test delay period suppression away from RF relative to baseline
fprintf('T-Test on Baseline > Delay ExRF Firing Rates in baseline window [%0.2f, %0.2f] s from cue onset, delay window [%0.2f, %0.2f] s from array onset:\n', ...
        baselineWindowOffset, delayWindowOffset);
[~,PTTest,~,STATS] = ttest(delayRatesExRFNorm, zeros(size(delayRatesExRFNorm)), 'tail', 'left');
fprintf('\tT(%d) = %0.2f, p(1-tailed) = %0.5f\n', STATS.df, STATS.tstat, PTTest);
PSignRank = signrank(delayRatesExRFNorm, zeros(size(delayRatesExRFNorm)), 'tail', 'left');
fprintf('\tsignrank(n=%d), p(1-tailed) = %0.5f\n', numel(delayRatesExRFNorm), PSignRank);

%% test attentional modulation in delay period
delayRatesDiffNorm = delayRatesInRFNorm - delayRatesExRFNorm;
fprintf('T-Test on InRF > ExRF Firing Rates in window [%0.2f, %0.2f] s from array onset:\n', ...
        delayWindowOffset);
[~,PTTest,~,STATS] = ttest(delayRatesDiffNorm, zeros(size(delayRatesDiffNorm)), 'tail', 'right');
fprintf('\tT(%d) = %0.2f, p(1-tailed) = %0.5f\n', STATS.df, STATS.tstat, PTTest);
PSignRank = signrank(delayRatesDiffNorm, zeros(size(delayRatesDiffNorm)), 'tail', 'right');
fprintf('\tsignrank(n=%d), p(1-tailed) = %0.5f\n', numel(delayRatesDiffNorm), PSignRank);
 
fprintf('-------------------------\n')

%% plot distribution and stats
plotDelayPeriodFRStats(delayRatesInRFNorm, delayRatesExRFNorm, ...
        PTTest, PSignRank, delayWindowOffset, areaName, outputDir, v);