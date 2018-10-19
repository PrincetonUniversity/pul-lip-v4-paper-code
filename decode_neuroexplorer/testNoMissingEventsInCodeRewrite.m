% confirm that the new StimuliOnset_5D variables contains all the event
% times from the old StimuliOnset, though possibly plus some.
% at least for L110523 here
function testNoMissingEventsInCodeRewrite()

isIncludeDistractors = 1;
% load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L110523\spikes\PUL\0D\StimuliOnset_0D.mat') % old
% load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L110523\StimuliOnset_0D.mat') % new
% load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L110523\spikes\PUL\StimuliOnset.mat') % old
% load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L110523\StimuliOnset_5D.mat') % new
load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L101124\spikes\PUL\StimuliOnset.mat') % old
load('D:\Documents\MATLAB\flanker_task_analysis\data\example\L101124\StimuliOnset_5D.mat') % new

% col 1: old prefix, col 2: new variable name
varsToCheck = {'CueP', 'CueP';
               'ArrayGivenCueP', 'ArrP';
               'CueBowP', 'CueBowP';
               'CueBarP', 'CueBarP'; 
               'ArrayGivenCuedBowP', 'ArrBowP';
               'ArrayGivenCuedBarP', 'ArrBarP';
               'CueBowConP', 'CueBowConP';
               'CueBarConP', 'CueBarConP'; 
               'ArrayGivenCuedBowConP', 'ArrBowConP';
               'ArrayGivenCuedBarConP', 'ArrBarConP';
               'CueBowInconP', 'CueBowInconP';
               'CueBarInconP', 'CueBarInconP'; 
               'ArrayGivenCuedBowInconP', 'ArrBowInconP';
               'ArrayGivenCuedBarInconP', 'ArrBarInconP'};
startConVars = 7;
           
for i = 1:size(varsToCheck,1)
    if ~isIncludeDistractors && i >= startConVars
        break; % 0D trials have no con/incon designations
    end
    numAdded = 0;
    newVarMat = eval(varsToCheck{i,2});
    for j = 1:6
        oldVar = eval([varsToCheck{i,1} num2str(j)]);
        newVar = newVarMat(:,j);
        intersection = intersect(oldVar, newVar);
        if ~(isempty(oldVar) && isempty(intersection)) && ...
                (~all(size(intersection) == size(oldVar)) || ...
                ~all(intersection == oldVar))
            error(['There are values in %s that are not in %s.'...
                    ' Something must be wrong with the decoding.\n'], ...
                    [varsToCheck{i,1} num2str(j)], varsToCheck{i,2});
        end
        
        % there may be extra events in the new variable - count them
        delta = sum(~isnan(newVar)) - numel(oldVar);
        numAdded = numAdded + delta;
        %fprintf('%d trials added for P%d\n', delta, i);
    end
    fprintf(['%d %s trials added using new decodeNeuroExplorerEvents', ...
            ' code (none missing)\n'], numAdded, varsToCheck{i,2});
    % num added to CueP should be same as num added to CueBowP + to CueBarP
    % same for ArrayGivenCueP (really, it's more: the trials should be the 
    % union)
    % also num added to CueP should be same as for ArrayGivenCueP
    
    checkMatSetUpCorrectly(newVarMat, varsToCheck{i,2});
end

end

% all the non-NaN values in a column should be before the NaN if there are
% any, and there should be no rows that are just NaN
function checkMatSetUpCorrectly(mat, varName)
for i = 1:size(mat,2)
    numNonNaNValues = sum(~isnan(mat(:,i)));
    if any(isnan(mat(1:numNonNaNValues,i)))
        error(['Matrix %s is not set up correctly: there are non-NaN' ...
                ' values after the NaN values in column %d\n'], varName, i);
    end
end
assert(~all(all(isnan(mat),2)));
end