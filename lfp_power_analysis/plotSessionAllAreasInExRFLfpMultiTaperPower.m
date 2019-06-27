function plotSessionAllAreasInExRFLfpMultiTaperCoh(sessionName, isZeroDistractors, ...
        eventInfo, inRFLoc, exRFLoc, saveFile, varargin)

preprocLFP = struct();
powerInRFLowFreq = [];
powerExRFLowFreq = [];
powerInRFHighFreq = [];
powerExRFHighFreq = [];
semPowerInRFLowFreq = [];
semPowerExRFLowFreq = [];
semPowerInRFHighFreq = [];
semPowerExRFHighFreq = [];
mtParamsLowFreq = struct();
mtParamsHighFreq = struct();
isVisible = 1;
overridedefaults(who, varargin);

if isempty(semPowerInRFLowFreq)
    semPowerInRFLowFreq = nan(size(powerInRFLowFreq));
    semPowerInRFHighFreq = nan(size(powerInRFHighFreq));
end
if isempty(semPowerExRFLowFreq)
    semPowerExRFLowFreq = nan(size(powerExRFLowFreq));
    semPowerExRFHighFreq = nan(size(powerExRFHighFreq));
end

figure_tr_inch(16,8); clf;
set(gcf, 'Color', 'white');
% set(gcf, 'InvertHardCopy','off');
set(gcf, 'Renderer', 'painters');
set(gcf, 'Visible', 'off');

%% location params

minF = 5;
maxF = 70;
splitF = mtParamsLowFreq.paramsPost.fpass(2);

yTickLowFreq = [6 15 30];
yTickHighFreq = [40 60];

lowHighRowSep = 0.005;
highLowRowSep = 0.02;

lowHighColSep = 0.005;
highLowColSep = 0.03;

specPlotWScaling = (0.27 - lowHighColSep) / (maxF - minF); % match the mvar width
specPlotWLowFreq = (mtParamsLowFreq.paramsPost.fpass(2) - minF) * specPlotWScaling;
specPlotWHighFreq = (maxF - splitF) * specPlotWScaling;
specPlotH = 0.14; 

specgramHScaling = (0.14 - lowHighRowSep) / (maxF - minF); % match the mvar height
specgramHLowFreq = (mtParamsLowFreq.paramsPost.fpass(2) - minF) * specgramHScaling;
specgramHHighFreq = (maxF - splitF) * specgramHScaling;

diffSpecPlotBtm = 0.07; % "bottom" of plot area
compSpecPlotBtm = diffSpecPlotBtm + specPlotH + 0.02;
diffSpecgramBtmB = compSpecPlotBtm + specPlotH + 0.09;
diffSpecgramBtm = diffSpecgramBtmB + specgramHLowFreq + lowHighRowSep;
exRFSpecgramBtmB = diffSpecgramBtm + specgramHHighFreq + highLowRowSep;
exRFSpecgramBtm = exRFSpecgramBtmB + specgramHLowFreq + lowHighRowSep;
inRFSpecgramBtmB = exRFSpecgramBtm + specgramHHighFreq + highLowRowSep;
inRFSpecgramBtm = inRFSpecgramBtmB + specgramHLowFreq + lowHighRowSep;

col1Left = 0.06; % "left" of pulvinar plots
col1bLeft = col1Left + specPlotWLowFreq + lowHighColSep;
col2Left = col1bLeft + specPlotWHighFreq + highLowColSep;
col2bLeft = col2Left + specPlotWLowFreq + lowHighColSep;
col3Left = col2bLeft + specPlotWHighFreq + highLowColSep;
col3bLeft = col3Left + specPlotWLowFreq + lowHighColSep;
colorbarLeft = col3bLeft + specPlotWHighFreq + 0.01;
colorbarW = 0.0133;
colorbarH = 0.1393;

specPlotWTotal = specPlotWLowFreq + specPlotWHighFreq + lowHighColSep;
specgramW = specPlotWTotal;
specgramHTotal = specgramHLowFreq + specgramHHighFreq + lowHighRowSep;

inExRFColorbarH = specgramHTotal*2+highLowRowSep;

specGramTextX = -0.15;
specPlotTextX = -mtParamsLowFreq.paramsPost.fpass(2)*0.3/20;

%% get data
% load(lfpFile);

%%
% load('params.mat');
% [sessionName, areaName] = getInfoFromLfpFile(lfpFile);

