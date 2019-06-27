function plotSessionAllAreasInExRFLfpMultiTaperCoh(sessionName, isZeroDistractors, ...
        eventInfo, inRFLoc, exRFLoc, saveFile, varargin)

preprocLFP = struct();
cohInRFLowFreq = [];
cohExRFLowFreq = [];
cohInRFHighFreq = [];
cohExRFHighFreq = [];
semCohInRFLowFreq = [];
semCohExRFLowFreq = [];
semCohInRFHighFreq = [];
semCohExRFHighFreq = [];
semCohDiffLowFreq = [];
semCohDiffHighFreq = [];
mtParamsLowFreq = struct();
mtParamsHighFreq = struct();
isVisible = 1;
diffCAxisLim = [-0.4 0.4];
overridedefaults(who, varargin);

if isempty(semCohInRFLowFreq)
    semCohInRFLowFreq = nan(size(cohInRFLowFreq));
    semCohInRFHighFreq = nan(size(cohInRFHighFreq));
end
if isempty(semCohExRFLowFreq)
    semCohExRFLowFreq = nan(size(cohExRFLowFreq));
    semCohExRFHighFreq = nan(size(cohExRFHighFreq));
end
if isempty(semCohDiffLowFreq)
    semCohDiffLowFreq = nan(size(cohInRFLowFreq));
    semCohDiffHighFreq = nan(size(cohInRFHighFreq));
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

cohPlotWScaling = (0.27 - lowHighColSep) / (maxF - minF); % match the mvar width
cohPlotWLowFreq = (mtParamsLowFreq.paramsPost.fpass(2) - minF) * cohPlotWScaling;
cohPlotWHighFreq = (maxF - splitF) * cohPlotWScaling;
cohPlotH = 0.14; 

cohgramHScaling = (0.14 - lowHighRowSep) / (maxF - minF); % match the mvar height
cohgramHLowFreq = (mtParamsLowFreq.paramsPost.fpass(2) - minF) * cohgramHScaling;
cohgramHHighFreq = (maxF - splitF) * cohgramHScaling;

diffCohPlotBtm = 0.07; % "bottom" of plot area
compCohPlotBtm = diffCohPlotBtm + cohPlotH + 0.02;
diffCohgramBtmB = compCohPlotBtm + cohPlotH + 0.09;
diffCohgramBtm = diffCohgramBtmB + cohgramHLowFreq + lowHighRowSep;
exRFCohgramBtmB = diffCohgramBtm + cohgramHHighFreq + highLowRowSep;
exRFCohgramBtm = exRFCohgramBtmB + cohgramHLowFreq + lowHighRowSep;
inRFCohgramBtmB = exRFCohgramBtm + cohgramHHighFreq + highLowRowSep;
inRFCohgramBtm = inRFCohgramBtmB + cohgramHLowFreq + lowHighRowSep;


col1Left = 0.06; % "left" of pulvinar plots
col1bLeft = col1Left + cohPlotWLowFreq + lowHighColSep;
col2Left = col1bLeft + cohPlotWHighFreq + highLowColSep;
col2bLeft = col2Left + cohPlotWLowFreq + lowHighColSep;
col3Left = col2bLeft + cohPlotWHighFreq + highLowColSep;
col3bLeft = col3Left + cohPlotWLowFreq + lowHighColSep;
colorbarLeft = col3bLeft + cohPlotWHighFreq + 0.01;
colorbarW = 0.0133;
colorbarH = 0.1393;

cohPlotWTotal = cohPlotWLowFreq + cohPlotWHighFreq + lowHighColSep;
cohgramW = cohPlotWTotal;
cohgramHTotal = cohgramHLowFreq + cohgramHHighFreq + lowHighRowSep;

inExRFColorbarH = cohgramHTotal*2+highLowRowSep;

cohGramTextX = -0.15;
cohPlotTextX = -mtParamsLowFreq.paramsPost.fpass(2)*0.3/20;

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
assert(size(cohInRFLowFreq,3) == numAreas);

