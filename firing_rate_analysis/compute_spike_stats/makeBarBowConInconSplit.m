function [allDataSep, allData] = makeBarBowConInconSplit(spikeTimes, locs, ...
        eventName, windowName)
% creates:
% 1x7 struct array with fields:
%    barConData -- at (1), struct array with all bar con trials for P1
%    barInconData
%    bowConData
%    bowInconData
%    barData
%    bowData
%    combData -- all the above

allData = struct([]);
for i = 1:numel(locs)
    allData(i).barConData = spikeTimes.(eventName).(['barCon' locs{i} windowName]);
    allData(i).barInconData = spikeTimes.(eventName).(['barIncon' locs{i} windowName]);
    allData(i).bowConData = spikeTimes.(eventName).(['bowCon' locs{i} windowName]);
    allData(i).bowInconData = spikeTimes.(eventName).(['bowIncon' locs{i} windowName]);
    allData(i).barData = [allData(i).barConData allData(i).barInconData];
    allData(i).bowData = [allData(i).bowConData allData(i).bowInconData];
    % combined data, regardless of shape and congruency
    allData(i).combData = [allData(i).barConData ...
                           allData(i).barInconData ...
                           allData(i).bowConData ...
                           allData(i).bowInconData];
end

%% convert into cell arrays

allDataSep = struct([]);
allDataSep(1).barConData = {allData.barConData};
allDataSep(1).barInconData = {allData.barInconData};
allDataSep(1).bowConData = {allData.bowConData};
allDataSep(1).bowInconData = {allData.bowInconData};
allDataSep(1).barData = {allData.barData};
allDataSep(1).bowData = {allData.bowData};
allDataSep(1).combData = {allData.combData};