% indices depend on what areas get processed in
% computePreprocessedEvokedLfpWholeSession()
numAreas = 3;

% TODO: check that these match the windows used if preprocLFP exists
% periCueWindow = eventInfo.eventWindows('AroundCue');
% periArrWindow = eventInfo.eventWindows('AroundArr');
% if isempty(preprocLFP)
% %     preprocLFP = computePreprocessedEvokedLfpWholeSession(...
% %             sessionName, 0, periCueWindow, periArrWindow);
% end;
assert(size(powerInRFLowFreq,3) == numAreas);

if isempty(powerInRFLowFreq) || isempty(powerExRFLowFreq)
%     [cohInRF,~,mvarParams] = computePairCoherenceMVAR(preprocLFP.postCleanByLoc, inRFLoc, 'AroundArr');
%     [cohExRF,~,mvarParams2] = computePairCoherenceMVAR(preprocLFP.postCleanByLoc, exRFLoc, 'AroundArr');
%     assert(isequal(mvarParams,mvarParams2));
%     clear mvarParams2;
end
assert(all(mtParamsLowFreq.t == mtParamsHighFreq.t));
t = mtParamsLowFreq.t;
fLow = mtParamsLowFreq.f;
fHigh = mtParamsHighFreq.f;

%% make main title
axBig = axes('Position', [0.04 0.045 0.92 0.91], 'Visible', 'off');
set(get(axBig,'Title'), 'Visible', 'on')

% format: Session L110524, LIP Neuron B (140 trials)
zeroDAppend = '';
if isZeroDistractors
    zeroDAppend = ' (0 Distractors)'; 
end

modTitle = sprintf('Session %s - All Pairs Multi-Taper Power during Delay %s', sessionName, zeroDAppend);
titleParams = {'Interpreter', 'None', 'FontWeight', 'bold'};
title(modTitle, 'FontSize', 15, titleParams{:});

%% plot one coherence pair per column
assert(size(powerInRFLowFreq,3) == numAreas);

% cohNFreqBins = mvarParams.cohNFreqBins;

% tInd = 11:51; % plot for 200ms window
tInd = 11:41; % plot for 300ms window
% tTmp = (tInd - 41)*0.01 + 0.001;  % time window 41 has center at array
% onset for 200ms window
tTmp = (tInd - 31)*0.01 + 0.001;  % time window 31 has center at array onset for 300ms window

assert(all(t(tInd) - 0.5 - tTmp < 1e-10));
t = t(tInd) - 0.5;

fLowInd = fLow >= minF & fLow <= splitF;
fLow = fLow(fLowInd);
fHighInd = fHigh >= splitF & fHigh <= maxF;
fHigh = fHigh(fHighInd);

powerInRFLowFreqAtTInd = 10*log10(powerInRFLowFreq(tInd,fLowInd,:));
powerExRFLowFreqAtTInd = 10*log10(powerExRFLowFreq(tInd,fLowInd,:));
powerInRFHighFreqAtTInd = 10*log10(powerInRFHighFreq(tInd,fHighInd,:));
powerExRFHighFreqAtTInd = 10*log10(powerExRFHighFreq(tInd,fHighInd,:));
maxC = max([max(powerInRFLowFreqAtTInd(:)) max(powerExRFLowFreqAtTInd(:)) ...
       max(powerInRFHighFreqAtTInd(:)) max(powerExRFHighFreqAtTInd(:))]);
minC = min([min(powerInRFLowFreqAtTInd(:)) min(powerExRFLowFreqAtTInd(:)) ...
       min(powerInRFHighFreqAtTInd(:)) min(powerExRFHighFreqAtTInd(:))]);
maxDiffC = max([powerInRFLowFreqAtTInd(:)-powerExRFLowFreqAtTInd(:); ...
        powerInRFHighFreqAtTInd(:)-powerExRFHighFreqAtTInd(:)]);
minDiffC = min([powerInRFLowFreqAtTInd(:)-powerExRFLowFreqAtTInd(:); ...
        powerInRFHighFreqAtTInd(:)-powerExRFHighFreqAtTInd(:)]);

