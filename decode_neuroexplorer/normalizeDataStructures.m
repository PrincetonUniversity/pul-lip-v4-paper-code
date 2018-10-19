% dataPath:
%   e.g. 'D:\Documents\MATLAB\flanker_task_analysis\data\example\L110523'
%   should have '5D and 0D' (optional), 'lfps', and/or 'spikes' directories
%   within and L110523 should be the session name

% this script creates 4 new .mat files in the session data root:
% - {sessionName}_events.mat, which contains the variables 
%   Start, Stop, Event0**_5D, Event0**_0D, Strobed_5D, and Strobed_0D where 
%   ** = 03-10. if there is a 5D and 0D lfps.mat file, then these event
%   variables derive from there (Event0**_0D & Strobed_0D are copied
%   directly, whereas Event0**5D & Strobed_5D are copied from Event0** and
%   Strobed which are confusingly the 5D variable names). if there is no 5D
%   and 0D directory, then the generated events.mat file contains only
%   Start, Stop, Event0**5D, and Strobed_5D, which are copied from Event0**
%   and Strobed from the lfps.mat file in the lfps directory
%
% - {sessionName}_lfpsOnly.mat, which contains the variables
%   AD0*, AD0*_ts, AD0*_ind where * = 1-4. these data come from the
%   lfps/{sessionName}_lfps.mat file
%
% - {sessionName}_otherAD.mat, which contains the variables
%   AD**, AD**_ts, AD**_ind where ** = 17-19. these data come from the
%   lfps/{sessionName}_lfps.mat file
%
% - {sessionName}_allSpikes.mat, which contains the variables 
%   sig0** where the first * is 1-4, representing the area recorded from
%   (PUL=1, TEO=2, LIP=3, V4=4) and the second * is a letter (a-e)
%   distibguishing different isolated neurons. these data come from the
%   spikes/{areaName}/{sessionName}_spikes.mat files

function normalizeDataStructures(dataPath)

if dataPath(end-1:end) ~= filesep
    dataPath = [dataPath filesep];
end

% assumes 7 chars in session name
sessionName = dataPath(length(dataPath)-7:length(dataPath)-1);
fiveDZeroDDir = [dataPath '5D and 0D' filesep];
lfpsDir = [dataPath 'lfps' filesep];
spikesDir = [dataPath 'spikes' filesep];
areaNames = {'PUL', 'TEO', 'LIP', 'V4'}; % sub dirs of spikesDir, in order
% of spike signal indexing

newEventMatFile = [dataPath sessionName '_events.mat'];
newLFPsMatFile = [dataPath sessionName '_lfpsOnly.mat'];
otherADDataMatFile = [dataPath sessionName '_otherAD.mat'];
newSpikesMatFile = [dataPath sessionName '_allSpikes.mat'];
% could split lfps/spikes by area name but the files are small enough, that
% this isn't necessary yet. maybe later.


lfpVars = {'AD01', 'AD01_ts', 'AD01_ind', 'AD02', 'AD02_ts', 'AD02_ind', ...
        'AD03', 'AD03_ts', 'AD03_ind', 'AD04', 'AD04_ts', 'AD04_ind'};
otherADVars = {'AD17', 'AD17_ts', 'AD17_ind', 'AD18', 'AD18_ts', ...
        'AD18_ind', 'AD19', 'AD19_ts', 'AD19_ind'};

expectedEventBlockVars = {'Start', 'Stop'};
% these will be renamed to have _5D at the end
expectedEvent5DPreVars = {'Event003', 'Event004', ...
        'Event005', 'Event006', 'Event007', 'Event008', 'Event009', ...
        'Event010', 'Strobed'};
expectedEvent5DPostVars{numel(expectedEvent5DPreVars)} = [];
postVarCount = 1;

% list the 0D variables which should already exist, when applicable
expectedEvent0DVars{numel(expectedEvent5DPreVars)} = [];
for i = 1:numel(expectedEvent5DPreVars)
    expectedEvent0DVars{i} = [expectedEvent5DPreVars{i} '_0D'];
end

% all these variables should be in the 5D & 0D lfps.mat file
expectedEvent5D0DVars = [expectedEventBlockVars expectedEvent5DPreVars{:} ...
        expectedEvent0DVars{:}];

% HANDLE THE LFP DATA

