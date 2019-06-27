function eventInfo = createLfpEventInfo()

%% Create eventInfo.varNames struct for storing all possible names
% This way, it is easier to loop through all the variables for analysis
% at the cost of having to use eval() which doesn't give good errors or 
% syntax checking, so be careful...

% also ArrayBarConP5GivenCueP3
eventsOld = {'Cue' 'Arr' 'Trial'};
eventsNew = {'AroundCue' 'AroundArr' 'WholeTrial'};
targetsOld = {'Bar' 'Bow' ''};
targetsNew = lower(targetsOld);
cons = {'Con' 'Incon' ''}; % empty case is necessary for 0D data
locs = {'P1' 'P2' 'P3' 'P4' 'P5' 'P6'};

% AD01 - Pulvinar
% AD02 - TEO
% AD03 - LIP
% AD04 - V4
% AD17 - Lever

% If window includes too far back before cue or after array, get huge 
% effects of noise.

% Note: 400-800ms variable delay between cue and array 

% pull out a large window around each event to avoid edge effects
% one for each of eventsNew, using those as the keys
eventWindows = containers.Map(); % map from string to matrix
% [secsBeforeEvent secsAfterEvent]
eventWindows('AroundCue') = [0.2 0.4];
eventWindows('AroundArr') = [0.5 0.3];
% [secsBeforeCue secsAfterArr]
eventWindows('WholeTrial') = [0.2 0.4];

preCueTime = eventWindows('AroundCue');
preCueTime = preCueTime(1);
preArrTime = eventWindows('AroundArr');
preArrTime = preArrTime(1);

analysisWindowsOffset = containers.Map(); % map from string to matrix
analysisWindowsOffset('PreCueBaseline') = [-0.18 0];
analysisWindowsOffset('AroundCue') = [0.02 0.2];
analysisWindowsOffset('AroundArr') = [0.02 0.2];
analysisWindowsOffset('WholeTrial') = [0.02 0.12]; % for cue

analysisWindows = containers.Map(); % map from string to matrix
analysisWindows('PreCueBaseline') = preCueTime + analysisWindowsOffset('PreCueBaseline');
analysisWindows('AroundCue') = preCueTime + analysisWindowsOffset('AroundCue');
analysisWindows('AroundArr') = preArrTime + analysisWindowsOffset('AroundArr');
analysisWindows('WholeTrial') = 0.05 + analysisWindowsOffset('WholeTrial'); % for cue

% plot shading parameters, as used in jbfill()
shadeParams = containers.Map(); % map from string to matrix
cueShadeCol = [0.9 1 0.9]; % light green
arrShadeCol = [0.9 0.9 0.9]; % light gray
shadeYUpper = [1000 1000];
shadeYLower = -shadeYUpper;

shadeParams('AroundCue') = {analysisWindowsOffset('AroundCue'), shadeYUpper, shadeYLower, ...
        cueShadeCol, cueShadeCol, 1, 1};
shadeParams('AroundArr') = {analysisWindowsOffset('AroundArr'), shadeYUpper, shadeYLower, ...
        arrShadeCol, arrShadeCol, 1, 1};
shadeParams('WholeTrial') = {analysisWindowsOffset('WholeTrial'), shadeYUpper, shadeYLower, ...
        cueShadeCol, cueShadeCol, 1, 1};

% normal; dark; light
barCols = [0 0 1; 0 0 0.7; 0.6 0.6 1]; % bar = blue
bowCols = [1 0 0; 0.7 0 0; 1 0.6 0.6]; % bow = red

lfpVarNames = struct('event',[],'target',[],'con',[],'loc',[],'window',[],...
        'oldName',[],'newName',[]);

index = 1;
for i = 1:length(eventsOld) 
    for j = 1:length(targetsOld)
        for k = 1:length(cons)
            if isempty(targetsOld{j}) && ~isempty(cons{k})
                % skip con/incon without a target shape
                continue;
            end
            for l = 1:length(locs)
                lfpVarNames(index).event = eventsNew{i};    
                lfpVarNames(index).target = targetsOld{j};
                lfpVarNames(index).con = cons{k};
                lfpVarNames(index).loc = locs{l};
                lfpVarNames(index).locInd = l;
                if ismember(eventsOld{i}, {'Cue', 'Arr'})
                    lfpVarNames(index).eventTimesBaseNames = ...
                            {[eventsOld{i} targetsOld{j} cons{k} 'P']};
                elseif ismember(eventsOld{i}, {'Trial'})
                    lfpVarNames(index).eventTimesBaseNames = ...
                            {['Cue' targetsOld{j} cons{k} 'P'], ...
                             ['Arr' targetsOld{j} cons{k} 'P']};
                end
                % need to index into the above (:,l) for the right var
                lfpVarNames(index).lfpsName = [targetsNew{j} cons{k} locs{l}];
                % note: consider renaming vars with
                % session_name and cell_name as prefix
                index = index + 1;
            end
        end
    end
end

% put all these variables into a struct
eventInfo = var2struct(lfpVarNames, eventsNew, targetsNew, cons, locs, ...
        eventWindows, analysisWindows, shadeParams, barCols, bowCols);

disp('eventInfo struct set up.');

