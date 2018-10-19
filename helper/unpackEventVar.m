
% myVarName can be one of the vars created from createSpikeVars.m or
% createLfpVars.m
% namesIndex indexes into myVarName.eventTimesBaseNames
function v = unpackEventVar(eventStruct, myVarName, namesIndex)

if nargin < 3
    if numel(myVarName.eventTimesBaseNames) ~= 1
        warning('Calling unpackEventVar() on %s without proper index', ...
                myVarName);
    end
    namesIndex = 1;
end

base = eventStruct.(myVarName.eventTimesBaseNames{namesIndex});
v = base(:,myVarName.locInd);
v(isnan(v)) = []; % remove NaNs
