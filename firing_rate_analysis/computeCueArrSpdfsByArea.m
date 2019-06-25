function computeCueArrSpdfsByArea(spikeStats5D, spikeFiles5D, areaName, outputDir, v)

fprintf('---------------- Creating cue-locked and array-locked SPDFs for area %s (v = %d) ----------------\n', areaName, v);

%% get manual RF choices
rfChoicesFileName = [lower(areaName) '_rf_choices.csv'];
[rfcSession,rfcCellID,rfcInRF,rfcExRF,rfcQuality,~,~,~] = readCellRFChoices(...
        rfChoicesFileName);
fprintf('Loaded RF choices from %s (%d cells)\n', rfChoicesFileName, numel(rfcCellID));

%% get RFs per session
inRFLocs = nan(numel(spikeStats5D), 1);
exRFLocs = nan(numel(spikeStats5D), 1);
for i = 1:numel(spikeStats5D)
    spikeFileName = getFileName(spikeFiles5D{i});
    sessionName = spikeFileName(1:7);
    cellID = spikeFileName(12:13);

    rfcMatch = find(strcmp(sessionName, rfcSession) & ...
            strcmp(cellID, rfcCellID));
    assert(length(rfcMatch) == 1);

    if rfcQuality(rfcMatch) >= 1
        inRFLocs(i) = rfcInRF(rfcMatch);
        exRFLocs(i) = rfcExRF(rfcMatch);
    end
end
fprintf('RFs selected for %d/%d sessions.\n', ...
        sum(~isnan(inRFLocs)), numel(spikeStats5D));

%% exclude these sessions
excludedSessions = {'C110727_sig3b_5D'};

%% compute population psth, combined bar/bow con/incon
% aligned to cue
cueT = spikeStats5D{1}.cueSpikeStats.t;
cueResponseRatesInRFNorm = nan(numel(spikeStats5D), numel(cueT));
cueResponseRatesExRFNorm = nan(numel(spikeStats5D), numel(cueT));

% aligned to array
arrT = spikeStats5D{1}.arrSpikeStats.t;
arrResponseRatesInRFNorm = nan(numel(spikeStats5D), numel(arrT));
arrResponseRatesExRFNorm = nan(numel(spikeStats5D), numel(arrT));

% for each 5D session where the preferred cue location could be determined
% and there are more than the minimum number of trials at the preferred and
% nonpreferred cue locations, 
% compute the normalized firing rate for pref & nonpref locations over the cue 
% period
numSessionsUsed = 0;
for i = 1:numel(spikeStats5D)
    spikeFileName = getFileName(spikeFiles5D{i});
    
    % skip excluded sessions
    if any(ismember(excludedSessions, spikeFileName(1:16)))
        fprintf('Special case: Skipping %s\n', spikeFileName);
        continue;
    end

    % skip sessions without a specified RF
    if isnan(inRFLocs(i))
        sessionName = spikeFileName(1:7);
        cellID = spikeFileName(12:13);
        fprintf('No matching RF choice for session %s, cell %s\n', sessionName, cellID);
        continue;
    end

    % response_norm = (response - baseline) / (max - baseline)
    % then when response == max, response_norm = 1
    % and when response == baseline, response_norm = 0

    maxTrialRate = max(spikeStats5D{i}.maxTrialRates.rateByLoc([inRFLocs(i) exRFLocs(i)]));
    baselineRatesInRF = spikeStats5D{i}.averageSPDFFiringRates.preCueBaselineByLoc(inRFLocs(i));
    baselineRatesExRF = spikeStats5D{i}.averageSPDFFiringRates.preCueBaselineByLoc(exRFLocs(i));

    cueResponseRatesInRF = spikeStats5D{i}.cueSpikeStats.comb.rates(inRFLocs(i),:);
    cueResponseRatesExRF = spikeStats5D{i}.cueSpikeStats.comb.rates(exRFLocs(i),:);
    cueResponseRatesInRFNorm(i,:) = (cueResponseRatesInRF - baselineRatesInRF) / (maxTrialRate - baselineRatesInRF);
    cueResponseRatesExRFNorm(i,:) = (cueResponseRatesExRF - baselineRatesExRF) / (maxTrialRate - baselineRatesExRF);

    arrResponseRatesInRF = spikeStats5D{i}.arrSpikeStats.comb.rates(inRFLocs(i),:);
    arrResponseRatesExRF = spikeStats5D{i}.arrSpikeStats.comb.rates(exRFLocs(i),:);
    arrResponseRatesInRFNorm(i,:) = (arrResponseRatesInRF - baselineRatesInRF) / (maxTrialRate - baselineRatesInRF);
    arrResponseRatesExRFNorm(i,:) = (arrResponseRatesExRF - baselineRatesExRF) / (maxTrialRate - baselineRatesExRF);

    numSessionsUsed = numSessionsUsed + 1;
