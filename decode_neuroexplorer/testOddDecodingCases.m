% run during debugging mode before the assert in convertStimEventsSingleSession

Event8 = [Event008_5D ones(length(Event008_5D),1)];
Event9 = [Event009_5D zeros(length(Event009_5D),1)];

Event89 = [Event8; Event9];

% sort by time (first column)
[~,i] = sort(Event89(:,1));
Event89 = Event89(i,:);

maxArrayToJuiceTime = 1.4;
Event10 = nan(length(Event010_5D),3);
for i = 1:numel(Event010_5D)
    match = find(abs(Event010_5D(i) - Event89) < maxArrayToJuiceTime & ...
            Event010_5D(i) - Event89 > 0);
    if ~isempty(match)
        Event10(i,:) = [Event010_5D(i) Event89(match,1) Event89(match,2)];
    else
        Event10(i,:) = [Event010_5D(i) -1 2];
    end
end

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
        Event10(i,4) = -1;
    end
end

% this will print out any inconsistent trials
inconsistentTrials = find(Event10(:,3)-Event10(:,4));
if ~isempty(inconsistentTrials)
    disp('\nInconsistent trials (see testOddDecodingCases.m):');
    disp(inconsistentTrials);
end

%assert(inconsistentTrials,1));