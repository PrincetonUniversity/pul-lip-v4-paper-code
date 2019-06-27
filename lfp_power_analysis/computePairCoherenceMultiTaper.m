function [pairCoh,pairTCoh,power,multiTaperParams] = computePairCoherenceMultiTaper(preProcLFPByLoc, loc, eventName, params)

%% pre-processing
% paramsPre = params;
paramsPost = params;
%downsampleFactor = 2;
%paramsPost.Fs = paramsPre.Fs / downsampleFactor; % downsampled to 500 Hz

numAreas = size(preProcLFPByLoc{loc}.(eventName),3);

%% normalize - subtract point-wise ensemble mean and divide by standard deviation from each trial
% [samples x trials x areas]
preProcLFPNormAtLoc = nan(size(preProcLFPByLoc{loc}.(eventName)));
for i = 1:numAreas
    areaData = preProcLFPByLoc{loc}.(eventName)(:,:,i);
    areaDataMean = mean(areaData, 2);
    areaDataStd = std(areaData, 0, 2);
    for j = 1:size(areaData,2)
        preProcLFPNormAtLoc(:,j,i) = (preProcLFPByLoc{loc}.(eventName)(:,j,i) - areaDataMean) ./ areaDataStd;
    end
end

%% compute power spectrum over the whole window
numPtsPerTrial = size(preProcLFPNormAtLoc,1);
nfft = max(2^(nextpow2(numPtsPerTrial) + paramsPost.pad),numPtsPerTrial);
f = getfgrid(paramsPost.Fs, nfft, paramsPost.fpass);
S = nan(numel(f), numAreas);

for i = 1:numAreas
    locSessionDataAreaI = preProcLFPNormAtLoc(:,:,i);
    [S(:,i),fTmp] = mtspectrumc(locSessionDataAreaI, paramsPost);
    assert(all(f == fTmp));
end

%% compute t, f
% slidingWindow = [0.2 0.01];
slidingWindow = [0.3 0.01];

numPtsPerTrial = size(preProcLFPNormAtLoc,1);
Nwin = round(paramsPost.Fs * slidingWindow(1)); % number of samples in window
nfft = max(2^(nextpow2(Nwin)+paramsPost.pad),Nwin);
f = getfgrid(paramsPost.Fs, nfft, paramsPost.fpass); 

Nstep = round(paramsPost.Fs * slidingWindow(2)); % number of samples to step through
winmid = (1:Nstep:numPtsPerTrial-Nwin+1) + round(Nwin/2);
t = winmid / paramsPost.Fs;

%% compute power spectrum with sliding window
S = nan(numel(t), numel(f), numAreas);
for i = 1:numAreas
    locSessionDataAreaI = preProcLFPNormAtLoc(:,:,i);
    [S(:,:,i),tTmp,fTmp] = mtspecgramc(locSessionDataAreaI, slidingWindow, paramsPost);
    assert(all(t == tTmp));
    assert(all(f == fTmp));
end

%% compute coherence with sliding window
numPairs = nchoosek(numAreas, 2);
C = nan(numel(t), numel(f), numPairs);

pairCount = 1;
for i = 1:numAreas
    locSessionDataAreaI = preProcLFPNormAtLoc(:,:,i);
    for j = i+1:numAreas
        locSessionDataAreaJ = preProcLFPNormAtLoc(:,:,j);
        
        [C(:,:,pairCount),phi,S12,S1,S2,tTmp,fTmp] = cohgramc(...
                locSessionDataAreaI, locSessionDataAreaJ, slidingWindow, paramsPost);
        assert(all(t == tTmp));
        assert(all(f == fTmp));
        assert(all(all(S1 == S(:,:,i))));
        assert(all(all(S2 == S(:,:,j))));
        
        pairCount = pairCount + 1;
    end
end

pairCoh = C;
power = S;
multiTaperParams = var2struct(paramsPost, slidingWindow, f, t);

numTrials = size(preProcLFPByLoc{loc}.(eventName),2);
pairTCoh = atanh(pairCoh)-(1/((2*paramsPost.tapers(2)*numTrials)-2));

% C.coh [361x100x6 double] -- time windows x freq bins x channel pairs
% (:,:,1) = ch1 vs ch2
% (:,:,2) = ch1 vs ch3
% (:,:,3) = ch1 vs ch4
% (:,:,4) = ch2 vs ch3
% (:,:,5) = ch2 vs ch4
% (:,:,6) = ch3 vs ch4