end

cueRowsToRemove = all(isnan(cueResponseRatesInRFNorm), 2) | all(isnan(cueResponseRatesExRFNorm), 2);
cueResponseRatesInRFNorm(cueRowsToRemove,:) = [];
cueResponseRatesExRFNorm(cueRowsToRemove,:) = [];
fprintf('Excluded %d/%d sessions from cue SPDF.\n', sum(cueRowsToRemove), numel(spikeStats5D));

meanNormCueInRFRate = mean(cueResponseRatesInRFNorm);
meanNormCueExRFRate = mean(cueResponseRatesExRFNorm);

seNormCueInRFRate = std(cueResponseRatesInRFNorm) / (sqrt(size(cueResponseRatesInRFNorm, 1)));
seNormCueExRFRate = std(cueResponseRatesExRFNorm) / (sqrt(size(cueResponseRatesExRFNorm, 1)));

arrRowsToRemove = all(isnan(arrResponseRatesInRFNorm), 2) | all(isnan(arrResponseRatesExRFNorm), 2);
arrResponseRatesInRFNorm(arrRowsToRemove,:) = [];
arrResponseRatesExRFNorm(arrRowsToRemove,:) = [];
fprintf('Excluded %d/%d sessions from array plot.\n', sum(arrRowsToRemove), numel(spikeStats5D));

meanNormArrInRFRate = mean(arrResponseRatesInRFNorm);
meanNormArrExRFRate = mean(arrResponseRatesExRFNorm);

seNormArrInRFRate = std(arrResponseRatesInRFNorm) / sqrt(size(arrResponseRatesInRFNorm, 1));
seNormArrExRFRate = std(arrResponseRatesExRFNorm) / sqrt(size(arrResponseRatesExRFNorm, 1));

%% paper plot
fprintf('Plotting SPDF for %s (N=%d)...\n', areaName, numel(spikeStats5D));
plotMeanCueArrSpdf(areaName, cueT, meanNormCueInRFRate, seNormCueInRFRate, ...
        meanNormCueExRFRate, seNormCueExRFRate, ...
        arrT, meanNormArrInRFRate, seNormArrInRFRate, ...
        meanNormArrExRFRate, seNormArrExRFRate)

%% save
plotFileName = sprintf('%s/%s_pop_psth_cueArrAligned_inRFVsExRF_bc_n%d_paper_v%d.png', ...
        outputDir, lower(areaName), numSessionsUsed, v);
export_fig(plotFileName, '-nocrop');

%% vector paper plot
fprintf('Plotting SPDF for %s (N=%d)...\n', areaName, numel(spikeStats5D));
plotMeanCueArrSpdfVector(areaName, cueT, meanNormCueInRFRate, seNormCueInRFRate, ...
        meanNormCueExRFRate, seNormCueExRFRate, ...
        arrT, meanNormArrInRFRate, seNormArrInRFRate, ...
        meanNormArrExRFRate, seNormArrExRFRate)

%% save
plotFileName = sprintf('%s/%s_pop_psth_cueArrAligned_inRFVsExRF_bc_n%d_paper_v%d.eps', ...
        outputDir, lower(areaName), numSessionsUsed, v);
export_fig(plotFileName, '-nocrop');

%% vector paper plot
fprintf('Plotting SPDF for %s (N=%d)...\n', areaName, numel(spikeStats5D));
plotMeanCueArrSpdfVectorShade(areaName, cueT, meanNormCueInRFRate, seNormCueInRFRate, ...
        meanNormCueExRFRate, seNormCueExRFRate, ...
        arrT, meanNormArrInRFRate, seNormArrInRFRate, ...
        meanNormArrExRFRate, seNormArrExRFRate)

%% save
plotFileName = sprintf('%s/%s_pop_psth_cueArrAligned_inRFVsExRF_bc_n%d_paper_shade_v%d.png', ...
        outputDir, lower(areaName), numSessionsUsed, v);
export_fig(plotFileName, '-nocrop');