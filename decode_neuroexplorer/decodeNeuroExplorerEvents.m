function decodeNeuroExplorerEvents(Event004,Event005,Event006,Event007,...
       Event008,Event009,Event010,Strobed,isIncludeDistractors)

% Identify onset time of stimuli presented during flanker task based on 
% Plexon events/strobed words
%
% Please first run Neuroexplorer to export the specified variables in
% Plexon file to MATLAB
%
% Input:
% Event004, Event005, Event006, Event007, Event008, Event009, Event010,
% Strobed,
% Event4-6: 3-bit cue position (times when these bits were 1)
% Event7:   cue validity bit/event - always occurs with a cue (so Ev4-6: 000
%           can be detected)
% Event8:   bowtie at P2
% Event9:   barrel at P2
% Event10:  juice
% Strobed:  the 7-bit word describing the array configuration
%           bit 1 is the shape immediately next, clockwise of RF
%           bit 2 is the shape immediately next, CCW of RF
%           bit 3-7 are the 2nd to 6th shapes next CCW, after the adjacent 
%           one (represented by bit 2) of RF
%           note that the shape at the RF (P2) is shown by Events 8 and 9
%           col 1: time, col 2: the 7-bit word
% isIncludeDistractors: flag to indicate whether this is a task 
%                       with/without distractors
%
% Output:
% CueP1...6: cue onset time
% ArrayP1...6: array onset time
%
% CueBowP1...6: cue onset time for cued bowtie
% CueBarP1...6: cue onset time for cued barrel
% ArrBowP1...6: array onset time for cued bowtie
% ArrBarP1...6: array onset time for cued barrel
%
% CueBowConP1...6: cue onset time for congruent cued bowtie
% CueBowInconP1...6: cue onset time for incongruent cued bowtie
% CueBarConP1...6: cue onset time for congruent cued barrel
% CueBarInconP1...6: cue onset time for incongruent cued barrel
% ArrBowConP1...6: array onset time for congruent cued bowtie
% ArrBowInconP1...6: array onset time for incongruent cued bowtie
% ArrBarConP1...6: array onset time for congruent cued barrel
% ArrBarInconP1...6: array onset time for incongruent cued barrel 
%
% Usage:
% decodeNeuroExplorerEvents(Event004, Event005, Event006, Event007, Event008, Event009, Event010, Strobed)
%
% Adapted from convertEvent_ArrayGivenCueP function written by Rick Li and
% Yuri Saalmann in Sabine Kastner's lab
%

if nargin < 9
    isIncludeDistractors = 1;
end

numCuePositions = 6; % a lot depends on this...
if ~exist('Event008', 'var'), Event008 = []; end
if ~exist('Event009', 'var'), Event009 = []; end

% each Event00* var has a list of times
% Events 4-6: their presence represents a 3-bit word for cue position
% Event 7: cue validity bit/event - always occurs with a cue (so Ev4-6: 000
% can be detected)
% cueStimOrig is a zero-padded matrix of Event004-7 in columns
cueStimOrig = Event004;
cueStimOrig(1:length(Event005),2) = Event005;
cueStimOrig(1:length(Event006),3) = Event006; 
cueStimOrig(1:length(Event007),4) = Event007;

cueOffset = 0.005; % 5ms
arrayOffset = -0.015; % -15ms

maxCueToJuiceTime = 2.15; % sec
maxCueToArrayTime = 1; % sec

simultSignalTol = 0.001; % tolerance level for simultaneous signals --
% if two events are within this # seconds from each other, they represent
% the same signal. currently only used in comparing Strobed <-> Event8/9 
% signals

% "simultaneous" Plexon events are slightly offset in time: 
% (8.6568 and 8.6569). the de-binarizing of events to work requires that
% events sent at the same time to represent a cue are actually at the same
% time, so round up -- this could cause mis-id of a trial if an event comes
% in at 1.999 and another corresponding to the same cue is sent in at 2.001
% chances are very slim though. another way to do it is to loop through
% Event007 and find the Event004-6 that are within 100ms or something of
% it. TODO: do this. it's better.
cueStimRound = ceil(cueStimOrig*10)/10; % ceiling to 10ths place (100ms)

% store the cue position as 0-5 instead of as binary
cueDecimal = zeros(size(Event007)); 

