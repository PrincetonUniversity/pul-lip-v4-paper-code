function plotMeanSpdf(areaName, cueT, meanNormCueInRFRate, seNormCueInRFRate, ...
        meanNormCueExRFRate, seNormCueExRFRate, ...
        arrT, meanNormArrInRFRate, seNormArrInRFRate, ...
        meanNormArrExRFRate, seNormArrExRFRate)

%% paper plot
% legend in LIP array onset plot
% xlabel in V4 plot
figure_tr_inch(7, 3);
set(gcf, 'Color', 'white');

%% SPDF aligned to cue onset
subaxis(1, 2, 1, 'ML', 0.15, 'MB', 0.26, 'MT', 0.03, 'SH', 0.04, 'MR', 0.07);
hold on;
plot([0 0], [-1 1], 'k');
plot([-1 1], [0 0], 'k');
jbfill(cueT, meanNormCueInRFRate + seNormCueInRFRate, ...
        meanNormCueInRFRate - seNormCueInRFRate, ...
        [1 0 0], [1 0 0], 1, 0.3);
hold on;
plot(cueT, meanNormCueInRFRate, 'r', 'LineWidth', 3);

jbfill(cueT, meanNormCueExRFRate + seNormCueExRFRate, ...
        meanNormCueExRFRate - seNormCueExRFRate, ...
        [0 0 1], [0 0 1], 1, 0.3);
hold on;
plot(cueT, meanNormCueExRFRate, 'b', 'LineWidth', 3);

if strcmp(areaName, 'V4')
    xlabel('Time from Cue Onset (s)   ');
end
ylabel('Normalized Rate', 'Position', [-1.5 0], 'Units', 'normalized');
set(gca, 'FontSize', 18);
xlim([-0.2 0.3]);
if strcmp(areaName, 'PUL')
    ylim([-0.08 0.22]);
elseif strcmp(areaName, 'V4')
    ylim([-0.07 0.46]);
elseif strcmp(areaName, 'LIP')
    ylim([-0.12 0.36]);
end
box off;

%% SPDF aligned to array onset
subaxis(1, 2, 2);
hold on;

if strcmp(areaName, 'LIP')
    plot([0 0], [-1 0.22], 'k'); % leave room for legend
else
    plot([0 0], [-1 1], 'k');
end

plot([-1 1], [0 0], 'k');
jbfill(arrT, meanNormArrInRFRate + seNormArrInRFRate, ...
        meanNormArrInRFRate - seNormArrInRFRate, ...
        [1 0 0], [1 0 0], 1, 0.3);
hold on;
h1 = plot(arrT, meanNormArrInRFRate, 'r', 'LineWidth', 3);

jbfill(arrT, meanNormArrExRFRate + seNormArrExRFRate, ...
        meanNormArrExRFRate - seNormArrExRFRate, ...
        [0 0 1], [0 0 1], 1, 0.3);
hold on;
h2 = plot(arrT, meanNormArrExRFRate, 'b', 'LineWidth', 3);

if strcmp(areaName, 'LIP')
    l1 = legend([h1 h2], {'Attend RF', 'Attend Away'}, 'box', 'off', 'Color', 'white', 'Position', [0.61 0.82 0.1622 0.1267], 'Units', 'normalized');
end

if strcmp(areaName, 'V4')
    xlabel('     Time from Array Onset (s)');
end
set(gca, 'FontSize', 18);
xlim([-0.3 0.2]);
if strcmp(areaName, 'PUL')
    ylim([-0.08 0.22]);
elseif strcmp(areaName, 'V4')
    ylim([-0.07 0.46]);
elseif strcmp(areaName, 'LIP')
    ylim([-0.12 0.36]);
end
set(gca, 'YTickLabel', []);
box off;