function plotMeanCueArrSpdfVectorShade(areaName, cueT, meanNormCueInRFRate, seNormCueInRFRate, ...
        meanNormCueExRFRate, seNormCueExRFRate, ...
        arrT, meanNormArrInRFRate, seNormArrInRFRate, ...
        meanNormArrExRFRate, seNormArrExRFRate)

%% paper plot
% legend in LIP array onset plot
% xlabel in V4 plot
figure_tr_inch(7, 3);
clf;
set(gcf, 'Color', 'white');
set(gcf, 'renderer', 'painters');

cueW = 0.44 * 0.4/0.5; % scaled for axis length
arrW = 0.44;
spdfH = 0.69;

btm = 0.26;
cueLeft = 0.13;
arrLeft = cueLeft + cueW + 0.04;

%% SPDF aligned to cue onset
axes('Position', [cueLeft btm cueW spdfH]);
hold on;

jbfill(cueT, meanNormCueInRFRate + seNormCueInRFRate, ...
        meanNormCueInRFRate - seNormCueInRFRate, ...
        [1 0 0], [1 0 0], 1, 0.3);
hold on;

jbfill(cueT, meanNormCueExRFRate + seNormCueExRFRate, ...
        meanNormCueExRFRate - seNormCueExRFRate, ...
        [0 0 1], [0 0 1], 1, 0.3);
hold on;

xlim([-0.1 0.3]);
if strcmp(areaName, 'PUL')
    ylim([-0.08 0.22]);
elseif strcmp(areaName, 'V4')
    ylim([-0.07 0.47]);
elseif strcmp(areaName, 'LIP')
    ylim([-0.12 0.36]);
end
box off;
set(gca, 'Visible', 'off');

%% SPDF aligned to array onset
axes('Position', [arrLeft btm arrW spdfH]);
hold on;

jbfill(arrT, meanNormArrInRFRate + seNormArrInRFRate, ...
        meanNormArrInRFRate - seNormArrInRFRate, ...
        [1 0 0], [1 0 0], 1, 0.3);
hold on;

jbfill(arrT, meanNormArrExRFRate + seNormArrExRFRate, ...
        meanNormArrExRFRate - seNormArrExRFRate, ...
        [0 0 1], [0 0 1], 1, 0.3);
hold on;

xlim([-0.3 0.2]);
if strcmp(areaName, 'PUL')
    ylim([-0.08 0.22]);
elseif strcmp(areaName, 'V4')
    ylim([-0.07 0.47]);
elseif strcmp(areaName, 'LIP')
    ylim([-0.12 0.36]);
end
box off;
set(gca, 'Visible', 'off');
