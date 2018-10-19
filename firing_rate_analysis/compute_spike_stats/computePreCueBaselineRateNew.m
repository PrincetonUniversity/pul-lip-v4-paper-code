function [baselineRate, baselineRateSD, baselineWindowOffset] = computePreCueBaselineRateNew(spikeTimes, cueOnset, varargin)
% Computes the baseline firing rate during a window before cue onset

% This basically counts spikes in the window and divides that by the window
% length and the number of trials. No fancy smoothing/kernels here.
% 
%   spikeTimes - struct array of spike times aligned to cue onset. if empty, returns NaN
%   cueOnset - time of cue onset in spikeTimes
% Other params:
%   baselineWindowOffset - the extent of the window for computing the baseline
%                         relative to the cue time

baselineWindowOffset = [-0.1 0]; % in seconds, relative to cue time
overridedefaults(who, varargin);

baselineWindow = cueOnset + baselineWindowOffset;

if baselineWindow(1) < 0
    warning('flanker_task_analysis:negativeBaselineWindow',...
            ['Baseline window [%.3f,%.3f] extends past input data range. '...
            'Setting lower bound to 0'], baselineWindow(1), baselineWindow(2));
    baselineWindow(1) = 0;
end

[baselineRate, baselineRateSD] = computeAvgRateInWin(spikeTimes, baselineWindow);

