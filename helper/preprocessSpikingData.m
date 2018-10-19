function preprocessSpikingData(dataDir, areaName, procDataDir, startWorkspaceFilePath, v)
% create vars: eventInfo, spikeFilesAll, spikeFiles5D, spikeFiles0D, spikeFiles5D0D
doOverwriteSpikeFiles = 1;

% get the names of the sessions that have spikes and have data for both the
% 5D and 0D conditions
[fiveDSessionNames, zeroDfiveDSessionNames] = getSpikeSessionNames(areaName);

% create struct holding all important variable names and combinations
eventInfo = createSpikeEventInfo();

spikeFilesAll = {};
spikeFiles0D = {};
spikeFiles5D0D = {}; % hold all file names for cells that have both 5D and 0D data

% process only the 5D session data first
for i = 1:numel(fiveDSessionNames)
    sessionName = fiveDSessionNames{i};
    currSpikeFiles = createSpikeVars(dataDir, sessionName, ...
            areaName, eventInfo, doOverwriteSpikeFiles, 0, procDataDir, v);
    % concatenate to list of spike file names
    spikeFilesAll = [spikeFilesAll currSpikeFiles]; %#ok<AGROW> 
end

spikeFiles5D = spikeFilesAll;

% process the 0D and 5D session data
for i = 1:numel(zeroDfiveDSessionNames)
    sessionName = zeroDfiveDSessionNames{i};
    currSpikeFiles5D = createSpikeVars(dataDir, sessionName, ...
            areaName, eventInfo, doOverwriteSpikeFiles, 0, procDataDir, v);
    spikeFilesAll = [spikeFilesAll currSpikeFiles5D]; %#ok<AGROW> 
    spikeFiles5D = [spikeFiles5D currSpikeFiles5D]; %#ok<AGROW> 
    
    currSpikeFiles0D = createSpikeVars(dataDir, sessionName, ...
            areaName, eventInfo, doOverwriteSpikeFiles, 1, procDataDir, v);
    spikeFilesAll = [spikeFilesAll currSpikeFiles0D]; %#ok<AGROW> 
    spikeFiles0D = [spikeFiles0D currSpikeFiles0D]; %#ok<AGROW> 
    spikeFiles5D0D = [spikeFiles5D0D currSpikeFiles5D currSpikeFiles0D]; %#ok<AGROW> 
end

% sort to make it a little easier to process later
spikeFilesAll = sort(spikeFilesAll);
spikeFiles5D = sort(spikeFiles5D);
spikeFiles0D = sort(spikeFiles0D);
spikeFiles5D0D = sort(spikeFiles5D0D);

fprintf('Done creating spike vars.\n');

fprintf('spikeFilesAll: %d files\n', numel(spikeFilesAll));
fprintf('spikeFiles5D: %d files\n', numel(spikeFiles5D));
fprintf('spikeFiles0D: %d files\n', numel(spikeFiles0D));
fprintf('spikeFiles5D0D: %d files\n', numel(spikeFiles5D0D));

% clean up
clear i fiveDSessionNames zeroDfiveDSessionNames skipFiles sessionName ...
        currSpikeFiles currSpikeFiles5D currSpikeFiles0D doLoad ...
        doOverwriteSpikeFiles;

save(startWorkspaceFilePath);
fprintf('Saved workspace to %s\n', getFileName(startWorkspaceFilePath));