event10Count = 1; % which event10 is currently being looked at
% number of trials of cue occurring in the specific location
cuePosCount = zeros(numCuePositions,1); 
cueTimes = nan(1,numCuePositions); % cols represent the 6 positions

for i = 1:length(Event007)
    % convert binary representation of cue location (Ev4-6) to decimal 
    % with 6 distractors, cueDecimal(i) ranges 0-5
    if ismember(cueStimRound(i,4), cueStimRound(:,1))
        cueDecimal(i) = 1;
    end
    if ismember(cueStimRound(i,4), cueStimRound(:,2))
        cueDecimal(i) = cueDecimal(i) + 2;
    end
    if ismember(cueStimRound(i,4), cueStimRound(:,3))
        cueDecimal(i) = cueDecimal(i) + 4;
    end
    cueDecimal(i) = cueDecimal(i) + 1; % now in the correct range 1-6
    if cueDecimal(i) <= 0 || cueDecimal(i) > numCuePositions
        error('Invalid cue position %d at trial %d', cueDecimal(i), i);
    end
    
    % reminder: Event 10 is juice
    % question: why are there fewer juice events than valid events?
    % this below is probably to rule out when juice was given before the 
    % current trial. it seems that they are not consistently paired. you
    % can have one without a corresponding other.
    
    % note that in Yuri's code, this was an if statement vs a while loop,
    % and thus, some trials were accidentally discarded because when 
    % Event007(i) did indeed have a juice pulse immediately following it,
    % Event010(event10Count+1) was still less than Event007(i) using the
    % variables at their state at this comment, i.e. the if statement below
    % that saves into cueTimes (actually, its analogous variable) was not
    % triggered.
    while event10Count <= length(Event010) && ...
            Event010(event10Count) < Event007(i)
        event10Count = event10Count + 1;
    end
    if event10Count > length(Event010)
        break;
    end
    % at this point, the next juice event (at Event010(event10Count)) is 
    % after the current trial (cue event) as it should be
    
    % if the next juice event is associated with the current trial, then
    % this was a correct trial. save it. 
    if Event010(event10Count) < Event007(i) + maxCueToJuiceTime
        % add the cue event time to the CueP column corresponding
        % to the cue location, at the next empty row for that column
        cuePosCount(cueDecimal(i)) = cuePosCount(cueDecimal(i)) + 1;
        cueTimes(cuePosCount(cueDecimal(i)),cueDecimal(i)) = Event007(i);
        event10Count = event10Count + 1;
    end
end

% cueTimes now has all the cue times for each cue location, separated as columns
% it is padded by zeros

% init all the matrices with nan
S = struct();
S.CueP = nan(size(cueTimes)); % the adjusted/corrected CueP matrix
S.ArrP = nan(size(cueTimes)); % matrix of the array times for each
                                      % corresponding cue time
S.CueBowP = nan(size(cueTimes));
S.CueBarP = nan(size(cueTimes));
S.ArrBowP = nan(size(cueTimes));
S.ArrBarP = nan(size(cueTimes));
S.CueBowConP = nan(size(cueTimes));
S.CueBarConP = nan(size(cueTimes));
S.ArrBowConP = nan(size(cueTimes));
S.ArrBarConP = nan(size(cueTimes));
S.CueBowInconP = nan(size(cueTimes));
S.CueBarInconP = nan(size(cueTimes));
S.ArrBowInconP = nan(size(cueTimes));
S.ArrBarInconP = nan(size(cueTimes));

% note: Tables are horribly horribly inefficient, but they are very
% human readable
S.TrialTable = table(); % []

for i = 1:numCuePositions
    % compute the array onset times for each cue onset and remove any cues
    % that are not associated with an array (e.g. a catch trial)
    [CuePi, ArrPi] = getArrayOnset(cueTimes(:,i), Strobed,...
            cueOffset, arrayOffset, maxCueToArrayTime);
    % save the vars that were output (the cue and array onset times) into the 
    % larger matrices
    S.CueP(1:length(CuePi),i) = CuePi;
    S.ArrP(1:length(ArrPi),i) = ArrPi; 
    
    CueLoc = ones(length(CuePi),1)*i;
    TrialTablePi = table(CuePi, ArrPi, CueLoc);
