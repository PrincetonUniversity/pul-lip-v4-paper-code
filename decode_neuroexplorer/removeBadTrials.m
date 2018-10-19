% % don't trim the sig; trim the events!!
% % oh but for the same session, the times that each cell is affected is not
% % the same.....
% 
% function trimmedSig = removeBadTrials(sessionName, newSpikeSigName, sig, CueP)
% 
% switch(sessionName)
%     case 'C110623'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % remove trials 41+ -- no spikes, cell lost
%         end
%         if strcmp(newSpikeSigName, 'sig1b')
%             % remove trials 1-40 -- clear change b/w trials 40, 41
%         end
%     case 'C110811'
%         if strcmp(newSpikeSigName, 'sig4a')
%             % remove trials 1-38
%         end
%     case 'L101013'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % major noise, increases in firing rate on certain trials
%         end
%         if strcmp(newSpikeSigName, 'sig4a')
%             % remove trials 1-75
%         end
%     case 'L101029'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % remove trials 120-150
%         end
%     case 'L101102'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % change point around trial 280
%         end
%     case 'L101105'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % major noise, increases in firing rate on certain trials
%         end
%     case 'L110411'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % reduction in firing rate around trial 35, remove 35+
%         end
%     case 'L110412'
%         % maybe worth combining sig1a and sig1b -- gap in firing in sig1a
%         % filled in sig1b, maybe poor spike sorting
%     case 'L110531'
%         if strcmp(newSpikeSigName, 'sig1a')
%             % remove trial 110+, increase in firing rate around then
%         end
%     case 'L110811'
%         if strcmp(newSpikeSigName, 'sig1c')
%             % remove trial 55+, reduction in firing rate around then
%         end
%         % note also sig1b has slight increase in firing rate around then
% end
% 
% 
% % remove part of sig between trimStartTrial and trimEndTrial, inclusive
% function sig = removeSigBetweenTrials(sig, CueP, trimStartTrial, trimEndTrial)
%     allCueTimes = CueP(:);
%     allCueTimes(isnan(allCueTimes) = [];
%     allCueTimes = sort(allCueTimes);
%     trimStartCueTime = allCueTimes(trimStartTrial);
%     trimEndCueTime = allCueTimes(trimEndTrial);
%     preCueAdjust = 0.2;
%     postCueAdjust = 0.2;
%     sig(sig >= (trimStartCueTime
% 
% 
% 
% 
% end