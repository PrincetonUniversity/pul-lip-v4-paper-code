function spikeStats = computeSpikeStats(locData, window, varargin)
% computes basic statistics and properties about the spike data
% computes: rates, rateErrs, peakRates, maxRate, maxTrialRate, numTrials

kernelSigma = 0.01; % 10ms
overridedefaults(who, varargin);

N = size(locData, 2);

% compute evenly distributed time vector
% is this optimal?? this is what t is in the original chronux psth, without the
% -1.
% for window length of 700 ms and sigma 0.01, this creates 351 time points, 
% separated by 2 ms
nTime = fix(5*sum(window)/kernelSigma) + 1; % number of time steps. 
t = linspace(0, sum(window), nTime);

% for computing maxTrialRate, we don't want such small time bins
% using the above example, the following creates 36 time points, separated by 20
% ms
nTimeSparse = fix(0.5*sum(window)/kernelSigma) + 1; 
tSparse = linspace(0, sum(window), nTimeSparse);

% init the vectors to return with all spike stats data
rates = nan(N, nTime);
rateErrs = nan(N, nTime);
peakRates = nan(N, 2); % col1: t, col2: R; one for each location
maxRate = 0; % max of the max rates for each location
maxTrialRate = 0; % max of the max trial rates regardless of location
numTrials = zeros(N, 1);

for i = 1:N
    data = locData{i};
    numTrials(i) = size(data, 2);
    [R,~,E] = fixedPsth(data, kernelSigma, 2, t);
    if ~isempty(R)
        rates(i,:) = R;
        rateErrs(i,:) = E;
        
        [maxR,maxRInd] = max(R);
        peakRates(i,1:2) = [t(maxRInd) - window(1), maxR];
        
        maxRate = max(maxRate, max(R));
    end
    
    for j = 1:numel(data)
        R = fixedPsth(data(j), kernelSigma, 2, tSparse);
        if ~isempty(R)
            maxTrialRate = max(maxTrialRate, max(R));
        end
    end
end

% put all these variables into a struct - basically everything...
spikeStats = var2struct(locData, window, kernelSigma, t, rates, ...
        rateErrs, peakRates, maxRate, maxTrialRate, numTrials);
