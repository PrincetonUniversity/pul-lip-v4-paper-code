function preprocessLfpData(dataDir, procDataDir, startWorkspaceFilePath, v)
    
% get the session names for included data
sharedRFs = getLFPSharedRFs();
sessionNames = sharedRFs(:,1);
numSessions = numel(sessionNames);

% create struct holding all important variable names and combinations
eventInfo = createLfpEventInfo();
periCueWindow = eventInfo.eventWindows('AroundCue');
periArrWindow = eventInfo.eventWindows('AroundArr');

minTrialsPerCondition = 4; % if 5, this cuts 55 sessions -> 53: lose C110524 and C110601
inclSessions = false(numSessions, 1);
processedEvokedLfpFiles = cell(numSessions, 1);

totalTimeTic = tic;
for i = 1:numSessions
    sessionName = sharedRFs{i,1};
    if sharedRFs{i,2} == -1
        fprintf('Skipping %s (%d/%d)...\n', sessionName, i, numSessions);
        continue;
    end
    
    perSessionTic = tic;
    fprintf('Processing %s (%d/%d)...\n', sessionName, i, numSessions);
    
    preprocLFP = preprocessEvokedLfp(dataDir, sessionName, periCueWindow, periArrWindow, 0, 0);
    preprocLFP = removeTEOFromPreprocLfp(preprocLFP);

    inRFLoc = sharedRFs{i,2};
    exRFLoc = mod(inRFLoc + 2, 6) + 1; % choose opp loc
    
    numTrialsInRF = size(preprocLFP.postCleanByLoc{inRFLoc}.('AroundArr'),2);
    numTrialsExRF = size(preprocLFP.postCleanByLoc{exRFLoc}.('AroundArr'),2);
    
    if numTrialsInRF < minTrialsPerCondition || numTrialsExRF < minTrialsPerCondition
        fprintf('\tInsufficient number of trials for inclusion in power/coherence analysis.\n');
        continue;
    end
    
    % mark session as included/saved
    inclSessions(i) = 1;
    
    % save preprocessed evoked lfp
    saveFileName = sprintf('%s/%s_processedEvokedLfp_v%d.mat', procDataDir, sessionName, v);
    save(saveFileName, 'sessionName', 'preprocLFP', 'inRFLoc', 'exRFLoc');
    processedEvokedLfpFiles{i} = saveFileName;
    
    perSessionToc = toc(perSessionTic);
    fprintf('\t... done (%dm %ds)\n', round(perSessionToc/60), round(mod(perSessionToc, 60)));
end

% remove skipped sessions
processedEvokedLfpFiles(~inclSessions) = [];
save(startWorkspaceFilePath, 'sharedRFs', 'processedEvokedLfpFiles', 'eventInfo');
fprintf('Saved workspace to %s\n', getFileName(startWorkspaceFilePath));

totalTimeToc = toc(totalTimeTic);
fprintf('Total time: (%dh %dm)\n', round(totalTimeToc/(60*60)), round(mod(totalTimeToc, 60*60)) / 60);
