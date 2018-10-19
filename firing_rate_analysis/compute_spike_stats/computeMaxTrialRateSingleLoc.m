function maxTrialRates = computeMaxTrialRateSingleLoc(...
        cueSpikeStats, arrSpikeStats, isZeroDistractors)
% max firing rate during the course of the trial (-200 from cue onset, +200 from
% array onset) -- trials have to be aligned to something in order to get firing
% rates that don't come from individual trials, so approximate this by looking
% [-200,400] around cue onset and [-400,200] around array onset since time
% between cue onset and array onset is minimum 400ms (and max 800ms). this will 
% cover all time points but not re-align the cue response (assumed within 100ms 
% from cue onset) when aligned to the array or vice versa. 

% max trial rate is determined for each cue location independently

% note that this method doesn't count spikes, but rather looks at the psth rates

maxTrialRates.cueWindowOffset = [-0.2 0.4]; % look 200 ms pre-cue-onset to 400ms post-cue-onset
maxTrialRates.delayWindowOffset = [-0.4 0]; % look 400 ms pre-array-onset to array onset
maxTrialRates.arrWindowOffset = [0 0.2]; % look 300 ms pre-array-onset to 200ms post-array-onset

numLocs = numel(cueSpikeStats.comb.locData);

for loc = 1:numLocs
    % compute max firing rate around the CUE normalization period for all
    % conditions combined because it doesn't make sense from the monkey's POV to
    % split it up yet
    % slow b/c computation on so many unnecessary conditions
    % don't use cueSpikeStatsForNorm.comb.maxRates because that ignores location
    cueTInd = getTimeLogicalWithTolerance(cueSpikeStats.t, maxTrialRates.cueWindowOffset(1), ...
            maxTrialRates.cueWindowOffset(2));
    maxCuePeriodRate = max(cueSpikeStats.comb.rates(loc,cueTInd));

    % compute max firing rate around the DELAY normalization period
    delayTInd = getTimeLogicalWithTolerance(arrSpikeStats.t, maxTrialRates.delayWindowOffset(1), ...
            maxTrialRates.delayWindowOffset(2));
    maxDelayPeriodRate = max(arrSpikeStats.comb.rates(loc,delayTInd));

    % compute max firing rate around the ARRAY normalization period
    arrTInd = getTimeLogicalWithTolerance(arrSpikeStats.t, maxTrialRates.arrWindowOffset(1), ...
            maxTrialRates.arrWindowOffset(2));
    if ~isZeroDistractors
        % compute max firing rate around the array normalization period split up by
        % shape-con condition
        maxArrPeriodRate = max([max(arrSpikeStats.barCon.rates(loc,arrTInd))...
                max(arrSpikeStats.barIncon.rates(loc,arrTInd))...
                max(arrSpikeStats.bowCon.rates(loc,arrTInd))...
                max(arrSpikeStats.bowIncon.rates(loc,arrTInd))...
                max(arrSpikeStats.bar.rates(loc,arrTInd))...
                max(arrSpikeStats.bow.rates(loc,arrTInd))...
                max(arrSpikeStats.comb.rates(loc,arrTInd))]);
    else % is zero distractor session - no congruency
        % compute max firing rate around the array normalization period split up by
        % shape condition
        maxArrPeriodRate = max([max(arrSpikeStats.bar.rates(loc,arrTInd))...
                max(arrSpikeStats.bow.rates(loc,arrTInd))...
                max(arrSpikeStats.comb.rates(loc,arrTInd))]);
    end

    % max trial rate is the max of the max of each of the three periods
    maxTrialRates.rateByLoc(loc) = max([maxCuePeriodRate maxDelayPeriodRate maxArrPeriodRate]);
end