tWindowInd = 31; % time window [-198 to 0] ms from array onset
powerInRFLowFreqAtWindowInd = 10*log10(powerInRFLowFreq(tWindowInd,fLowInd,:));
powerExRFLowFreqAtWindowInd = 10*log10(powerExRFLowFreq(tWindowInd,fLowInd,:));
powerInRFHighFreqAtWindowInd = 10*log10(powerInRFHighFreq(tWindowInd,fHighInd,:));
powerExRFHighFreqAtWindowInd = 10*log10(powerExRFHighFreq(tWindowInd,fHighInd,:));
maxCAtWindowInd = max([max(powerInRFLowFreqAtWindowInd(:)) max(powerExRFLowFreqAtWindowInd(:)) ...
        max(powerInRFHighFreqAtWindowInd(:)) max(powerExRFHighFreqAtWindowInd(:))]);
minCAtWindowInd = min([min(powerInRFLowFreqAtWindowInd(:)) min(powerExRFLowFreqAtWindowInd(:)) ...
        min(powerInRFHighFreqAtWindowInd(:)) min(powerExRFHighFreqAtWindowInd(:))]);
maxDiffCAtWindowInd = max([powerInRFLowFreqAtWindowInd(:)-powerExRFLowFreqAtWindowInd(:); ...
        powerInRFHighFreqAtWindowInd(:)-powerExRFHighFreqAtWindowInd(:)]);
minDiffCAtWindowInd = min([powerInRFLowFreqAtWindowInd(:)-powerExRFLowFreqAtWindowInd(:); ...
        powerInRFHighFreqAtWindowInd(:)-powerExRFHighFreqAtWindowInd(:)]);