%     TrialTablePi = nan(length(CuePi), 5);
%     TrialTablePi(:,1:3) = [CuePi ArrPi CueLoc];
    
    [CueBowPi, ArrBowPi, CueBarPi, ArrBarPi, TrialTablePi] = ...
            getArrayBowBarOnset(CuePi, i, Event008, Event009, ...
            Strobed, arrayOffset, maxCueToArrayTime, simultSignalTol, ...
            TrialTablePi);
    % save the vars that were output (the cue and array onset times, for bow vs 
    % bar trials separately) into the larger matrices
    S.CueBowP(1:length(CueBowPi),i) = CueBowPi;
    S.CueBarP(1:length(CueBarPi),i) = CueBarPi;
    S.ArrBowP(1:length(ArrBowPi),i) = ArrBowPi;
    S.ArrBarP(1:length(ArrBarPi),i) = ArrBarPi;
    
    if isIncludeDistractors
        [CueBowInconPi, ArrBowInconPi, CueBowConPi, ArrBowConPi, ...
                CueBarInconPi, ArrBarInconPi, CueBarConPi, ArrBarConPi, ...
                TrialTablePi] = ...
                getArrayCuedConOnset(CuePi, i, Event008, Event009, ...
                Strobed, arrayOffset, maxCueToArrayTime, simultSignalTol, ...
                TrialTablePi);
        S.CueBowInconP(1:length(CueBowInconPi),i) = CueBowInconPi;
        S.CueBarInconP(1:length(CueBarInconPi),i) = CueBarInconPi;
        S.ArrBowInconP(1:length(ArrBowInconPi),i) = ArrBowInconPi;
        S.ArrBarInconP(1:length(ArrBarInconPi),i) = ArrBarInconPi;
        S.CueBowConP(1:length(CueBowConPi),i) = CueBowConPi;
        S.CueBarConP(1:length(CueBarConPi),i) = CueBarConPi;
        S.ArrBowConP(1:length(ArrBowConPi),i) = ArrBowConPi;
        S.ArrBarConP(1:length(ArrBarConPi),i) = ArrBarConPi;
    end
    
    S.TrialTable = [S.TrialTable; TrialTablePi];
end

% delete end rows that are solely NaNs from above matrices
fields = fieldnames(S);
for i = 1:numel(fields)
    if ~strcmp(fields{i}, 'TrialTable')
        S.(fields{i}) = trimNanRows(S.(fields{i}));
    end
end

if isIncludeDistractors
    saveFileName = 'StimuliOnset_5D.mat';
else
    saveFileName = 'StimuliOnset_0D.mat';
end

% TODO include sessionName?
fprintf(' >%s ', saveFileName);
save(saveFileName, '-struct', 'S'); % save S.vars as individual vars

end % end function




% CuePi is a column vector of cue onset times
% Determine the array onset times associated with each cue onset time
% and remove any cue onset times that are not followed by an strobed event
% time (e.g. catch trials)
function [CuePi, ArrPi] = getArrayOnset(CuePi, Strobed, cueOffset,...
        arrayOffset, maxCueToArrayTime)
assert(size(CuePi,2) == 1);
ArrPi = zeros(size(CuePi));
% for every cue time, find the Strobed time (OR times??) that occurs within
% 1 second after cue time. then save the Strobed time into ArrayGivenCueP
for i = 1:size(ArrPi,1)
    indx = find(CuePi(i) <= Strobed(:,1) & ...
            Strobed(:,1) < CuePi(i) + maxCueToArrayTime);
    if ~isempty(indx)
        if length(indx) > 1
            error(['Too many (%d) array onsets within %f of a single '...
                    'cue at %f.'],...
                    length(indx), maxCueToArrayTime, CuePi(i));
        end
        ArrPi(i) = Strobed(indx,1); % just the time
    end
end

% remove the cue onsets related to catch trials (where ArrayGivenCueP == 0,
% i.e. not set in previous loop)
CuePi(~ArrPi) = []; 
ArrPi(~ArrPi) = [];

% apply the cue/array timing offsets - hmmm should these be applied
% earlier?
CuePi = CuePi + cueOffset;
ArrPi = ArrPi + arrayOffset;
end




