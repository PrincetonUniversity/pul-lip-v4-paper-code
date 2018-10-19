function checkArrayEvents(Event004, Event005, Event006, Event007, ...
        Event008_orig, Event009_orig, Event010_orig, eventArray)
% event004-7 is just for help debugging.

Event8 = [Event008_orig ones(length(Event008_orig),1)];
Event9 = [Event009_orig zeros(length(Event009_orig),1)];

Event89 = [Event8; Event9];

% sort by time (first column)
[~,i] = sort(Event89(:,1));
Event89 = Event89(i,:);

maxArrayToJuiceTime = 1.4;
Event10 = nan(length(Event010_orig),3);
for i = 1:numel(Event010_orig)
    % look for juice times that are more than 1.4 seconds after an event 8
    % or an event 9
    match = find(abs(Event010_orig(i) - Event89(:,1)) < maxArrayToJuiceTime & ...
            Event010_orig(i) - Event89(:,1) > 0);
    if ~isempty(match)
        % if associated array event is bowtie, put 1 in column 3
        % if associated array event is barrel, put 0 in column 3
        % column 2 has the array event time
        Event10(i,:) = [Event010_orig(i) Event89(match,1) Event89(match,2)];
    else
        % cannot find an associated array event
        % must be a catch trial - put 2 in column 3
        Event10(i,:) = [Event010_orig(i) -1 2];
    end
end

% go through each row (trial) of the presentation log event array
% mark the trial type (bowtie, barrel, or catch) in column 4
for i = 1:size(eventArray,1)
    if strcmp(strtrim(eventArray(i,:)), 'catch')
        Event10(i,4) = 2;
    elseif ~isempty(strfind(eventArray(i,:), 'RF bowtie')) || ...
            ~isempty(strfind(eventArray(i,:), 'cued bowtie at RF'))
        Event10(i,4) = 1;
    elseif ~isempty(strfind(eventArray(i,:), 'RF barrel')) || ...
            ~isempty(strfind(eventArray(i,:), 'cued barrel at RF'))
        Event10(i,4) = 0;
    else
        fprintf('Trial %d has unknown associated event name: %s\n', ...
                i, eventArray(i,:));
        Event10(i,4) = -1;
    end
end

% this will PRINT out any inconsistent trials
inconsistentTrials = find(Event10(:,3)-Event10(:,4));
numToText = {'Unknown', 'Barrel', 'Bowtie', 'Catch'}; % -1, 0, 1, 2
for i = 1:numel(inconsistentTrials)
    it = inconsistentTrials(i);
    
    % if could not find any array event within 1.4 seconds, print a
    % different warning
    if Event10(it,3) == 2
        match = find(Event010_orig(it) - Event89(:,1) > 0, 1, 'last');
        if isempty(match)
            warning(['Could not find any array event that might match '...
                    'juice event %d\n.'], it);
        else
            warning(['Juice event #%d has time from array event (event8/9) '...
                    'to juice event as %.4f seconds.\n Log says this juice '...
                    'event is %s.\n'], it, ...
                    Event010_orig(it) - Event89(match,1), ...
                    numToText{Event10(it,4) + 2});
        end
    else
        warning('Juice event %d is %s based on Events and %s based on Log.\n', ...
                it, numToText{Event10(it,3) + 2}, numToText{Event10(it,4) + 2});
    end
end
