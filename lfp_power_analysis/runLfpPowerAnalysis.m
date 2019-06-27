%% setup
clear;
v = 101;

% set up input/output directories
global ENV;
procDataDir = ENV.lfpPowProcDataDir;
figureDir = ENV.lfpPowFigDir;
dataDir = ENV.dataDir;

fprintf('-------------------------------------------------------------------\n')
fprintf('----- Processing LFPs and computing delay period power spectra for each area (v = %d) -----\n', v);
fprintf('Reading data from dir: %s\n', dataDir);
fprintf('Processed data dir: %s\n', procDataDir);
fprintf('Outputting figures to dir: %s\n', figureDir);
fprintf('\n');

%% create the relevant event and spike time variables, save workspace to file
startWorkspaceFileName = sprintf('%s/lfp_start_workspace_v%d.mat', procDataDir, v);
preprocessLfpData(dataDir, procDataDir, startWorkspaceFileName, v);
computeMultiTaperPowerCoherence(procDataDir, figureDir, startWorkspaceFileName, v)

fprintf('Done.\n');