function [CueBowPi, ArrBowPi, CueBarPi, ArrBarPi, TrialTablePi] = getArrayBowBarOnset(...
        CuePi, cueLoc, Event008, Event009, Strobed, arrayOffset, ...
        maxCueToArrayTime, simultSignalTol, TrialTablePi)
numCueEvents = size(CuePi,1);
ArrBowPi = nan(numCueEvents); % preallocate
ArrBarPi = nan(numCueEvents);
ArrBowCount = 0; 
ArrBarCount = 0;
CueBowPi = nan(numCueEvents); 
CueBarPi = nan(numCueEvents);
shapeP = zeros(1,8); % which shape is at which location, 0 = bow, 1 = bar
Shape = cell(numCueEvents, 1);
for i = 1:numCueEvents
    indx = find(Strobed(:,1) > CuePi(i) & Strobed(:,1) < CuePi(i) + maxCueToArrayTime);
    if ~isempty(indx)
        % Event008 is triggered at the time of the array (approx) if the
        % shape at the RF is a bowtie. Event009 is triggered if it's a
        % barrel
        if any(abs(Strobed(indx,1) - Event008(:)) < simultSignalTol)
            typeRF = 0;
        elseif any(abs(Strobed(indx,1) - Event009(:)) < simultSignalTol)
            typeRF = 1;
        else
            error(['Strobed word not associated with an RF bow/bar '...
                    'event for cue at time %f'], CuePi(i));
        end
        % sort out all the shapes from the strobed word and event8/9.
        % P2 is defined as the position of the RF.
        % in the experimental code, P1 is the next shape clockwise of the
        % RF. P3 is the next shape anti-clockwise of the RF. P4 is the next
        % one over.
        nonRFShapes = bitget(Strobed(indx,2), 1:7);
        shapeP(1) = nonRFShapes(1);
        shapeP(2) = typeRF;
        shapeP(3:end) = nonRFShapes(2:end);
        if shapeP(cueLoc) == 0 % bowtie = 0
            ArrBowCount = ArrBowCount + 1;
            CueBowPi(ArrBowCount) = CuePi(i);
            ArrBowPi(ArrBowCount) = Strobed(indx,1) + arrayOffset;
            Shape{i} = 'Bow';
        else % barrel = 1
            ArrBarCount = ArrBarCount + 1;
            CueBarPi(ArrBarCount) = CuePi(i);
            ArrBarPi(ArrBarCount) = Strobed(indx,1) + arrayOffset;
            Shape{i} = 'Bar';
        end
%         TrialTablePi(i,4) = shapeP(cueLoc);
    end
end

% shrink arrays because pre-allocation too large
CueBowPi(isnan(CueBowPi)) = [];
ArrBowPi(isnan(ArrBowPi)) = [];
CueBarPi(isnan(CueBarPi)) = [];
ArrBarPi(isnan(ArrBarPi)) = [];

TrialTablePi.Shape = Shape;

end



function [CueBowInconPi, ArrBowInconPi, CueBowConPi, ArrBowConPi, ...
          CueBarInconPi, ArrBarInconPi, CueBarConPi, ArrBarConPi, ...
          TrialTablePi] = ...
          getArrayCuedConOnset(CuePi, cueLoc, Event008, Event009, ...
          Strobed, arrayOffset, maxCueToArrayTime, simultSignalTol, ...
          TrialTablePi)
