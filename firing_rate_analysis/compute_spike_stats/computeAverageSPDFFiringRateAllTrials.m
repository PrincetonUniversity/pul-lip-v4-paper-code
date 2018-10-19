function averageSPDFFiringRates = computeAverageSPDFFiringRateAllTrials(...
        cueSpikeStats, arrSpikeStats, averageFiringRates)
% compute the average firing rate around three different time windows of 
% the trial, using all trials, regardless of cue location, shape, and
% congruency. none of the three windows include the array period anyway.

preCueTInd = getTimeLogicalWithTolerance(cueSpikeStats.t, averageFiringRates.preCueBaselineWindowOffset);
cueResponseTInd = getTimeLogicalWithTolerance(cueSpikeStats.t, averageFiringRates.cueResponseWindowOffset);
delay200TInd = getTimeLogicalWithTolerance(arrSpikeStats.t, averageFiringRates.delay200WindowOffset);
delay300TInd = getTimeLogicalWithTolerance(arrSpikeStats.t, averageFiringRates.delay300WindowOffset);
arrResponseTInd = getTimeLogicalWithTolerance(arrSpikeStats.t, averageFiringRates.arrResponseWindowOffset);

% all trials
averageSPDFFiringRates.preCueBaseline = mean(cueSpikeStats.combSortedByTime.rates(:,preCueTInd));
averageSPDFFiringRates.cueResponse = mean(cueSpikeStats.combSortedByTime.rates(:,cueResponseTInd));
averageSPDFFiringRates.delay200 = mean(arrSpikeStats.combSortedByTime.rates(:,delay200TInd));
averageSPDFFiringRates.delay300 = mean(arrSpikeStats.combSortedByTime.rates(:,delay300TInd));
averageSPDFFiringRates.arrResponse = mean(arrSpikeStats.combSortedByTime.rates(:,arrResponseTInd));

% split trials by cue location
numLocs = numel(cueSpikeStats.comb.locData);
for loc = 1:numLocs
    averageSPDFFiringRates.preCueBaselineByLoc(loc) = mean(cueSpikeStats.comb.rates(loc,preCueTInd));
    averageSPDFFiringRates.cueResponseByLoc(loc) = mean(cueSpikeStats.comb.rates(loc,cueResponseTInd));
    averageSPDFFiringRates.delay200ResponseByLoc(loc) = mean(arrSpikeStats.comb.rates(loc,delay200TInd));
    averageSPDFFiringRates.delay300ResponseByLoc(loc) = mean(arrSpikeStats.comb.rates(loc,delay300TInd));
    averageSPDFFiringRates.arrResponseByLoc(loc) = mean(arrSpikeStats.comb.rates(loc,arrResponseTInd));
    
    averageSPDFFiringRates.preCueBaselineErrByLoc(loc) = mean(cueSpikeStats.comb.rateErrs(loc,preCueTInd));
    averageSPDFFiringRates.cueResponseErrByLoc(loc) = mean(cueSpikeStats.comb.rateErrs(loc,cueResponseTInd));
    averageSPDFFiringRates.delay200ResponseErrByLoc(loc) = mean(arrSpikeStats.comb.rateErrs(loc,delay200TInd));
    averageSPDFFiringRates.delay300ResponseErrByLoc(loc) = mean(arrSpikeStats.comb.rateErrs(loc,delay300TInd));
    averageSPDFFiringRates.arrResponseErrByLoc(loc) = mean(arrSpikeStats.comb.rateErrs(loc,arrResponseTInd));
end

averageSPDFFiringRates.preCueBaselineWindowOffset = averageFiringRates.preCueBaselineWindowOffset;
averageSPDFFiringRates.cueResponseWindowOffset = averageFiringRates.cueResponseWindowOffset;
averageSPDFFiringRates.delay200WindowOffset = averageFiringRates.delay200WindowOffset;
averageSPDFFiringRates.delay300WindowOffset = averageFiringRates.delay300WindowOffset;
averageSPDFFiringRates.arrResponseWindowOffset = averageFiringRates.arrResponseWindowOffset;