for i = 1:numAreas
    addYLabel = 0;
    addColorbar = 0;
    addRowLabel = 0;
    if i == 1
        leftLowFreq = col1Left;
        leftHighFreq = col1bLeft;
        areaName = 'Pulvinar';
        addYLabel = 1;
        addRowLabel = 1;
    elseif i == 2
        leftLowFreq = col3Left;
        leftHighFreq = col3bLeft;
        areaName = 'LIP';
        addColorbar = 1;
    elseif i == 3
        leftLowFreq = col2Left;
        leftHighFreq = col2bLeft;
        areaName = 'V4';
    end
    
    powInRFLowFreqOnePair = 10*log10(squeeze(powerInRFLowFreq(:,:,i)));
    powExRFLowFreqOnePair = 10*log10(squeeze(powerExRFLowFreq(:,:,i)));
    powInRFHighFreqOnePair = 10*log10(squeeze(powerInRFHighFreq(:,:,i)));
    powExRFHighFreqOnePair = 10*log10(squeeze(powerExRFHighFreq(:,:,i)));
    semPowInRFLowFreqOnePair = 10*log10(squeeze(semPowerInRFLowFreq(:,:,i)));
    semPowExRFLowFreqOnePair = 10*log10(squeeze(semPowerExRFLowFreq(:,:,i)));
    semPowInRFHighFreqOnePair = 10*log10(squeeze(semPowerInRFHighFreq(:,:,i)));
    semPowExRFHighFreqOnePair = 10*log10(squeeze(semPowerExRFHighFreq(:,:,i)));
    diffPowLowFreqOnePair = powInRFLowFreqOnePair - powExRFLowFreqOnePair;
    diffPowHighFreqOnePair = powInRFHighFreqOnePair - powExRFHighFreqOnePair;
    
    
    %% 1) inRF coherogram high freq
    axInRFSpecgramHighFreqBigPos = [leftLowFreq inRFSpecgramBtm specgramW specgramHHighFreq];
    axInRFSpecgramHighFreqBig = axes('Position', axInRFSpecgramHighFreqBigPos);
    
    imagesc(t, fHigh, powInRFHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fHigh)], 'k-'); % plot line at center of delay period
    caxis([minC maxC]);
    
    set(get(axInRFSpecgramHighFreqBig, 'Title'), 'Visible', 'on')
    title(areaName, 'FontSize', 13, titleParams{:});
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 1b) inRF coherogram low freq
    axInRFSpecgramLowFreqBigPos = [leftLowFreq inRFSpecgramBtmB specgramW specgramHLowFreq];
    axInRFSpecgramLowFreqBig = axes('Position', axInRFSpecgramLowFreqBigPos);
    
    imagesc(t, fLow, powInRFLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fLow)], 'k-'); % plot line at center of delay period
    caxis([minC maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    axInRFSpecgramAllFreqBigPos = [leftLowFreq inRFSpecgramBtmB specgramW specgramHTotal];
    axInRFSpecgramAllFreqBig = axes('Position', axInRFSpecgramAllFreqBigPos, 'Visible', 'off');
    set(get(axInRFSpecgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axInRFSpecgramAllFreqBig, 'Frequency (Hz)');
        
        if addRowLabel
            text(specGramTextX, 0.5, 0, 'InRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [1 0 0]);
        end
    else
        ylabel(axInRFSpecgramAllFreqBig, '');
        set(axInRFSpecgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 2) exRF coherogram high freq
    axExRFSpecgramHighFreqBigPos = [leftLowFreq exRFSpecgramBtm specgramW specgramHHighFreq];
    axExRFSpecgramHighFreqBig = axes('Position', axExRFSpecgramHighFreqBigPos);
    
    imagesc(t, fHigh, powExRFHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fHigh)], 'k-'); % plot line at center of delay period
    caxis([minC maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 2b) exRF coherogram low freq
    axExRFSpecgramLowFreqBigPos = [leftLowFreq exRFSpecgramBtmB specgramW specgramHLowFreq];
    axExRFSpecgramLowFreqBig = axes('Position', axExRFSpecgramLowFreqBigPos);
    
    imagesc(t, fLow, powExRFLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fLow)], 'k-'); % plot line at center of delay period
    caxis([minC maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    if addColorbar
        axInExRFSpecgramBigColorH = colorbar('Position', [colorbarLeft axExRFSpecgramLowFreqBigPos(2) colorbarW inExRFColorbarH]);
        ylabel(axInExRFSpecgramBigColorH, 'Power (dB)', 'Rotation', 270, ...
                'Units', 'Normalized', 'Position', [3.3 0.5 0]); % colorbar label
        set(axExRFSpecgramLowFreqBig, 'Position', axExRFSpecgramLowFreqBigPos); % expand plot to full size
    end;
    
    axExRFSpecgramAllFreqBigPos = [leftLowFreq exRFSpecgramBtmB specgramW specgramHTotal];
    axExRFSpecgramAllFreqBig = axes('Position', axExRFSpecgramAllFreqBigPos, 'Visible', 'off');
    set(get(axExRFSpecgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axExRFSpecgramAllFreqBig, 'Frequency (Hz)');
        if addRowLabel
            text(specGramTextX, 0.5, 0, 'ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [0 0 1]);
        end
    else
        ylabel(axExRFSpecgramAllFreqBig, ''); 
        set(axExRFSpecgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 3) difference coherogram
    axDiffSpecgramHighFreqBigPos = [leftLowFreq diffSpecgramBtm specgramW specgramHHighFreq];
    axDiffSpecgramHighFreqBig = axes('Position', axDiffSpecgramHighFreqBigPos);
    
    imagesc(t, fHigh, diffPowHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fHigh)], 'k-'); % plot line at center of delay period
    caxis([minDiffC maxDiffC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 3b) difference coherogram low freq
    axDiffSpecgramLowFreqBigPos = [leftLowFreq diffSpecgramBtmB specgramW specgramHLowFreq];
    axDiffSpecgramLowFreqBig = axes('Position', axDiffSpecgramLowFreqBigPos);
    
    imagesc(t, fLow, diffPowLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([-0.1 -0.1], [0 max(fLow)], 'k-'); % plot line at center of delay period
    caxis([minDiffC maxDiffC]);
    
    addXLabel = 1;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    if addColorbar
        axDiffSpecgramBigColorH = colorbar('Position', [colorbarLeft axDiffSpecgramLowFreqBigPos(2) colorbarW specgramHTotal]);
        ylabel(axDiffSpecgramBigColorH, 'Power Diff (dB)', 'Rotation', 270, ...
                'Units', 'Normalized', 'Position', [3.3 0.5 0]); % colorbar label
        set(axDiffSpecgramLowFreqBig, 'Position', axDiffSpecgramLowFreqBigPos); % expand plot to full size
    end

    axDiffSpecgramAllFreqBigPos = [leftLowFreq diffSpecgramBtmB specgramW specgramHTotal];
    axDiffSpecgramAllFreqBig = axes('Position', axDiffSpecgramAllFreqBigPos, 'Visible', 'off');
    set(get(axDiffSpecgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axDiffSpecgramAllFreqBig, 'Frequency (Hz)');
        if addRowLabel
            text(specGramTextX, 0.5, 0, 'InRF-ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [0.4 0.2 0.6]);
        end
    else
        ylabel(axDiffSpecgramAllFreqBig, ''); 
        set(axDiffSpecgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 4) inRF vs exRF coherence at time window right before array onset low freq
    axCompSpecPlotLowFreqBig = axes('Position', [leftLowFreq compSpecPlotBtm specPlotWLowFreq specPlotH]);
    
    hold on;
    plot(fLow, powInRFLowFreqOnePair(tWindowInd,fLowInd), 'Color', [1 0 0]); % red: inRF
    plot(fLow, powExRFLowFreqOnePair(tWindowInd,fLowInd), 'Color', [0 0 1]); % blue: exRF
    
    if any(~isnan(semPowInRFLowFreqOnePair))
        fillH = jbfill(fLow, powInRFLowFreqOnePair(tWindowInd,fLowInd) + semPowInRFLowFreqOnePair(tWindowInd,fLowInd), ...
                powInRFLowFreqOnePair(tWindowInd,fLowInd) - semPowInRFLowFreqOnePair(tWindowInd,fLowInd), [1 0.8 0.8], [1 0.8 0.8], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    if any(~isnan(semPowExRFLowFreqOnePair))
        fillH = jbfill(fLow, powExRFLowFreqOnePair(tWindowInd,fLowInd) + semPowExRFLowFreqOnePair(tWindowInd,fLowInd), ...
                powExRFLowFreqOnePair(tWindowInd,fLowInd) - semPowExRFLowFreqOnePair(tWindowInd,fLowInd), [0.8 0.8 1], [0.8 0.8 1], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
    xlim([0 max(fLow)]);
    ylim([minCAtWindowInd maxCAtWindowInd]);
    addXLabel = 0;
    if addXLabel
        xlabel('Frequency (Hz)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    if addYLabel
        axCompSpecPlotYH = ylabel('Power (dB)', 'Units', 'Normalized');
        axCompSpecPlotYLabelPos = get(axCompSpecPlotYH, 'Position');
    else
        ylabel(''); set(gca, 'YTickLabel', '');
    end
    
    if addRowLabel
        text(specPlotTextX, 0.25, 0, 'InRF', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [1 0 0]);
        text(specPlotTextX, 0.45, 0, ',', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [0 0 0]);
        text(specPlotTextX, 0.75, 0, 'ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [0 0 1]);
    end
    % make the grid
    % note that setting YColor to background color above also affects the
    % grid color so we have to manually draw the grid
%     grid('on');
%     grid('minor');
    addManualGrid(gca);
    
    % make sure x and y axes show up dark
    set(gca, 'Layer', 'top');
%     xl = xlim();
%     yl = ylim();
%     plot(xl, [yl(1) yl(1)], 'k-');
%     plot([xl(1) xl(1)], yl, 'k-');
    
    axCompCohPlotAllFreqBig = axes('Position', [leftLowFreq compSpecPlotBtm specPlotWTotal specPlotH], 'Visible', 'off');
    set(get(axCompCohPlotAllFreqBig, 'Title'), 'Visible', 'on')
    title('200ms window pre-array (t=-0.1)', titleParams{:});
    
    %% 4b) inRF vs exRF coherence at time window right before array onset high freq
    axCompSpecPlotHighFreqBig = axes('Position', [leftHighFreq compSpecPlotBtm specPlotWHighFreq specPlotH]);
    
    hold on;
    plot(fHigh, powInRFHighFreqOnePair(tWindowInd,fHighInd), 'Color', [1 0 0]); % red: inRF
    plot(fHigh, powExRFHighFreqOnePair(tWindowInd,fHighInd), 'Color', [0 0 1]); % blue: exRF

    if any(~isnan(semPowInRFHighFreqOnePair))
        fillH = jbfill(fHigh, powInRFHighFreqOnePair(tWindowInd,fHighInd) + semPowInRFHighFreqOnePair(tWindowInd,fHighInd), ...
                powInRFHighFreqOnePair(tWindowInd,fHighInd) - semPowInRFHighFreqOnePair(tWindowInd,fHighInd), [1 0.8 0.8], [1 0.8 0.8], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    if any(~isnan(semPowExRFHighFreqOnePair))
        fillH = jbfill(fHigh, powExRFHighFreqOnePair(tWindowInd,fHighInd) + semPowExRFHighFreqOnePair(tWindowInd,fHighInd), ...
                powExRFHighFreqOnePair(tWindowInd,fHighInd) - semPowExRFHighFreqOnePair(tWindowInd,fHighInd), [0.8 0.8 1], [0.8 0.8 1], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
    xlim([min(fHigh) max(fHigh)]);
    ylim([minCAtWindowInd maxCAtWindowInd]);
    addXLabel = 0;
    if addXLabel
        xlabel('Frequency (Hz)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    
    set(gca, 'YTickLabel', '');
    set(gca, 'YColor', get(gca, 'Color'))

    % make the grid
    % note that setting YColor to background color above also affects the
    % grid color so we have to manually draw the grid
%     grid('on');
%     grid('minor');
    addManualGrid(gca);
    
    % make sure x and y axes show up dark
    set(gca, 'Layer', 'top');
%     xl = xlim();
%     yl = ylim();
%     plot(xl, [yl(1) yl(1)], 'k-');
%     plot([xl(1) xl(1)], yl, 'k-');
    
    %% 5) difference coherence with error bars low freq
    axDiffSpecPlotLowFreqBig = axes('Position', [leftLowFreq diffSpecPlotBtm specPlotWLowFreq specPlotH]);
    
    hold on;
    plot(fLow, diffPowLowFreqOnePair(tWindowInd,fLowInd), 'Color', [0.4 0.2 0.6]);
    plot([0 max(fLow)], [0 0], '--', 'Color', 0.5*ones(3,1));
    box('off');
    
    xlim([0 max(fLow)]);
    ylim([minDiffCAtWindowInd maxDiffCAtWindowInd]);
    addXLabel = 1;

    if addYLabel
        axDiffSpecPlotYH = ylabel('Power Diff (dB)', 'Units', 'Normalized');
        set(axDiffSpecPlotYH, 'Position', axCompSpecPlotYLabelPos); % use position of above plot
    else
        ylabel(''); set(gca, 'YTickLabel', '');
    end
    
    if addRowLabel
        text(specPlotTextX, 0.5, 0, 'InRF-ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [0.4 0.2 0.6]);
    end
    
    % make the grid
    % note that setting YColor to background color above also affects the
    % grid color so we have to manually draw the grid
%     grid('on');
%     grid('minor');
    addManualGrid(gca);
    
    % make sure x and y axes show up dark
    set(gca, 'Layer', 'top');
%     xl = xlim();
%     yl = ylim();
%     plot(xl, [yl(1) yl(1)], 'k-');
%     plot([xl(1) xl(1)], yl, 'k-');
    
    axDiffSpecPlotAllFreqBig = axes('Position', [leftLowFreq diffSpecPlotBtm specPlotWTotal specPlotH], 'Visible', 'off');
    set(get(axDiffSpecPlotAllFreqBig, 'XLabel'), 'Visible', 'on')
    if addXLabel
        xlabel(axDiffSpecPlotAllFreqBig, 'Frequency (Hz)'); 
    else
        xlabel(axDiffSpecPlotAllFreqBig, ''); 
        set(axDiffSpecPlotAllFreqBig, 'XTickLabel', '');
    end
    
    %% 5b) difference coherence with error bars high freq
    axDiffSpecPlotHighFreqBig = axes('Position', [leftHighFreq diffSpecPlotBtm specPlotWHighFreq specPlotH]);
    
    hold on;
    plot(fHigh, diffPowHighFreqOnePair(tWindowInd,fHighInd), 'Color', [0.4 0.2 0.6]);
    plot([0 max(fHigh)], [0 0], '--', 'Color', 0.5*ones(3,1));
    box('off');
    
    xlim([min(fHigh) max(fHigh)]);
    ylim([minDiffCAtWindowInd maxDiffCAtWindowInd]);

    set(gca, 'YTickLabel', '');
    set(gca, 'YColor', get(gca, 'Color'))
    
    % make the grid
    % note that setting YColor to background color above also affects the
    % grid color so we have to manually draw the grid
%     grid('on');
%     grid('minor');
    addManualGrid(gca);
    
    % make sure x and y axes show up dark
    set(gca, 'Layer', 'top');
%     xl = xlim();
%     yl = ylim();
%     plot(xl, [yl(1) yl(1)], 'k-');
%     plot([xl(1) xl(1)], yl, 'k-');
    
end

%% save
if isVisible
    set(gcf, 'Visible', 'on');
end
if ~isempty(saveFile)
    % note: running export_fig in parfor loop leads to cut off figs
	export_fig(saveFile, '-nocrop', '-r300');
end
if ~isVisible
    close;
end
