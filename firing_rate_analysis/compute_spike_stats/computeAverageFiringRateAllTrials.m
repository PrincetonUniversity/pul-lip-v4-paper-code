function averageFiringRates = computeAverageFiringRateAllTrials(...
        spikeTimesByCondAlignedToCue, cueOnset, spikeTimesByCondAlignedToArr, arrOnset)
% compute the average firing rate around three different time windows of 
% the trial, using all trials, regardless of cue location, shape, and
% congruency. none of the three windows include the array period anyway.

preCueBaselineWindowOffset = [-0.1 0];
aroundCueWindowOffset = [-0.1 0.4];
cueResponseWindowOffset = [0.02 0.2];
delay200WindowOffset = [-0.2 0];
delay300WindowOffset = [-0.3 0];
arrResponseWindowOffset = [0.02 0.2];

allTrialsAlignedCueByTime = cell2mat(spikeTimesByCondAlignedToCue.combSortedByTimeData);
allTrialsAlignedArrByTime = cell2mat(spikeTimesByCondAlignedToArr.combSortedByTimeData);

preCueBaselineWindow = cueOnset + preCueBaselineWindowOffset;
aroundCueWindow = cueOnset + aroundCueWindowOffset;
cueResponseWindow = cueOnset + cueResponseWindowOffset;
delay200Window = arrOnset + delay200WindowOffset;
delay300Window = arrOnset + delay300WindowOffset;
arrResponseWindow = arrOnset + arrResponseWindowOffset;

averageFiringRates.preCueBaseline = computeAvgRateInWin(allTrialsAlignedCueByTime, preCueBaselineWindow);
averageFiringRates.aroundCue = computeAvgRateInWin(allTrialsAlignedCueByTime, aroundCueWindow);
averageFiringRates.cueResponse = computeAvgRateInWin(allTrialsAlignedCueByTime, cueResponseWindow);
averageFiringRates.delay200 = computeAvgRateInWin(allTrialsAlignedArrByTime, delay200Window);
averageFiringRates.delay300 = computeAvgRateInWin(allTrialsAlignedArrByTime, delay300Window);
averageFiringRates.arrResponse = computeAvgRateInWin(allTrialsAlignedArrByTime, arrResponseWindow);

numLocs = numel(spikeTimesByCondAlignedToCue.combData);
for i = 1:numLocs
    [averageFiringRates.preCueBaselineByLoc(i),averageFiringRates.preCueBaselineByLocSD(i),averageFiringRates.preCueBaselineFanoFactor(i)] = computeAvgRateInWin(...
            spikeTimesByCondAlignedToCue.combData{i}, preCueBaselineWindow);
    [averageFiringRates.cueResponseByLoc(i),averageFiringRates.cueResponseByLocSD(i),averageFiringRates.cueFanoFactor(i)] = computeAvgRateInWin(...
            spikeTimesByCondAlignedToCue.combData{i}, cueResponseWindow);
    [averageFiringRates.delay200ResponseByLoc(i),averageFiringRates.delay200ResponseByLocSD(i),averageFiringRates.delay200FanoFactor(i)] = computeAvgRateInWin(...
            spikeTimesByCondAlignedToArr.combData{i}, delay200Window);
    [averageFiringRates.delay300ResponseByLoc(i),averageFiringRates.delay300ResponseByLocSD(i),averageFiringRates.delay300FanoFactor(i)] = computeAvgRateInWin(...
            spikeTimesByCondAlignedToArr.combData{i}, delay300Window);
    [averageFiringRates.arrResponseByLoc(i),averageFiringRates.arrResponseByLocSD(i),averageFiringRates.arrFanoFactor(i)] = computeAvgRateInWin(...
            spikeTimesByCondAlignedToArr.combData{i}, arrResponseWindow);
end

averageFiringRates.preCueBaselineWindowOffset = preCueBaselineWindowOffset;
averageFiringRates.aroundCueWindowOffset = aroundCueWindowOffset;
averageFiringRates.cueResponseWindowOffset = cueResponseWindowOffset;
averageFiringRates.delay200WindowOffset = delay200WindowOffset;
averageFiringRates.delay300WindowOffset = delay300WindowOffset;
averageFiringRates.arrResponseWindowOffset = arrResponseWindowOffset;

