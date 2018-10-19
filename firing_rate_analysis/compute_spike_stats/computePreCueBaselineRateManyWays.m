function baselineRates = computePreCueBaselineRateManyWays(...
        spikeTimesByCondAlignedToCue, cueOnset)
% compute pre-cue baseline firing rates using 4 different methods
%
% compute pre-cue baseline firing rates using 4 different methods: 
% 1: no baseline
% 2: baseline using averaged activity across all trials
% 3: a baseline for each cue location using averaged activity across all
% trials for each cue location
% 4: a baseline for each cue location x target shape x congruency condition
% using averaged activity across all trials for each condition
% 
%   spikeTimesByCondAlignedToCue - struct of cells with spike times aligned
%   to cue onset
%   cueOnset - time of cue onset
%
% returns a struct with fields corresponding to the baseline rates computed
% by the four methods: none, allTrials, byLoc, byCond
% if there are no trials in a particular location or condition, baseline
% rate is NaN

numLocs = size(spikeTimesByCondAlignedToCue.combData, 2);

% method 1: no baseline
baselineRates.none = 0;

% method 2: combine all trials
allTrials = [];
for i = 1:numLocs
    % note, sometimes spikeTimesByCondAlignedToCue.combData{i} is empty
    allTrials = [allTrials spikeTimesByCondAlignedToCue.combData{i}];
end
[baselineRates.allTrials,baselineRates.allTrialsSD,baselineRates.baselineWindowOffset] = computePreCueBaselineRateNew(allTrials, cueOnset);

% optional test
% allTrialsAlignedCueByTime = cell2mat(spikeTimesByCondAlignedToCue.combSortedByTimeData);
% assert(baselineRates.allTrials == computePreCueBaselineRateNew(allTrialsAlignedCueByTime, cueOnset));

% method 3: split trials by location, in order of location number
for i = 1:numLocs
    [baselineRates.byLoc(i),baselineRates.byLocSD(i),baselineWindowOffset2] = computePreCueBaselineRateNew(...
            spikeTimesByCondAlignedToCue.combData{i}, cueOnset);
    assert(all(baselineRates.baselineWindowOffset == baselineWindowOffset2));
end

% method 4: split trials by location x shape x bar/bow condition, in order
% of those conditions -- P1BarCon, P1BarIncon, P1BowCon, P1BowIncon, etc.
conds = {'barCon', 'barIncon', 'bowCon', 'bowIncon', 'bar', 'bow'};
for i = 1:numel(conds)
    if isfield(spikeTimesByCondAlignedToCue, [conds{i} 'Data'])
        condData = spikeTimesByCondAlignedToCue.([conds{i} 'Data']);
        for j = 1:numLocs
            [baselineRates.byCond.(conds{i})(j),baselineRates.byCondSD.(conds{i})(j)] = ...
                    computePreCueBaselineRateNew(condData{j}, cueOnset);
        end
    end
end