if isempty(cohInRFLowFreq) || isempty(cohExRFLowFreq)
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

modTitle = sprintf('Session %s - All Pairs Multi-Taper Coherence during Delay %s', sessionName, zeroDAppend);
titleParams = {'Interpreter', 'None', 'FontWeight', 'bold'};
title(modTitle, 'FontSize', 15, titleParams{:});

%% plot one coherence pair per column
numPairs = size(cohInRFLowFreq,3);
% cohNFreqBins = mvarParams.cohNFreqBins;

% tInd = 11:51; % plot 
tInd = 11:41; 
% tTmp = (tInd - 41)*0.01 + 0.001;  % time window 41 has center at array onset
tTmp = (tInd - 31)*0.01 + 0.001;  % time window 41 has center at array onset

assert(all(t(tInd) - 0.5 - tTmp < 1e-10));
t = t(tInd) - 0.5;

centerT = -0.15;

fLowInd = fLow >= minF & fLow <= splitF;
fLow = fLow(fLowInd);
fHighInd = fHigh >= splitF & fHigh <= maxF;
fHigh = fHigh(fHighInd);

cohInRFLowFreqAtTInd = cohInRFLowFreq(tInd,fLowInd,:);
cohExRFLowFreqAtTInd = cohExRFLowFreq(tInd,fLowInd,:);
cohInRFHighFreqAtTInd = cohInRFHighFreq(tInd,fHighInd,:);
cohExRFHighFreqAtTInd = cohExRFHighFreq(tInd,fHighInd,:);
maxC = max([max(cohInRFLowFreqAtTInd(:)) max(cohExRFLowFreqAtTInd(:)) ...
       max(cohInRFHighFreqAtTInd(:)) max(cohExRFHighFreqAtTInd(:))]);
maxDiffC = max([cohInRFLowFreqAtTInd(:)-cohExRFLowFreqAtTInd(:); ...
        cohInRFHighFreqAtTInd(:)-cohExRFHighFreqAtTInd(:)]);
minDiffC = min([cohInRFLowFreqAtTInd(:)-cohExRFLowFreqAtTInd(:); ...
        cohInRFHighFreqAtTInd(:)-cohExRFHighFreqAtTInd(:)]);

% tWindowInd = 31; % time window [-198 to 0] ms from array onset
tWindowInd = 21; % time window [-298 to 0] ms from array onset for 300ms window
cohInRFLowFreqAtWindowInd = cohInRFLowFreq(tWindowInd,fLowInd,:);
cohExRFLowFreqAtWindowInd = cohExRFLowFreq(tWindowInd,fLowInd,:);
cohInRFHighFreqAtWindowInd = cohInRFHighFreq(tWindowInd,fHighInd,:);
cohExRFHighFreqAtWindowInd = cohExRFHighFreq(tWindowInd,fHighInd,:);
maxCAtWindowInd = max([max(cohInRFLowFreqAtWindowInd(:)) max(cohExRFLowFreqAtWindowInd(:)) ...
        max(cohInRFHighFreqAtWindowInd(:)) max(cohExRFHighFreqAtWindowInd(:))]);
maxDiffCAtWindowInd = max([cohInRFLowFreqAtWindowInd(:)-cohExRFLowFreqAtWindowInd(:); ...
        cohInRFHighFreqAtWindowInd(:)-cohExRFHighFreqAtWindowInd(:)]);
minDiffCAtWindowInd = min([cohInRFLowFreqAtWindowInd(:)-cohExRFLowFreqAtWindowInd(:); ...
        cohInRFHighFreqAtWindowInd(:)-cohExRFHighFreqAtWindowInd(:)]);

