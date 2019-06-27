function computeMultiTaperPowerCoherence(procDataDir, figureDir, startWorkspaceFileName, v)

Fs = 1000;

% tapers: TW=1 and T=0.2sec so W(half-bandwidth)=5Hz, so resolution bandwidth = [-5,5]Hz
paramsLowFreq.fpass = [5 30];
paramsLowFreq.pad = 3;
paramsLowFreq.tapers = [2 3]; 
paramsLowFreq.trialave = 1;
paramsLowFreq.Fs = Fs;

% tapers: TW=2 and T=0.2sec so W(half-bandwidth)=10Hz, so resolution bandwidth = [-10,10]Hz
% ideally a larger T is used so that more tapers and a smaller resolution bandwidth can be used
paramsHighFreq.fpass = [30 100];
paramsHighFreq.tapers = [3 5]; 
paramsHighFreq.pad = 2;
paramsHighFreq.trialave = 1;
paramsHighFreq.Fs = Fs;

% load sessions with preprocessed evoked lfps
L = load(startWorkspaceFileName, 'processedEvokedLfpFiles', 'eventInfo');
numInclSessions = numel(L.processedEvokedLfpFiles);

powSaveFiles = cell(numInclSessions, 1);
cohSaveFiles = cell(numInclSessions, 1);

totalTimeTic = tic;
for i = 1:numInclSessions
    perSessionTic = tic;
    EL = load(L.processedEvokedLfpFiles{i}, 'sessionName', 'preprocLFP', 'inRFLoc', 'exRFLoc');
    fprintf('Processing %s (%d/%d)...\n', EL.sessionName, i, numInclSessions);
    
    % multi-taper coherence and power around array onset for InRF
    [mtCohInRFLowFreq,mtTCohInRFLowFreq,mtPowerInRFLowFreq,mtParamsLowFreq] = computePairCoherenceMultiTaper(...
            EL.preprocLFP.postCleanByLoc, EL.inRFLoc, 'AroundArr', paramsLowFreq);
    [mtCohInRFHighFreq,mtTCohInRFHighFreq,mtPowerInRFHighFreq,mtParamsHighFreq] = computePairCoherenceMultiTaper(...
            EL.preprocLFP.postCleanByLoc, EL.inRFLoc, 'AroundArr', paramsHighFreq);
        
    % multi-taper coherence and power around array onste for ExRF
    [mtCohExRFLowFreq,mtTCohExRFLowFreq,mtPowerExRFLowFreq,mtParamsLowFreq2] = computePairCoherenceMultiTaper(...
            EL.preprocLFP.postCleanByLoc, EL.exRFLoc, 'AroundArr', paramsLowFreq);
    [mtCohExRFHighFreq,mtTCohExRFHighFreq,mtPowerExRFHighFreq,mtParamsHighFreq2] = computePairCoherenceMultiTaper(...
            EL.preprocLFP.postCleanByLoc, EL.exRFLoc, 'AroundArr', paramsHighFreq);
    assert(isequal(mtParamsLowFreq,mtParamsLowFreq2));
    assert(isequal(mtParamsHighFreq,mtParamsHighFreq2));
    
    % save analysis results
    saveFileName = sprintf('%s/%s_lfpMTCohPow_v%d.mat', procDataDir, EL.sessionName, v);
    save(saveFileName, ...
            'mtCohInRFLowFreq', 'mtTCohInRFLowFreq', 'mtPowerInRFLowFreq', ...
            'mtCohInRFHighFreq', 'mtTCohInRFHighFreq', 'mtPowerInRFHighFreq', ...
            'mtCohExRFLowFreq', 'mtTCohExRFLowFreq', 'mtPowerExRFLowFreq', ...
            'mtCohExRFHighFreq', 'mtTCohExRFHighFreq', 'mtPowerExRFHighFreq', ...
            'mtParamsLowFreq', 'mtParamsHighFreq');
   
    % plot power in delay period
    saveFileName = sprintf('%s/%s_mtPowerAll_delayInExRF_v%d.pdf', figureDir, EL.sessionName, v);
    plotSessionAllAreasInExRFLfpMultiTaperPower(EL.sessionName, 0, ...
            L.eventInfo, EL.inRFLoc, EL.exRFLoc, saveFileName, 'preprocLFP', EL.preprocLFP, ...
            'powerInRFLowFreq', mtPowerInRFLowFreq, ...
            'powerExRFLowFreq', mtPowerExRFLowFreq, ...
            'powerInRFHighFreq', mtPowerInRFHighFreq, ...
            'powerExRFHighFreq', mtPowerExRFHighFreq, ...
            'mtParamsLowFreq', mtParamsLowFreq, ...
            'mtParamsHighFreq', mtParamsHighFreq, ...
            'isVisible', 0);
    powSaveFiles{i} = saveFileName;
    
    % plot coherence in delay period
    saveFileName = sprintf('%s/%s_mtCohAll_delayInExRF_v%d.pdf', figureDir, EL.sessionName, v);
    plotSessionAllAreasInExRFLfpMultiTaperCoh(EL.sessionName, 0, ...
            L.eventInfo, EL.inRFLoc, EL.exRFLoc, saveFileName, 'preprocLFP', EL.preprocLFP, ...
            'cohInRFLowFreq', mtTCohInRFLowFreq, ...
            'cohExRFLowFreq', mtTCohExRFLowFreq, ...
            'cohInRFHighFreq', mtTCohInRFHighFreq, ...
            'cohExRFHighFreq', mtTCohExRFHighFreq, ...
            'mtParamsLowFreq', mtParamsLowFreq, ...
            'mtParamsHighFreq', mtParamsHighFreq, ...
            'isVisible', 0);
    cohSaveFiles{i} = saveFileName;

    perSessionToc = toc(perSessionTic);
    fprintf('\t... done (%dm %ds)\n', round(perSessionToc/60), round(mod(perSessionToc, 60)));
end

% combine the pdfs
fprintf('Combining PDFs into one...\n');
deleteAndAppendPdfs(sprintf('%s/mtPowerAll_delayInExRF_v%d.pdf', figureDir, v), powSaveFiles);
deleteAndAppendPdfs(sprintf('%s/mtCohAll_delayInExRF_v%d.pdf', figureDir, v), cohSaveFiles);
fprintf('\t... done\n');

totalTimeToc = toc(totalTimeTic);
fprintf('Total time: (%dh %dm)\n', round(totalTimeToc/(60*60)), round(mod(totalTimeToc, 60*60)) / 60);