if isdir(lfpsDir)
    % process L110810 specially -- no lfp data but spike data
    if ~strcmp(sessionName, 'L110810')
        lfpsMatFile = [lfpsDir sessionName '_lfps.mat'];
    else
        lfpsMatFile = [spikesDir 'L110810_spikes.mat'];
    end
    L = load(lfpsMatFile);
    
    if ~strcmp(sessionName, 'L110810')
        % make sure all LFP variables are found in the _lfps.mat file, else  
        % throw error
        for i = 1:numel(lfpVars)
            if ~isfield(L, lfpVars{i})
%                 if strcmp(lfpVars{i}(1:4), 'AD01') ~= 1
                    warning('flanker_task_analysis:missingVar', ...
                            'Missing variable %s from file %s... OK', ...
                            lfpVars{i}, lfpsMatFile);
                    lfpVars{i} = ''; % don't try to save this var later
%                 else
%                     error('flanker_task_analysis:missingVar', ...
%                             'Missing variable %s from file %s', ...
%                             lfpVars{i}, lfpsMatFile);
%                 end
            end
        end

        % save AD0*, AD0*_ts, AD0*_ind where * = 1-4
        save(newLFPsMatFile, '-struct', 'L', lfpVars{:});
    end
    
    % make sure all non-LFP AD variables are found in the _lfps.mat file,  
    % else throw error
    for i = 1:numel(otherADVars)
        if ~isfield(L, otherADVars{i})
            error('flanker_task_analysis:missingVar', ...
                    'Missing variable %s from file %s', ...
                    otherADVars{i}, lfpsMatFile);
        end
    end
    
    % save AD**, AD**_ts, AD**_ind where ** = 17-19
    save(otherADDataMatFile, '-struct', 'L', otherADVars{:});
    
    
    % save Event0** and Strobed as Event0**_5D and Strobed_5D
    % if there are 0D trials, copy those (they are already named
    % Event0**_0D and Strobed_0D)
    % if there are 0D trials, then the Event0** and Strobed variables in
    % the lfps/{sessionName}_lfps.mat file contain BOTH 5D and 0D trials.
    % so we need to copy those from the '5D and 0D'/{sessionName}_lfps.mat
    % file, where they have been separated.
    % L110426, etc. have '5D and 0D' dir but no 0D data
    if isdir(fiveDZeroDDir) && ~strcmp(sessionName, 'L110426') && ...
            ~strcmp(sessionName, 'L110502') && ~strcmp(sessionName, 'L110503') && ...
            ~strcmp(sessionName, 'L110504')
        % process L110810 specially -- no lfp data but spike data
        if ~strcmp(sessionName, 'L110810')
            lfpsMatFile = [fiveDZeroDDir sessionName '_lfps.mat'];
        else
            lfpsMatFile = [spikesDir 'L110810_spikes.mat'];
        end
        Z = load(lfpsMatFile); 

        % confirm that the expected event variables exist!
        % and if they do exist, rename them appropriately
        for i = 1:numel(expectedEvent5D0DVars)
            if ~isfield(Z, expectedEvent5D0DVars{i})
                error('flanker_task_analysis:missingVar', ...
                        'Missing variable %s from file %s', ...
                        expectedEvent5D0DVars{i}, lfpsMatFile);
            elseif ismember(expectedEvent5D0DVars{i}, expectedEvent5DPreVars)
                % rename variable to have _5D at end
                newVar = [expectedEvent5D0DVars{i} '_5D'];
                Z.(newVar) = Z.(expectedEvent5D0DVars{i});
                Z = rmfield(Z, expectedEvent5D0DVars{i});
                % save the new name
                expectedEvent5DPostVars{postVarCount} = newVar;
                postVarCount = postVarCount + 1;
            end
        end

        % save only Start, Stop, Event0**_5D, Event0**_0D, Strobed_5D,
        % Strobed_0D vars into the event .mat where ** = 03-10
        eventVars = [expectedEventBlockVars expectedEvent5DPostVars{:} ...
                expectedEvent0DVars{:}];
        save(newEventMatFile, '-struct', 'Z', eventVars{:});


        % verify that the LFP vars are the same between the two 
        % {sessionName)_lfps.mat files
        if ~strcmp(sessionName, 'L110810')
            for i = 1:numel(lfpVars)
                if ~isempty(lfpVars{i}) && ...
                        ~(all(L.(lfpVars{i}) == Z.(lfpVars{i})))
                    error('flanker_task_analysis:lfpsNoMatch',...
                            ['LFP %s in the "lfps" and "5D and 0D" dirs'...
                            ' do not match!'], lfpVars{i});
                end
            end
        end

        % verify that the other AD vars are the same between the two 
        % {sessionName)_lfps.mat files
        for i = 1:numel(otherADVars)
            if ~(all(L.(otherADVars{i}) == Z.(otherADVars{i})))
                error('flanker_task_analysis:lfpsNoMatch',...
                        ['AD signal %s in the "lfps" and "5D and 0D"'...
                        'dirs do not match!'], otherADVars{i});
            end
        end

        % could also confirm that sort([Event003_5D Event003_0D]) is the 
        % same as Event003 in {sessionName}_lfps.mat
    else
        % there are only 5D trials
        % confirm that the expected event variables exist!
        % and if they do exist, rename them appropriately
        for i = 1:numel(expectedEvent5DPreVars)
            if ~isfield(L, expectedEvent5DPreVars{i})
                error('flanker_task_analysis:missingVar', ...
                        'Missing variable %s from file %s', ...
                        expectedEvent5DPreVars{i}, lfpsMatFile);
            else
                % rename variable to have _5D at end
                newVar = [expectedEvent5DPreVars{i} '_5D'];
                L.(newVar) = L.(expectedEvent5DPreVars{i});
                L = rmfield(L, expectedEvent5DPreVars{i});
                % save the new name
                expectedEvent5DPostVars{postVarCount} = newVar;
                postVarCount = postVarCount + 1;
            end
        end
        
        % save only Start, Stop, Event0**_5D, Strobed_5D vars into the 
        % event .mat where ** = 03-10
        eventVars = [expectedEventBlockVars expectedEvent5DPostVars{:}];
        save(newEventMatFile, '-struct', 'L', eventVars{:});
    end
