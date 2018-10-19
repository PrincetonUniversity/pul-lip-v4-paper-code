function [fiveDNames, zeroDFiveDNames] = getSpikeSessionNames(areaName)
% Returns hardcoded names of sessions that have spiking data. Should
% correspond to names of directories in the data root directory.
% Input:
%   - areaName: 'PUL', 'LIP', or 'V4'
% Output: 
%   - fiveDNames: list of session names where there is only 5 distractor data
%   - zeroDFiveDNames: list of sesssion names where there are both 0-distractor
%                      and 5-distractor data

if strcmp(areaName, 'LIP')
    fiveDNames = {'L101222', 'L101221', 'L101216',...
            'L101215', 'L101214', 'L101209', 'L101208', 'L101105',...
            'L101029', 'L101027', 'L101025', 'L101022',...
            'L101020', 'L101019', 'L101018', 'L101008',...
            'C110601', 'C110531', 'L110519'};
    zeroDFiveDNames = {'C110617', 'C110727', 'C110811', 'C110812',...
            'L110523', 'L110524', 'L110531'};
    
elseif strcmp(areaName, 'V4')
    fiveDNames = {'L101222', 'L101221', 'L101216', ...
            'L101215', 'L101209', 'L101208', 'L101124', 'L101119', 'L101105', ...
            'L101103', 'L101029', 'L101022', 'L101021', 'L101020', 'L101019', ...
            'L101014', 'L101013', 'L101012', 'L101011', 'L101008', 'L101007', ...
            'L110519'};
    zeroDFiveDNames = {'C110727', 'C110728', 'C110811', 'L110524'}; % removed for now: 'L110519'
    
elseif strcmp(areaName, 'PUL')
    fiveDNames = {'C110623', 'C110721', 'L101008', ...
            'L101013', 'L101014', 'L101019', 'L101020', 'L101029', 'L101102', ...
            'L101103', 'L101105', 'L101119', 'L101123', 'L101124', 'L101208', ...
            'L101209', 'L101214', 'L101215', 'L101222', 'L110411', 'L110412', ...
            'L110413', 'L110414', 'L110419', 'L110420', 'L110421', 'L110422', ...
            'L110429', 'L110519'};
    zeroDFiveDNames = {'C110713', 'C110720', 'C110722', 'C110728', 'C110804',...
            'C110809', 'C110811', 'C110812', 'L110523', 'L110524', 'L110531',...
            'L110711', 'L110810', 'L110811', 'L110812'};
    % NOTE: there's no LFP data for 'L110810' but spike data (Yuri confirmed)
    
else
    warning('Unknown area name: %s', areaName);
end

