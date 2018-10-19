function spikeStats = computeSpikeStatsRunner(data, window, varargin)
% computes the spdf for each field in the data struct

% data is the struct of separated cell arrays from makeBarBowConInconSplit()
% which comes in the form of a struct having fields:
%      barConData: {1x6 cell}
%    barInconData: {1x6 cell}
%      bowConData: {1x6 cell}
%    bowInconData: {1x6 cell}
%         barData: {1x6 cell}
%         bowData: {1x6 cell}
%        combData: {1x6 cell}
% Each of those cell arrays gets processed by computeSpikeStats2() for the given
% window and put into a single struct with the original field names minus the
% 'Data' part.

% would use the following but can't change the field names this way. might as
% well run through the fields manually.
%spikeStats = structfun(@(x) computeSpikeStats2(x, window, varargin{:}), ...
%        data, 'UniformOutput', false);
    
f = fields(data);
for i = 1:numel(f)
    newFieldName = f{i}(1:end-4); % remove 'Data' from field name
    spikeStats.(newFieldName) = computeSpikeStats(data.(f{i}), window, ...
            varargin{:});
end
spikeStats.t = spikeStats.comb.t - window(1);
spikeStats.window = window;