end


% HANDLE THE SPIKE DATA

% delete this file if it exists so that appending is safe
if exist(newSpikesMatFile, 'file')
    delete(newSpikesMatFile);
end

if isdir(spikesDir)
    for i = 1:numel(areaNames)
        spikesSubDir = [spikesDir areaNames{i} filesep];
        if isdir(spikesSubDir)
            % these are all 5D trials
            spikesMatFile = [spikesSubDir sessionName '_spikes.mat'];
            S = load(spikesMatFile);
            foundSpikeSigs = findSpikeSigs(S, i);
            if exist(newSpikesMatFile, 'file')
                save(newSpikesMatFile, '-struct', 'S',...
                    foundSpikeSigs{:}, '-append');
            else
                save(newSpikesMatFile, '-struct', 'S', foundSpikeSigs{:});
            end
            
            % could also confirm that Event003 is the same
            % as Event003_5D in '5D and 0D'/{sessionName}_lfps.mat and 
            % as Event003 in lfps/{sessionName}_lfps.mat
            
            % could also look at 0D file but it should be the same
        end
    end
    
    foundSpikeSigs1 = {};
    for i = [1 3 4]
        spikesSubDir = [spikesDir areaNames{i} filesep];
        if isdir(spikesSubDir)
            % these are all 5D trials
            spikesMatFile = [spikesSubDir sessionName '_spikes.mat'];
            S = load(spikesMatFile);
            for j = [1 3 4]%1:numel(areaNames)
                foundSpikeSigs = findSpikeSigs(S, j);
                foundSpikeSigs1 = [foundSpikeSigs1 foundSpikeSigs];
            end
        end
    end
    if exist(newSpikesMatFile, 'file')
        foundSpikeSigs2 = {};
        S2 = load(newSpikesMatFile);
        for j = [1 3 4]%1:numel(areaNames)
            foundSpikeSigs = findSpikeSigs(S2, j);
            foundSpikeSigs2 = [foundSpikeSigs2 foundSpikeSigs];
        end
        uniqueSpikeSigs1 = unique(foundSpikeSigs1);
        uniqueSpikeSigs2 = unique(foundSpikeSigs2);
        if ~(isempty(setdiff(uniqueSpikeSigs1, uniqueSpikeSigs2)) && isempty(setdiff(uniqueSpikeSigs2, uniqueSpikeSigs1)))
            fprintf('\n');
            disp(uniqueSpikeSigs1)
            disp(uniqueSpikeSigs2)
            warning('%s has non-matching spike sig variables', sessionName);
        end
    end
end
