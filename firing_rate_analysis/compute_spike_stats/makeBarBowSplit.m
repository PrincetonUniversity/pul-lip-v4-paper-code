function [allDataSep,allData] = makeBarBowSplit(spikeTimes, locs, eventName, ...
        windowName)
% creates:
% 1x3 struct array with fields:
%    barData -- at (1), struct array with all bar trials for P1
%    bowData
%    combData -- all the above

allData = struct([]);
for i = 1:numel(locs)
    allData(i).barData = spikeTimes.(eventName).(['bar' locs{i} windowName]);
    allData(i).bowData = spikeTimes.(eventName).(['bow' locs{i} windowName]);
    % combined data, regardless of shape and congruency
    allData(i).combData = [allData(i).barData allData(i).bowData];
end

%% convert into cell arrays
allDataSep = struct([]);
allDataSep(1).barData = {allData.barData};
allDataSep(1).bowData = {allData.bowData};
allDataSep(1).combData = {allData.combData};