numCueEvents = size(CuePi,1);
CueBowInconPi = nan(numCueEvents); % preallocate
ArrBowInconPi = nan(numCueEvents); 
CueBowConPi = nan(numCueEvents); 
ArrBowConPi = nan(numCueEvents);
CueBarInconPi = nan(numCueEvents); 
ArrBarInconPi = nan(numCueEvents); 
CueBarConPi = nan(numCueEvents); 
ArrBarConPi = nan(numCueEvents);
ArrayBowInconCount = 0; 
ArrayBowConCount = 0; 
ArrayBarInconCount = 0; 
ArrayBarConCount = 0;
shapeP = zeros(1,8);
Shape = cell(numCueEvents, 1);
Congruency = cell(numCueEvents, 1);
for i = 1:numCueEvents
    indx = find(Strobed(:,1) > CuePi(i) & Strobed(:,1) < CuePi(i) + maxCueToArrayTime);
    if ~isempty(indx)
        % Event008 is triggered at the tiem of the array (approx) if the
        % shape at the RF is a bowtie. Event009 is triggered if it's a
        % barrel
        if any(abs(Strobed(indx,1) - Event008(:)) < simultSignalTol)
            typeRF = 0;
        elseif any(abs(Strobed(indx,1) - Event009(:)) < simultSignalTol)
            typeRF = 1;
        end
        % sort out all the shapes from the strobed word and event8/9.
        % P2 is defined as the position of the RF.
        % in the experimental code, P1 is the next shape clockwise of the
        % RF. P3 is the next shape anti-clockwise of the RF. P4 is the next
        % one over.
        nonRFShapes = bitget(Strobed(indx,2),1:7);
        shapeP(1) = nonRFShapes(1);
        shapeP(2) = typeRF;
        shapeP(3:end) = nonRFShapes(2:end);
        % flankerTargetPos holds the indices of the flankers and targets,
        % order is irrelevant
        if cueLoc == 1; % on the most-left of 6bit line
            flankerTargetPos = [1 2 6];
        elseif cueLoc == 6 % on the most-right of 6bit line
            flankerTargetPos = [1 5 6];
        else
            flankerTargetPos = [cueLoc-1 cueLoc cueLoc+1];
        end
        % shapeP is 0 for bowtie, 1 for barrel
        % congruent bowtie trial: all three are 0, so product = 0, sum = 0
        % congruent barrel trial: all three are 1, so product = 1
        % incon bowtie trial: two are 0, one is 1, so product = 0, sum = 1
        % incon barrel trial: two are 1, one is 0, so product = 0, sum = 2
        % note that both flankers are *always* the same. otherwise this
        % algorithm doesn't work
        if prod(shapeP(flankerTargetPos)) == 0 && sum(shapeP(flankerTargetPos)) == 0
            ArrayBowConCount = ArrayBowConCount + 1;
            CueBowConPi(ArrayBowConCount,1) = CuePi(i);
            ArrBowConPi(ArrayBowConCount,1) = Strobed(indx,1) + arrayOffset;
            Shape{i} = 'Bow';
            Congruency{i} = 'Con';
%             TrialTablePi(i,4:5) = [0 0];
        elseif prod(shapeP(flankerTargetPos)) == 1
            ArrayBarConCount = ArrayBarConCount + 1;
            CueBarConPi(ArrayBarConCount,1) = CuePi(i);
            ArrBarConPi(ArrayBarConCount,1) = Strobed(indx,1) + arrayOffset;
            Shape{i} = 'Bar';
            Congruency{i} = 'Con';
%             TrialTablePi(i,4:5) = [1 0];
        elseif prod(shapeP(flankerTargetPos)) == 0 && sum(shapeP(flankerTargetPos)) ~= 0
            if shapeP(cueLoc) == 0
                ArrayBowInconCount = ArrayBowInconCount + 1;
                CueBowInconPi(ArrayBowInconCount,1) = CuePi(i);
                ArrBowInconPi(ArrayBowInconCount,1) = Strobed(indx,1) + arrayOffset;
                Shape{i} = 'Bow';
                Congruency{i} = 'Incon';
%                 TrialTablePi(i,4:5) = [0 1];
            else
                ArrayBarInconCount = ArrayBarInconCount + 1;
                CueBarInconPi(ArrayBarInconCount,1) = CuePi(i);
                ArrBarInconPi(ArrayBarInconCount,1) = Strobed(indx,1) + arrayOffset;
                Shape{i} = 'Bar';
                Congruency{i} = 'Incon';
%                 TrialTablePi(i,4:5) = [1 1];
            end
        else
            error('Array layout is wrong\n');
        end
    end
end

% shrink arrays because pre-allocation too large
CueBowConPi(isnan(CueBowConPi)) = [];
ArrBowConPi(isnan(ArrBowConPi)) = [];
CueBarConPi(isnan(CueBarConPi)) = [];
ArrBarConPi(isnan(ArrBarConPi)) = [];
CueBowInconPi(isnan(CueBowInconPi)) = [];
ArrBowInconPi(isnan(ArrBowInconPi)) = [];
CueBarInconPi(isnan(CueBarInconPi)) = [];
ArrBarInconPi(isnan(ArrBarInconPi)) = [];

TrialTablePi.Shape = Shape;
TrialTablePi.Congruency = Congruency;

end
