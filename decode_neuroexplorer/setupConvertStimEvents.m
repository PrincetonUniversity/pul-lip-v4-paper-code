% Decode the stimlus events from NeuroExplorer for all sessions

clear
fprintf('\n--------------------------------------------------------\n')

origDir = pwd;

[dataDir, ~, sessionNames, ~, ~, hasLfpSessionNames, hasSpikesSessionNames] = getUsableSessionNames();

allSessionNamesToProcess = union(hasSpikesSessionNames, hasLfpSessionNames);
disp(allSessionNamesToProcess);

% decode stimulus events one by one
for j = 1:numel(allSessionNamesToProcess)
    sessionName = allSessionNamesToProcess{j};

    fprintf('Normalizing data structures for session %s (%d/%d)...',...
        sessionName, j, numel(allSessionNamesToProcess));
    normalizeDataStructures([dataDir sessionName]);
    fprintf(' done\n');
    
    fprintf('Decoding stimulus events for session %s (%d/%d)...',...
            sessionName, j, numel(allSessionNamesToProcess));
    convertStimEventsSingleSession(dataDir, sessionName);
    fprintf(' done\n');
end

cd(origDir); % return to original directory

