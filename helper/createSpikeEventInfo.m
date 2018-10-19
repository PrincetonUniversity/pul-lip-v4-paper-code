function eventInfo = createSpikeEventInfo()
% create struct for storing all possible spike variable names
% will represent event-locked spike times for each condition (congruent vs
% incongruent, cue location, target shape)

eventsOld = {'Cue' 'Arr' 'Trial' 'Delay'};
% note: eventsNew includes AroundCueSortedByTime later
eventsNew = {'AroundCue' 'AroundArr' 'WholeTrial' 'Delay'}; 
targetsOld = {'Bar' 'Bow' ''};
targetsNew = lower(targetsOld);
cons = {'Con' 'Incon' ''}; % empty case is necessary for 0D data
locs = {'P1' 'P2' 'P3' 'P4' 'P5' 'P6'};

% note: if window includes too far back before cue or after array, get huge 
% effects of noise
% note: monkey's eyes are allowed to move before 100ms pre-cue and after 
% 150ms after array onset
% note: 400-800ms variable delay period between cue and array 

eventWindows = containers.Map(); % map from string to matrix
% [secsBeforeEvent secsAfterEvent]
eventWindows('Cue') = [0.3 0.5]; 
eventWindows('Arr') = [0.5 0.4];

% these are different -- they encode time before cue and time after array
eventWindows('WholeTrial') = [0.1 0.25];
eventWindows('Delay') = [-0.18 0];
windowKeys = eventWindows.keys();

preCueOnsetTime = eventWindows('Cue');
preCueOnsetTime = preCueOnsetTime(1);
preArrOnsetTime = eventWindows('Arr');
preArrOnsetTime = preArrOnsetTime(1);
preCueOnsetWholeTrialTime = eventWindows('WholeTrial');
preCueOnsetWholeTrialTime = preCueOnsetWholeTrialTime(1);

% time periods for analysis relative to the event onset
analysisWindowsOffset = containers.Map(); % map from string to matrix
analysisWindowsOffset('Cue') = [0.02 0.2];
analysisWindowsOffset('Arr') = [0.02 0.2];
analysisWindowsOffset('Trial') = [0.02 0.12]; % for cue

analysisWindows = containers.Map(); % map from string to matrix
analysisWindows('Cue') = preCueOnsetTime + analysisWindowsOffset('Cue');
analysisWindows('Arr') = preArrOnsetTime + analysisWindowsOffset('Arr');
analysisWindows('Trial') = preCueOnsetWholeTrialTime + analysisWindowsOffset('Trial'); % for cue

% plot shading parameters, as used in jbfill()
shadeParams = containers.Map(); % map from string to matrix
cueShadeCol = [0.9 1 0.9]; % light green
arrShadeCol = [0.9 0.9 0.9]; % light gray
shadeYUpper = [1000 1000];
shadeYLower = -shadeYUpper;

shadeParams('Cue') = {analysisWindowsOffset('Cue'), shadeYUpper, shadeYLower, ...
        cueShadeCol, cueShadeCol, 1, 1};
shadeParams('Arr') = {analysisWindowsOffset('Arr'), shadeYUpper, shadeYLower, ...
        arrShadeCol, arrShadeCol, 1, 1};
shadeParams('Trial') = {analysisWindowsOffset('Trial'), shadeYUpper, shadeYLower, ...
        cueShadeCol, cueShadeCol, 1, 1};


% normal; dark; light
barCols = [0 0 1; 0 0 0.7; 0.6 0.6 1]; % bar = blue
bowCols = [1 0 0; 0.7 0 0; 1 0.6 0.6]; % bow = red

% kind of a long way to get all window keys that have 'Cue'
cueWindows = windowKeys(not(cellfun('isempty', strfind(windowKeys, 'Cue'))));
arrWindows = windowKeys(not(cellfun('isempty', strfind(windowKeys, 'Arr'))));

windowOpts = {cueWindows, arrWindows, {'WholeTrial'}, {'Delay'}};

spikeTimeVarNames = struct();

index = 1;
for i = 1:length(eventsOld) 
    for j = 1:length(targetsOld)
        for k = 1:length(cons)
            if isempty(targetsOld{j}) && ~isempty(cons{k})
                % skip con/incon without a target shape
                continue;
            end
            for l = 1:length(locs)
                % each event type may have multiple windows for aggregating
                % spike times - these windows are kept in thisWindowOpts
                thisWindowOpts = windowOpts{i};
                for m = 1:length(thisWindowOpts)
                    spikeTimeVarNames(index).event = eventsNew{i};
                    spikeTimeVarNames(index).target = targetsOld{j};
                    spikeTimeVarNames(index).con = cons{k};
                    spikeTimeVarNames(index).loc = locs{l};
                    spikeTimeVarNames(index).locInd = l;
                    spikeTimeVarNames(index).window = thisWindowOpts{m};
                    if ismember(eventsOld{i}, {'Cue', 'Arr'})
                        spikeTimeVarNames(index).eventTimesBaseNames = ...
                                {[eventsOld{i} targetsOld{j} cons{k} 'P']};
                    elseif ismember(eventsOld{i}, {'Trial', 'Delay'})
                        spikeTimeVarNames(index).eventTimesBaseNames = ...
                                {['Cue' targetsOld{j} cons{k} 'P'], ...
                                 ['Arr' targetsOld{j} cons{k} 'P']};
                    end
                    % need to index into the above (:,l) for the right var
                    spikeTimeVarNames(index).spikeTimesName = ...
                            [targetsNew{j} cons{k} locs{l} thisWindowOpts{m}];
                    % note: consider renaming vars with
                    % session_name and cell_name as prefix
                    index = index + 1;
                end
            end
        end
    end
end

% put all these variables into a struct
eventInfo = var2struct(spikeTimeVarNames, eventsNew, targetsNew, cons, locs, ...
        eventWindows, cueWindows, arrWindows, analysisWindows, shadeParams, ...
        barCols, bowCols);

disp('eventInfo struct for spikes set up.');

