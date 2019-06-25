% run this function from the project root directory to set up the PATH and
% ENV variable for later use in navigating directory structures and create
% processed data directories
function setup()

%% add appropriate project dirs to the path
addpath(genpath(fullfile(pwd, 'chronux/spectral_analysis')));
addpath(genpath(fullfile(pwd, 'chronux_supp')));
addpath(genpath(fullfile(pwd, 'helper')));
addpath(genpath(fullfile(pwd, 'util')));
addpath(fullfile(pwd, 'firing_rate_analysis'));
addpath(fullfile(pwd, 'firing_rate_analysis/compute_spike_stats'));
addpath(fullfile(pwd, 'cell_rf_choices'));

fprintf('Path variable is now set.\n');

%% set global ENV variable - a convenient evil...
global ENV; % write "global ENV" to use this var in other scopes
ENV.homeDir = pwd;
ENV.dataDir = [pwd '/../klab_data/']; % CHANGE ME AS NEEDED

% ENV.lfpAnalysisDir = [ENV.homeDir 'lfp_analysis\'];
% ENV.lfpProcDataDir = [ENV.lfpAnalysisDir 'processed_data\'];
% 
% ENV.spikeAnalysisDir = [ENV.homeDir 'spike_analysis\'];
% ENV.spikeProcDataDir = [ENV.spikeAnalysisDir 'processed_data\'];
% 
% ENV.spikeLfpAnalysisDir = [ENV.homeDir 'spike_lfp_analysis\'];
% ENV.spikeLfpProcDataDir = [ENV.spikeLfpAnalysisDir 'processed_data\'];

fprintf('Global ENV variable is now set.\n');

%% make processed data directories
ENV.frProcDataDir = [ENV.homeDir '/firing_rate_analysis/processed_data'];
if ~exist(ENV.frProcDataDir, 'dir')
    mkdir(ENV.frProcDataDir);
end
ENV.frFigDir = [ENV.homeDir '/firing_rate_analysis/figures'];
if ~exist(ENV.frFigDir, 'dir')
    mkdir(ENV.frFigDir);
end
ENV.lfpPowProcDataDir = [ENV.homeDir '/lfp_power_analysis/processed_data'];
if ~exist(ENV.lfpPowProcDataDir, 'dir')
    mkdir(ENV.lfpPowProcDataDir);
end
ENV.lfpPowFigDir = [ENV.homeDir '/lfp_power_analysis/figures'];
if ~exist(ENV.lfpPowFigDir, 'dir')
    mkdir(ENV.lfpPowFigDir);
end
fprintf('Processed data directories are now made.\n');