for i = 1:numPairs
    addYLabel = 0;
    addColorbar = 0;
    addLegend = 0;
    addRowLabel = 0;
    if i == 1 
        leftLowFreq = col2Left;
        leftHighFreq = col2bLeft;
        cohPairName = 'Pulvinar-LIP';
    elseif i == 2
        leftLowFreq = col1Left;
        leftHighFreq = col1bLeft;
        cohPairName = 'Pulvinar-V4';
        addYLabel = 1;
        addRowLabel = 1;
    elseif i == 3
        leftLowFreq = col3Left;
        leftHighFreq = col3bLeft;
        cohPairName = 'V4-LIP';
        addColorbar = 1;
        addLegend = 1;
    end
    
    cohInRFLowFreqOnePair = squeeze(cohInRFLowFreq(:,:,i));
    cohExRFLowFreqOnePair = squeeze(cohExRFLowFreq(:,:,i));
    cohInRFHighFreqOnePair = squeeze(cohInRFHighFreq(:,:,i));
    cohExRFHighFreqOnePair = squeeze(cohExRFHighFreq(:,:,i));
    semCohInRFLowFreqOnePair = squeeze(semCohInRFLowFreq(:,:,i));
    semCohExRFLowFreqOnePair = squeeze(semCohExRFLowFreq(:,:,i));
    semCohInRFHighFreqOnePair = squeeze(semCohInRFHighFreq(:,:,i));
    semCohExRFHighFreqOnePair = squeeze(semCohExRFHighFreq(:,:,i));
    semCohDiffLowFreqOnePair = squeeze(semCohDiffLowFreq(:,:,i));
    semCohDiffHighFreqOnePair = squeeze(semCohDiffHighFreq(:,:,i));
    diffCohLowFreqOnePair = cohInRFLowFreqOnePair - cohExRFLowFreqOnePair;
    diffCohHighFreqOnePair = cohInRFHighFreqOnePair - cohExRFHighFreqOnePair;
    
    
    %% 1) inRF coherogram high freq
    axInRFCohgramHighFreqBigPos = [leftLowFreq inRFCohgramBtm cohgramW cohgramHHighFreq];
    axInRFCohgramHighFreqBig = axes('Position', axInRFCohgramHighFreqBigPos);
    
    imagesc(t, fHigh, cohInRFHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fHigh)], 'k-'); % plot line at center of delay period
    caxis([0 maxC]);
    
    set(get(axInRFCohgramHighFreqBig, 'Title'), 'Visible', 'on')
    title(cohPairName, 'FontSize', 13, titleParams{:});
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 1b) inRF coherogram low freq
    axInRFCohgramLowFreqBigPos = [leftLowFreq inRFCohgramBtmB cohgramW cohgramHLowFreq];
    axInRFCohgramLowFreqBig = axes('Position', axInRFCohgramLowFreqBigPos);
    
    imagesc(t, fLow, cohInRFLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fLow)], 'k-'); % plot line at center of delay period
    caxis([0 maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    axInRFCohgramAllFreqBigPos = [leftLowFreq inRFCohgramBtmB cohgramW cohgramHTotal];
    axInRFCohgramAllFreqBig = axes('Position', axInRFCohgramAllFreqBigPos, 'Visible', 'off');
    set(get(axInRFCohgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axInRFCohgramAllFreqBig, 'Frequency (Hz)');
        
        if addRowLabel
            text(cohGramTextX, 0.5, 0, 'InRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [1 0 0]);
        end
    else
        ylabel(axInRFCohgramAllFreqBig, '');
        set(axInRFCohgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 2) exRF coherogram high freq
    axExRFCohgramHighFreqBigPos = [leftLowFreq exRFCohgramBtm cohgramW cohgramHHighFreq];
    axExRFCohgramHighFreqBig = axes('Position', axExRFCohgramHighFreqBigPos);
    
    imagesc(t, fHigh, cohExRFHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fHigh)], 'k-'); % plot line at center of delay period
    caxis([0 maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 2b) exRF coherogram low freq
    axExRFCohgramLowFreqBigPos = [leftLowFreq exRFCohgramBtmB cohgramW cohgramHLowFreq];
    axExRFCohgramLowFreqBig = axes('Position', axExRFCohgramLowFreqBigPos);
    
    imagesc(t, fLow, cohExRFLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fLow)], 'k-'); % plot line at center of delay period
    caxis([0 maxC]);
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    if addColorbar
        axInExRFCohgramBigColorH = colorbar('Position', [colorbarLeft axExRFCohgramLowFreqBigPos(2) colorbarW inExRFColorbarH]);
        ylabel(axInExRFCohgramBigColorH, 'Coherence', 'Rotation', 270, ...
                'Units', 'Normalized', 'Position', [3.3 0.5 0]); % colorbar label
        set(axExRFCohgramLowFreqBig, 'Position', axExRFCohgramLowFreqBigPos); % expand plot to full size
    end;
    
    axExRFCohgramAllFreqBigPos = [leftLowFreq exRFCohgramBtmB cohgramW cohgramHTotal];
    axExRFCohgramAllFreqBig = axes('Position', axExRFCohgramAllFreqBigPos, 'Visible', 'off');
    set(get(axExRFCohgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axExRFCohgramAllFreqBig, 'Frequency (Hz)');
        if addRowLabel
            text(cohGramTextX, 0.5, 0, 'ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [0 0 1]);
        end
    else
        ylabel(axExRFCohgramAllFreqBig, ''); 
        set(axExRFCohgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 3) difference coherogram
    axDiffCohgramHighFreqBigPos = [leftLowFreq diffCohgramBtm cohgramW cohgramHHighFreq];
    axDiffCohgramHighFreqBig = axes('Position', axDiffCohgramHighFreqBigPos);
    
    imagesc(t, fHigh, diffCohHighFreqOnePair(tInd,fHighInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fHigh)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fHigh)], 'k-'); % plot line at center of delay period
%     caxis([minDiffC maxDiffC]);
    caxis(diffCAxisLim)
    colormap(axDiffCohgramHighFreqBig, getCoolWarmMap());
    
    addXLabel = 0;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickHighFreq);
    
    %% 3b) difference coherogram low freq
    axDiffCohgramLowFreqBigPos = [leftLowFreq diffCohgramBtmB cohgramW cohgramHLowFreq];
    axDiffCohgramLowFreqBig = axes('Position', axDiffCohgramLowFreqBigPos);
    
    imagesc(t, fLow, diffCohLowFreqOnePair(tInd,fLowInd)')
    set(gca,'YDir','normal');
    hold on;
    plot([0 0], [0 max(fLow)], 'k-', 'LineWidth', 2); % plot line at window with center at array onset
    plot([centerT centerT], [0 max(fLow)], 'k-'); % plot line at center of delay period
%     caxis([minDiffC maxDiffC]);
    caxis(diffCAxisLim)
    colormap(axDiffCohgramLowFreqBig, getCoolWarmMap());
    
    addXLabel = 1;
    if addXLabel
        xlabel('Time (s)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    set(gca, 'YTick', yTickLowFreq);
    
    if addColorbar
        axDiffCohgramBigColorH = colorbar('Position', [colorbarLeft axDiffCohgramLowFreqBigPos(2) colorbarW cohgramHTotal]);
        ylabel(axDiffCohgramBigColorH, 'Coherence Diff', 'Rotation', 270, ...
                'Units', 'Normalized', 'Position', [3.3 0.5 0]); % colorbar label
        set(axDiffCohgramLowFreqBig, 'Position', axDiffCohgramLowFreqBigPos); % expand plot to full size
    end

    axDiffCohgramAllFreqBigPos = [leftLowFreq diffCohgramBtmB cohgramW cohgramHTotal];
    axDiffCohgramAllFreqBig = axes('Position', axDiffCohgramAllFreqBigPos, 'Visible', 'off');
    set(get(axDiffCohgramAllFreqBig, 'YLabel'), 'Visible', 'on')
    if addYLabel
        ylabel(axDiffCohgramAllFreqBig, 'Frequency (Hz)');
        if addRowLabel
            text(cohGramTextX, 0.5, 0, 'InRF-ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
                    'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                    'Color', [0.4 0.2 0.6]);
        end
    else
        ylabel(axDiffCohgramAllFreqBig, ''); 
        set(axDiffCohgramAllFreqBig, 'YTickLabel', '');
    end
    
    %% 4) inRF vs exRF coherence at time window right before array onset low freq
    axCompCohPlotLowFreqBig = axes('Position', [leftLowFreq compCohPlotBtm cohPlotWLowFreq cohPlotH]);
    
    hold on;
    plot(fLow, cohInRFLowFreqOnePair(tWindowInd,fLowInd), 'Color', [1 0 0]); % red: inRF
    plot(fLow, cohExRFLowFreqOnePair(tWindowInd,fLowInd), 'Color', [0 0 1]); % blue: exRF
    
    if any(~isnan(semCohInRFLowFreqOnePair))
        fillH = jbfill(fLow, cohInRFLowFreqOnePair(tWindowInd,fLowInd) + semCohInRFLowFreqOnePair(tWindowInd,fLowInd), ...
                cohInRFLowFreqOnePair(tWindowInd,fLowInd) - semCohInRFLowFreqOnePair(tWindowInd,fLowInd), [1 0.8 0.8], [1 0.8 0.8], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    if any(~isnan(semCohExRFLowFreqOnePair))
        fillH = jbfill(fLow, cohExRFLowFreqOnePair(tWindowInd,fLowInd) + semCohExRFLowFreqOnePair(tWindowInd,fLowInd), ...
            cohExRFLowFreqOnePair(tWindowInd,fLowInd) - semCohExRFLowFreqOnePair(tWindowInd,fLowInd), [0.8 0.8 1], [0.8 0.8 1], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
    xlim([0 max(fLow)]);
    ylim([0 maxCAtWindowInd]);
    addXLabel = 0;
    if addXLabel
        xlabel('Frequency (Hz)'); 
    else
        xlabel(''); set(gca, 'XTickLabel', '');
    end
    if addYLabel
        axCompCohPlotYH = ylabel('Coherence', 'Units', 'Normalized');
        axCompCohPlotYLabelPos = get(axCompCohPlotYH, 'Position');
    else
        ylabel(''); set(gca, 'YTickLabel', '');
    end
    
    if addRowLabel
        text(cohPlotTextX, 0.25, 0, 'InRF', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [1 0 0]);
        text(cohPlotTextX, 0.45, 0, ',', 'Units', 'Normalized', 'Rotation', 90, ...
                'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
                'Color', [0 0 0]);
        text(cohPlotTextX, 0.75, 0, 'ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
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
    
    axCompCohPlotAllFreqBig = axes('Position', [leftLowFreq compCohPlotBtm cohPlotWTotal cohPlotH], 'Visible', 'off');
    set(get(axCompCohPlotAllFreqBig, 'Title'), 'Visible', 'on')
    title('300ms window pre-array (t=-0.15)', titleParams{:});
    
    %% 4b) inRF vs exRF coherence at time window right before array onset high freq
    axCompCohPlotHighFreqBig = axes('Position', [leftHighFreq compCohPlotBtm cohPlotWHighFreq cohPlotH]);
    
    hold on;
    plot(fHigh, cohInRFHighFreqOnePair(tWindowInd,fHighInd), 'Color', [1 0 0]); % red: inRF
    plot(fHigh, cohExRFHighFreqOnePair(tWindowInd,fHighInd), 'Color', [0 0 1]); % blue: exRF

    if any(~isnan(semCohInRFHighFreqOnePair))
        fillH = jbfill(fHigh, cohInRFHighFreqOnePair(tWindowInd,fHighInd) + semCohInRFHighFreqOnePair(tWindowInd,fHighInd), ...
            cohInRFHighFreqOnePair(tWindowInd,fHighInd) - semCohInRFHighFreqOnePair(tWindowInd,fHighInd), [1 0.8 0.8], [1 0.8 0.8], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    if any(~isnan(semCohExRFHighFreqOnePair))
        fillH = jbfill(fHigh, cohExRFHighFreqOnePair(tWindowInd,fHighInd) + semCohExRFHighFreqOnePair(tWindowInd,fHighInd), ...
            cohExRFHighFreqOnePair(tWindowInd,fHighInd) - semCohExRFHighFreqOnePair(tWindowInd,fHighInd), [0.8 0.8 1], [0.8 0.8 1], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
    xlim([min(fHigh) max(fHigh)]);
    ylim([0 maxCAtWindowInd]);
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
    axDiffCohPlotLowFreqBig = axes('Position', [leftLowFreq diffCohPlotBtm cohPlotWLowFreq cohPlotH]);
    
    hold on;
    plot(fLow, diffCohLowFreqOnePair(tWindowInd,fLowInd), 'Color', [0.4 0.2 0.6]);
    plot([0 max(fLow)], [0 0], '--', 'Color', 0.5*ones(3,1));
    box('off');
    
    if any(~isnan(semCohDiffLowFreqOnePair))
        fillH = jbfill(fLow, diffCohLowFreqOnePair(tWindowInd,fLowInd) + semCohDiffLowFreqOnePair(tWindowInd,fLowInd), ...
            diffCohLowFreqOnePair(tWindowInd,fLowInd) - semCohDiffLowFreqOnePair(tWindowInd,fLowInd), [0.5 0.35 0.6], [0.5 0.35 0.6], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
    xlim([0 max(fLow)]);
    ylim([minDiffCAtWindowInd maxDiffCAtWindowInd]);
    addXLabel = 1;

    if addYLabel
        axDiffCohPlotYH = ylabel('Coherence Diff', 'Units', 'Normalized');
        set(axDiffCohPlotYH, 'Position', axCompCohPlotYLabelPos); % use position of above plot
    else
        ylabel(''); set(gca, 'YTickLabel', '');
    end
    
    if addRowLabel
        text(cohPlotTextX, 0.5, 0, 'InRF-ExRF', 'Units', 'Normalized', 'Rotation', 90, ...
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
    
    axDiffCohPlotAllFreqBig = axes('Position', [leftLowFreq diffCohPlotBtm cohPlotWTotal cohPlotH], 'Visible', 'off');
    set(get(axDiffCohPlotAllFreqBig, 'XLabel'), 'Visible', 'on')
    if addXLabel
        xlabel(axDiffCohPlotAllFreqBig, 'Frequency (Hz)'); 
    else
        xlabel(axDiffCohPlotAllFreqBig, ''); 
        set(axDiffCohPlotAllFreqBig, 'XTickLabel', '');
    end
    
    %% 5b) difference coherence with error bars high freq
    axDiffCohPlotHighFreqBig = axes('Position', [leftHighFreq diffCohPlotBtm cohPlotWHighFreq cohPlotH]);
    
    hold on;
    plot(fHigh, diffCohHighFreqOnePair(tWindowInd,fHighInd), 'Color', [0.4 0.2 0.6]);
    plot([0 max(fHigh)], [0 0], '--', 'Color', 0.5*ones(3,1));
    box('off');
    
    if any(~isnan(semCohDiffHighFreqOnePair))
        fillH = jbfill(fHigh, diffCohHighFreqOnePair(tWindowInd,fHighInd) + semCohDiffHighFreqOnePair(tWindowInd,fHighInd), ...
            diffCohHighFreqOnePair(tWindowInd,fHighInd) - semCohDiffHighFreqOnePair(tWindowInd,fHighInd), [0.5 0.35 0.6], [0.5 0.35 0.6], 1, 0.5);
        uistack(fillH, 'bottom');
    end
    
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
