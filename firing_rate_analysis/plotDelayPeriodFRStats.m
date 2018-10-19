function plotDelayPeriodFRStats(delayRatesInRFNorm, delayRatesExRFNorm, ...
        PTTest, PSignRank, delayWindowOffset, areaName, outputDir, v)
%%
delayRatesDiffNorm = delayRatesInRFNorm - delayRatesExRFNorm;
meanDiffNormRate = mean(delayRatesDiffNorm);
seDiffNormRate = std(delayRatesDiffNorm) / sqrt(numel(delayRatesDiffNorm));
medianDiffNormRate = median(delayRatesDiffNorm);

%%
figure_tr_inch(6, 6);
set(gcf, 'Color', 'white');
xBounds = [-0.4 0.6];

%%
subaxis(2, 1, 1, 'ML', 0.12, 'MB', 0.12, 'MT', 0.08, 'SV', 0.1);
hold on;
plot([0 0], [0 2], 'k', 'LineWidth', 2);
plot(delayRatesDiffNorm, ones(size(delayRatesDiffNorm)), 'o')
plot([meanDiffNormRate meanDiffNormRate], [0 2], 'r', 'LineWidth', 2);
% plot([medianDiffNormRate medianDiffNormRate], [0 2], 'g');
plot([meanDiffNormRate - 2*seDiffNormRate meanDiffNormRate - 2*seDiffNormRate], [0 2], 'g--'); % 2 SE bars
plot([meanDiffNormRate + 2*seDiffNormRate meanDiffNormRate + 2*seDiffNormRate], [0 2], 'g--'); % 2 SE bars
boxplot(delayRatesDiffNorm, 'Orientation', 'horizontal')
xlim(xBounds);
title(sprintf('%s Delay InRF-ExRF Norm (N=%d)', areaName, numel(delayRatesExRFNorm)));
set(gca, 'YTickLabel', {});
set(gca, 'FontSize', 16);

labelText = {sprintf('delay window offset: [%0.2f, %0.2f] s', delayWindowOffset), ...
        sprintf('range diff rate: [%0.2f, %0.2f] au', min(delayRatesDiffNorm), max(delayRatesDiffNorm)), ...
        sprintf('mean diff rate (red): %0.4f au', meanDiffNormRate), ...
        sprintf('median diff rate: %0.4f au', medianDiffNormRate), ...
        sprintf('se diff rate: %0.4f au', seDiffNormRate)};
text(0.05, 0.02, labelText, 'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'bottom');

labelText = {sprintf('t-test p-value: %0.3f', PTTest), ...
        sprintf('sign-rank p-value: %0.3f', PSignRank)};
text(0.65, 0.02, labelText, 'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'bottom');

%%
subaxis(2, 1, 2);
hold on;
histogram(delayRatesDiffNorm, xBounds(1):0.025:xBounds(2));
xlim(xBounds);
origYLim = ylim();
plot([meanDiffNormRate meanDiffNormRate], origYLim, 'r', 'LineWidth', 2);
plot([0 0], origYLim, 'k', 'LineWidth', 2);
ylim(origYLim);
set(gca, 'FontSize', 16);
xlabel('Difference in Normalized Firing Rate');
ylabel('Number of Cells');
% TODO: the x axis lengths are different and thus misaligned

%% save
plotFileName = sprintf('%s/%s_pop_delayDiffNorm_bc_n%d_v%d.png', ...
        outputDir, lower(areaName), numel(delayRatesInRFNorm), v);
export_fig(plotFileName, '-nocrop');

%% scatter plot of delay period firing rate InRF vs ExRF
figure_tr_inch(6, 6);
subaxis(1, 1, 1, 'ML', 0.14, 'MB', 0.12, 'MT', 0.08);
H = plot(delayRatesInRFNorm, delayRatesExRFNorm, 'o');
xlabel('Delay InRF response firing rate - bc, norm (Hz)');
ylabel('Delay ExRF response firing rate - bc, norm (Hz)');
title(sprintf('%s Delay InRF vs ExRF (BC, Norm, N=%d)', areaName, numel(delayRatesInRFNorm)));
hold on;
currXLim = xlim();
currYLim = ylim();
minLim = min(currXLim(1), currYLim(1));
maxLim = max(currXLim(2), currYLim(2));
plot([minLim maxLim], [minLim maxLim], '-');
plot([0 0], [-1 1], 'k');
plot([-1 1], [0 0], 'k');
xlim([minLim maxLim]);
ylim([minLim maxLim]);
set(gca, 'FontSize', 16);

labelText = {sprintf('delay window offset: [%0.2f, %0.2f] s', delayWindowOffset), ...
        sprintf('inrf rate range: [%0.2f, %0.2f]', min(delayRatesInRFNorm), max(delayRatesInRFNorm)), ...
        sprintf('exrf rate range: [%0.2f, %0.2f]', min(delayRatesExRFNorm), max(delayRatesExRFNorm))};
text(0.6, 0.02, labelText, 'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'bottom');

%% save
plotFileName = sprintf('%s/%s_pop_delayInRFVsExRF_bc_norm_n%d_v%d.png', ...
        outputDir, lower(areaName), numel(delayRatesInRFNorm), v);
export_fig(plotFileName, '-nocrop');