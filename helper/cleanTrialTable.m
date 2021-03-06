function TrialTable = cleanTrialTable(sessionName, newSpikeSigName, TrialTable)
% Remove trials for particular sessions and particular cells due to lost cells,
% unusual noise, or other reasons (see each session and cell below). Similar to 
% cleanEventTimes.m, but removing trials out of TrialTable instead of a vector
% of eventTimes. 
% 
% sessionName - 7-character name of the session, e.g. C110623, L101215
% newSpikeSigName - 5-character name of the cell, e.g. sig1a, sig4c
% TrialTable - table of the session's trials, including column CuePi which is 
% the cue onset time for each trial (row in the table)
%
% Output:
%  TrialTable - table of the session's trials, with trials removed if the 
%  session name and newSpikeSigName match a condition in this script

if strcmp(sessionName, 'C110623') && strcmp(newSpikeSigName, 'sig1a')
    % lost cell from trial 42 and onward. remove those trials for this cell 
    % only. the 42nd trial cue onset time is 234.8507.
    assert(size(TrialTable,1) == 140);
    TrialTable = TrialTable(TrialTable.CuePi < 234.8, :);
    assert(size(TrialTable,1) == 41);
    
elseif strcmp(sessionName, 'L101013') && strcmp(newSpikeSigName, 'sig1a')
    % there are trials with extremely high firing dispersed throughout the
    % session. the cell may have been dying. it would be difficult to
    % remove these trials. instead, just remove trials after it appears
    % that the cell was lost, from trial 269 onward. the last spike in the
    % window of 100ms before cue onset to 400ms after cue onset occurs on
    % trial 268. the 268th trial cue onset time is 2052.6774.
    assert(size(TrialTable,1) == 309);
    TrialTable = TrialTable(TrialTable.CuePi < 2052.6, :);
    assert(size(TrialTable,1) == 268);
    
    % using these remaining 268 trials, look for outlier firing patterns,
    % using the window of 100ms before cue onset to 400ms after cue onset.
    % remove trials where the number of spikes is > mean + 3.29 standard
    % deviations (which, assuming normality in the spike count
    % distribution, removes trials that have a spike count outside of the
    % central 99.9% of the population)
    
    % mean number of spikes in window: 3.455
    % stdev: 6.083
    % positive end threshold: 23.471
    % this removes 9 trials with counts:
    % 25    26    34    26    31    30    29    25    24
    % which are trial indices: 
    % 83    84    96    97   179   181   182   187   189
    
    % since it seems like there are periods where there is unusual firing,
    % remove the entire periods: trial 83-84, 96-97, 179-182, 187-189. this 
    % translates to cue onset times of:
    % 707.2103 to 710.2079 (cue time 85 = 718.4813) and 
    % 882.1940 to 887.3398 (cue time 98 = 890.6971) and
    % 1508.9849 to 1520.9454 (cue tinme 183 = 1524.1229) and
    % 1554.2288 to 1560.7034 (cue time 256 = 1566.9385)
    
    TrialTable = TrialTable(~((TrialTable.CuePi > 706.7 & TrialTable.CuePi < 718) | ...
            (TrialTable.CuePi > 881.7 & TrialTable.CuePi < 890.2) | ...
            (TrialTable.CuePi > 1508.5 & TrialTable.CuePi < 1523.6) | ...
            (TrialTable.CuePi > 1553.7 & TrialTable.CuePi < 1566.4)), :);
    assert(size(TrialTable,1) == 257);
    
    % note that this leaves a few trials with still unusually high firing,
    % e.g. around original trial number 174. but it is not as bad.
    
elseif strcmp(sessionName, 'L101029') && strcmp(newSpikeSigName, 'sig1a')
    % most of the firing occurs between trials 110 and 150. as there is
    % still firing on the other trials and the difference does not appear
    % that substantial, do not modify the session.
    
elseif strcmp(sessionName, 'L101105') && strcmp(newSpikeSigName, 'sig1a')
    % there are trials with extremely high firing dispersed throughout the
    % session. the cell may have been dieing. look at the distribution of
    % number of spikes in the window of 100ms before cue onset to 400ms
    % after cue onset. remove trials where the number of spikes is > mean +
    % 3.29 standard deviations (which, assuming normality in the spike
    % count distribution, removes trials that have a spike count outside of
    % the central 99.9% of the population)
    
    % mean number of spikes in window: 1.4929
    % stdev: 3.3
    % positive end threshold: 12.35
    % this removes 8 trials with counts:
    % 19    15    17    29    36    13    19    14
    % which are trial indices: 
    % 148   149   152   153   154   247   254   255
    
    % since it seems like there are two periods where there is unusual firing,
    % remove the entire periods: trial 148-154 and trial 247-255. this 
    % translates to cue onset times of:
    % 940.5589 to 971.4440 (cue time 155 = 974.7714) and 
    % 1537.6942 to 1578.5714 (cue time 256 = 1581.5892)
    assert(size(TrialTable,1) == 420);
    TrialTable = TrialTable(~((TrialTable.CuePi > 940 & TrialTable.CuePi < 974.2) | ...
            (TrialTable.CuePi > 1537.2 & TrialTable.CuePi < 1581.1)), :);
    assert(size(TrialTable,1) == 404);
    
    % note that this leaves a few trials with still unusually high firing,
    % e.g. around original trial number 146. but it is not as bad.
    
elseif strcmp(sessionName, 'L110411') && strcmp(newSpikeSigName, 'sig1a')
    % seem to have lost cell from trial 95 and onward, and probably
    % earlier. there is a sharp decline in firing from trial 38 and onward.
    % the 38th trial cue onset time is 318.3454.
    assert(size(TrialTable,1) == 137);
    TrialTable = TrialTable(TrialTable.CuePi < 317.8, :);
    assert(size(TrialTable,1) == 37);
    
% elseif strcmp(sessionName, 'L110412') && strcmp(newSpikeSigName, 'sig1a')
    % trials ~33-37 have extremely low firing. as this is a small subset of the 
    % total 152 trials, do not modify the session.
    
% elseif strcmp(sessionName, 'L110412') && strcmp(newSpikeSigName, 'sig1b')
    % there are trials with high firing dispersed throughout the session.
    % the cell may have been dying. it would be difficult to remove these
    % trials.
    
% elseif strcmp(sessionName, 'L110811') && strcmp(newSpikeSigName, 'sig1c')
    % there is a sharp drop in firing rate from around trial 51 onward, but 
    % there is still some firing after that that does not look like noise 
    % (it is preferential to the delay period), so do not modify this session.
end
