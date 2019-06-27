function [cleanLfpData, outlierTrials] = removeLfpOutliers(origLfpData)
% input: nTime x nTrials
% this is used per cue location and per area

doPrint = 0;
doPlot = 0;

if doPrint
    fprintf('Original: %d\n', size(origLfpData, 2));
end

prevOutlierTrials = -1;
lfpData = origLfpData;

%% trials where abs(lfp) > 1 are wacky and should be removed first
currOutlierTrials = any(abs(origLfpData) > 1, 1); 
if doPrint
    fprintf('\tAfter abs(lfp) > 1 removal: %d\n', size(lfpData, 2) - sum(currOutlierTrials));
end

% iterate until there are no new outlier trials
iterateNum = 0;
while sum(currOutlierTrials) > sum(prevOutlierTrials)
    iterateNum = iterateNum + 1;
    prevOutlierTrials = currOutlierTrials;
    if doPrint
        fprintf('Iteration #%d: %d good trials\n', iterateNum, size(lfpData, 2) - sum(currOutlierTrials));
    end
    
    %% remove trials where the sd within the trial during the window is more
    % than nSDsBadWithin sd's away from the mean sd
    nSDsBadWithin = 3.5;
    lfpData(:,currOutlierTrials) = NaN;

    withinTrialSdLfp = nanstd(lfpData, 0, 1); % 1 x nTrials
    meanWithinTrialSd = nanmean(withinTrialSdLfp);
    sdWithinTrialSd = nanstd(withinTrialSdLfp);

    ubWithinTrialBad = meanWithinTrialSd + nSDsBadWithin * sdWithinTrialSd;
    lbWithinTrialBad = meanWithinTrialSd - nSDsBadWithin * sdWithinTrialSd;

    withinTrialSdOutlierTrials = withinTrialSdLfp < lbWithinTrialBad | ...
            withinTrialSdLfp > ubWithinTrialBad;
    currOutlierTrials = currOutlierTrials | withinTrialSdOutlierTrials;

    if doPrint
        fprintf('\tAfter within trial removal: %d\n', size(lfpData, 2) - sum(currOutlierTrials));
    end

    %% remove trials where the max/min are more
    % than nSDsMinMaxBadWithin sd's away from the mean max/min
    % uses trials that are not outliers as determined earlier
    nSDsMinMaxBadWithin = 4;
    lfpData(:,currOutlierTrials) = NaN;
    
    withinTrialMaxLfp = nanmax(lfpData, [], 1); % 1 x nTrials
    meanWithinTrialMaxSd = nanmean(withinTrialMaxLfp);
    sdWithinTrialMaxSd = nanstd(withinTrialMaxLfp);

    ubWithinTrialMaxBad = meanWithinTrialMaxSd + nSDsMinMaxBadWithin * sdWithinTrialMaxSd;

    withinTrialMaxSdOutlierTrials = withinTrialMaxLfp > ubWithinTrialMaxBad;

    withinTrialMinLfp = nanmin(lfpData, [], 1); % 1 x nTrials
    meanWithinTrialMinSd = nanmean(withinTrialMinLfp);
    sdWithinTrialMinSd = nanstd(withinTrialMinLfp);

    lbWithinTrialMinBad = meanWithinTrialMinSd - nSDsMinMaxBadWithin * sdWithinTrialMinSd;

    withinTrialMinSdOutlierTrials = withinTrialMinLfp < lbWithinTrialMinBad;

    withinTrialMinMaxOutlierTrials = withinTrialMaxSdOutlierTrials | withinTrialMinSdOutlierTrials;
    currOutlierTrials = currOutlierTrials | withinTrialMinMaxOutlierTrials;

    if doPrint
        fprintf('\tAfter within trial min/max removal: %d\n', size(lfpData, 2) - sum(currOutlierTrials));
    end

    %%
    % Outlier trial defined as having 1% of the time
    % window being >= 4.5 SDs away from the mean in either direction
    % uses trials that are not outliers as determined earlier
    % Do a second pass to catch sharp transients
    nSDsBadAcross = 4.5;
    proportionTimeBadAcrossToBeOutlier = 0.01;

    currOutlierTrials = findOutliersSDsBadAcrossForSomeTime(lfpData, ...
            currOutlierTrials, doPrint, nSDsBadAcross, proportionTimeBadAcrossToBeOutlier);
        
    %%
    % Outlier trial defined as having 0.5% of the time
    % window being >= 5 SDs away from the mean in either direction
    % uses trials that are not outliers as determined earlier
    % Do a second pass to catch sharp transients
    nSDsBadAcross = 5;
    proportionTimeBadAcrossToBeOutlier = 0.005;

    currOutlierTrials = findOutliersSDsBadAcrossForSomeTime(lfpData, ...
            currOutlierTrials, doPrint, nSDsBadAcross, proportionTimeBadAcrossToBeOutlier);
  
    %%
    if doPlot
        yScale = 5;
        sevenDefaultLines = lines(7);

        figure_tr_inch(12, 8);
        subaxis(1, 1, 1, 'ML', 0.05, 'MR', 0.02, 'MB', 0.07, 'MT', 0.02);
        set(gcf, 'Color', 'w');
        hold on;
        numPlotted = 1;
        for j = 1:size(origLfpData, 2) % for each trial
            lineStyle = '-';
            lineWidth = 0.5;
            if currOutlierTrials(j)
                lineStyle = '--';
                lineWidth = 1.5;
            end
            plot(origLfpData(:,j) * yScale + numPlotted, 'LineStyle', lineStyle, 'LineWidth', lineWidth);
            text(-0.02, numPlotted+0.3, sprintf('t%d', j), ...
                    'FontSize', 14, 'Color', sevenDefaultLines(mod(numPlotted-1, 7)+1,:), ...
                    'HorizontalAlignment', 'right');
            numPlotted = numPlotted + 1;
        end
        ylim([0 numPlotted]);
        set(gca, 'FontSize', 16);
        set(gca, 'YTickLabel', []);
        set(gca, 'box', 'off');
    end
end

%%
outlierTrials = currOutlierTrials;
cleanLfpData = origLfpData(:, ~outlierTrials);

end

function currOutlierTrials = findOutliersSDsBadAcrossForSomeTime(lfpData, ...
        currOutlierTrials, doPrint, nSDsBadAcross, proportionTimeBadAcrossToBeOutlier)

% Outlier trial defined as having proportionTimeBadToBeOutlierAcross of the time
% window being >= nSDsBadAcross away from the mean in either direction
% uses trials that are not outliers as determined earlier
% lfpData - [samples x trial]

lfpData(:,currOutlierTrials) = NaN;

meanLfp = nanmean(lfpData, 2); % mean across trials
sdLfp = nanstd(lfpData, 0, 2); % sd across trials

ubLfp = meanLfp + nSDsBadAcross * sdLfp;
lbLfp = meanLfp - nSDsBadAcross * sdLfp;

ubLfpMat = repmat(ubLfp, 1, size(lfpData, 2));
lbLfpMat = repmat(lbLfp, 1, size(lfpData, 2));

nTime = size(lfpData, 1);
nTimeBad = sum(lfpData > ubLfpMat | lfpData < lbLfpMat, 1); % -> 1 x nTrials
pTimeBad = nTimeBad / nTime;

timeOutlierTrials = pTimeBad >= proportionTimeBadAcrossToBeOutlier;
currOutlierTrials = currOutlierTrials | timeOutlierTrials;

if doPrint
    fprintf('\tAfter across trial removal: %d\n', size(lfpData, 2) - sum(currOutlierTrials));
end

end