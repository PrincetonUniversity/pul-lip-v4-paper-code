%% setup
clear;
v = 116;

% set up input/output directories
global ENV;
procDataDir = [ENV.homeDir '/firing_rate_analysis/processed_data'];
outputDir = [ENV.homeDir '/firing_rate_analysis/figures'];
dataDir = ENV.dataDir;

fprintf('-------------------------------------------------------------------\n')
fprintf('----- Generating SPDFs and delay period stats for each area (v = %d) -----\n', v);
fprintf('Reading data from dir: %s\n', dataDir);
fprintf('Processed data dir: %s\n', procDataDir);
fprintf('Outputting figures to dir: %s\n', outputDir);
fprintf('\n');

%% loop through areas
areaNames = {'PUL', 'LIP', 'V4'};
for k = 1:numel(areaNames)
    areaName = areaNames{k};
    
    %% create the relevant event and spike time variables, save workspace to file
    startWorkspaceFilePath = sprintf('%s/%s_start_workspace_v%d.mat', procDataDir, areaName, v);
%     preprocessSpikingData(dataDir, areaName, procDataDir, startWorkspaceFilePath, v);
    S = load(startWorkspaceFilePath); 

    %% compute spike stats incl. firing rate in various time windows
    detailedWorkspaceFilePath = sprintf('%s/%s_detailed_workspace_v%d.mat', procDataDir, areaName, v);
%     createSpikeStatsAll(S, 1, detailedWorkspaceFilePath);
    D = load(detailedWorkspaceFilePath, 'spikeStatsAll');

    %% get 5D sessions only
    indices5D = ismember(S.spikeFilesAll, S.spikeFiles5D);
    spikeStats5D = D.spikeStatsAll(indices5D);
    
    %% compute and plot spdfs aligned to cue and array onset
    computeCueArrSpdfsByArea(spikeStats5D, S.spikeFiles5D, areaName, outputDir, v);
    
    %% compute delay period firing rate statistics
    computeDelayPeriodFRStatsByArea(spikeStats5D, S.spikeFiles5D, areaName, outputDir, v);
    
end % area name loop

fprintf('Done.\n');