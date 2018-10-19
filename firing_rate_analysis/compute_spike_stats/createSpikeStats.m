function spikeStats = createSpikeStats(S, spikeFilePath)

T = load(spikeFilePath, 'SpikeTimes');

isZeroDistractors = ismember(spikeFilePath, S.spikeFiles0D);
if ~isZeroDistractors % 5D file
    cueAlignedData = makeBarBowConInconSplit(T.SpikeTimes, S.eventInfo.locs, 'AroundCue', 'Cue');
    arrAlignedData = makeBarBowConInconSplit(T.SpikeTimes, S.eventInfo.locs, 'AroundArr', 'Arr');
else % 0D file
    cueAlignedData = makeBarBowSplit(T.SpikeTimes, S.eventInfo.locs, 'AroundCue', 'Cue');
    arrAlignedData = makeBarBowSplit(T.SpikeTimes, S.eventInfo.locs, 'AroundArr', 'Arr');
end

% add all data sorted by time to the cue data for spike stats
% processing, just like the others
cueAlignedData.combSortedByTimeData = {T.SpikeTimes.AroundCueSortedByTime};
arrAlignedData.combSortedByTimeData = {T.SpikeTimes.AroundArrSortedByTime};

cueWin = S.eventInfo.eventWindows('Cue');
arrWin = S.eventInfo.eventWindows('Arr');

spikeStats.baselineRates = computePreCueBaselineRateManyWays(cueAlignedData, cueWin(1));
spikeStats.averageFiringRates = computeAverageFiringRateAllTrials(cueAlignedData, cueWin(1), ...
        arrAlignedData, arrWin(1));


spikeStats.cueSpikeStats = computeSpikeStatsRunner(cueAlignedData, cueWin, 'kernelSigma', 0.01);
spikeStats.arrSpikeStats = computeSpikeStatsRunner(arrAlignedData, arrWin, 'kernelSigma', 0.01);

spikeStats.maxTrialRates = computeMaxTrialRateSingleLoc(spikeStats.cueSpikeStats, ...
        spikeStats.arrSpikeStats, isZeroDistractors);

% compute average firing rate using mean of SPDF
spikeStats.averageSPDFFiringRates = computeAverageSPDFFiringRateAllTrials(spikeStats.cueSpikeStats, ...
        spikeStats.arrSpikeStats, spikeStats.averageFiringRates);

if ~isZeroDistractors % 5D file
    % store manual RF choices
    rfChoicesFileName = [lower(S.areaName) '_rf_choices.csv'];
    
    [rfcSession,rfcCellID,rfcInRF,rfcExRF] = readCellRFChoices(rfChoicesFileName);
    spikeFileName = getFileName(spikeFilePath);
    sessionName = spikeFileName(1:7);
    cellID = spikeFileName(12:13);

    rfcMatch = find(strcmp(sessionName, rfcSession) & strcmp(cellID, rfcCellID));
    assert(length(rfcMatch) == 1);

    % CURRENTLY USED ONLY FOR PLOT HIGHLIGHTING
    spikeStats.manualInRFLoc = rfcInRF(rfcMatch);
    spikeStats.manualExRFLoc = rfcExRF(rfcMatch);
    
else % 0D file
    spikeStats.manualInRFLoc = NaN;
    spikeStats.manualExRFLoc = NaN;
end
