function convertStimEventsSingleSession(dataDir, sessionName)
% convert the stimulus events exported from NeuroExplorer into event
% variables that can be more easily parsed (e.g. CueP1 has all times when
% the cue was presented at position 1).

cd([dataDir filesep sessionName]); % cd b/c called scripts save to current dir

% 2011 recordings -- no adjustments needed
if ~strcmp(sessionName(2:3), '10')
    load([sessionName '_events.mat']); 
    % the {sessionName}_events.mat file should have Event004_5D, 
    % Event005_5D, etc., and if there are 0D data, it should also have 
    % Event004_0D, Event005_0D, etc.
    
    % resolve special cases
    if strcmp(sessionName, 'L110812')
        Strobed_5D(410,:) = []; % a strobed word was sent for this trial but no
        % associated Event008 or Event009 were sent, which is anomalous. So
        % effectively remove the trial.
        Strobed_5D(411:413,:) = []; % same for the newly indexed trial 411-413.
    elseif strcmp(sessionName, 'C110728')
        Strobed_0D(72,:) = []; % see comments above
    end
    
    % create a different set of files if 0D data is present
    if exist('Event004_0D', 'var')
        % creates StimuliOnset_0D.mat file in {dataDir}/{sessionName}
        decodeNeuroExplorerEvents(Event004_0D, Event005_0D, Event006_0D,...
                Event007_0D, Event008_0D, Event009_0D, Event010_0D,...
                Strobed_0D, 0)
    end
    
    % creates StimuliOnset_5D.mat file
    decodeNeuroExplorerEvents(Event004_5D, Event005_5D, Event006_5D, Event007_5D,...
            Event008_5D, Event009_5D, Event010_5D, Strobed_5D)
    return
end

% effectively the ELSE condition:
% do the following conversion code ONLY for 2010 recordings

% load the event data from Neuroexplorer export
load([sessionName '_events.mat']);  

% generate the code for correct responses from the Presentation log files
% need to change the path, string filter and start point
presLogDir = 'Presentation log files';
if ~isdir(presLogDir) % some dirs have different names for the log files
    presLogDir = [dataDir filesep sessionName filesep sessionName(2:end) '_Lennon'];
end
% Q: do they all start @ 5+
eventArray = readPresentationlog_correct_trial(presLogDir, ...
        'edit6_flanker_task_27_with_eye_tracker_12w2_and_eyeErr_', 5);

% resolve special cases
if strcmp(sessionName, 'L101008')
    eventArray(43,:) = []; % this correct trial did not send a juice event and
    % so is not found in Event010_5D. reason was deeply investigated but still 
    % unknown.
elseif strcmp(sessionName, 'L101014')
    eventArray(17,:) = []; % for some reason, both a correct sound and an
    % incorrect sound played for this trial, confusing it so that eventArray
    % at row 81 says "incorrect" instead of the trial type. looks like the
    % trial should be an incorrect one, so remove this trial.
    Event010_5D(109) = []; % there are no event times near this time, so it
    % looks like this was the only trial from this block, and a catch trial
    % too. the log must have been excluded, so remove this trial.
elseif strcmp(sessionName, 'L101119')
    eventArray(81,:) = []; % see the sound error in L101014 above
elseif strcmp(sessionName, 'L101012')
    Event010_5D(226:end) = []; % these are all catch trials which are not 
    % present in the logs. they would be removed anyway, but remove them
    % now so that the sizes of Event010_5D and eventArray are the same
elseif strcmp(sessionName, 'L101027')
    Event010_5D(183:end) = []; % see the catch trial error in L101012 above
end

testOddDecodingCases;

% get the indexes of all catch trials
catchInd = nan(size(eventArray,1),1); % pre-allocate
catchCount = 0;
for i = 1:size(eventArray,1)
    if strfind(eventArray(i,:), 'catch'); 
        catchCount = catchCount + 1;
        catchInd(catchCount) = i;
    end
end
catchInd(isnan(catchInd)) = []; % remove excess nans

% the two matrices should have the same # of trials. otherwise indexing
% will not work correctly.
assert(size(Event010_5D, 1) == size(eventArray, 1));

% remove the catch trials from Event010 and eventArray 
Event010_5D(catchInd) = [];
eventArray(catchInd,:) = [];

% output all of the required variables
decodeNeuroExplorerEvents(Event004_5D, Event005_5D, Event006_5D, Event007_5D, ...
        Event008_5D, Event009_5D, Event010_5D, Strobed_5D)

% update CueP1 to not have catch trials
decodeAdjustCueP1(Event010_5D, eventArray)
