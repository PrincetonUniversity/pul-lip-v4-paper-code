function foundSpikeSigs = findSpikeSigs(S, areaIndex)

maxSpikeSigsPerArea = 5;
foundSpikeSigs = {};
for j = 1:maxSpikeSigsPerArea
    sigName = ['sig00' num2str(areaIndex) char('a'+j-1)];
    if isfield(S, sigName)
        foundSpikeSigs = [foundSpikeSigs sigName];
    end
end
