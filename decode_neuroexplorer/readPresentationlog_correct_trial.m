function array=readPresentationlog_correct_trial(filepath,filter,startnumber)
%
% filepath: main file path for those log files
% filter: the string part of log files, like 'edit6_flanker_task_27_with_eye_tracker_12w2_and_eyeErr_'
% startnumber: the start point for the first log file (those number must be continuous), like 5.
% The file name will be [filter startnumber], like 'edit6_flanker_task_27_with_eye_tracker_12w2_and_eyeErr_5'
%
% array: the code for correct responses, corresponding to Event010 in the
% same order
%
P = pwd;
cd(filepath);
logfile=dir('*.log');
sortfile=[];
count=0;
while count<length(logfile)*5 % NOTE: clean me up
    if exist([filter num2str(startnumber+count) '.log'],'file')
        sortfile=char(sortfile,[filter num2str(startnumber+count) '.log']);
    end
    count=count+1;
end
sortfile(1,:)=[];
array=[];
for ifile=1:size(sortfile,1)
    fid = fopen(deblank(sortfile(ifile,:)), 'r+');
    % read the first 5 rows to change the point location
    L = 5;
    for irow = 1:L, fgetl(fid); end
    while 1
        tline = fgetl(fid);
        if strcmp(tline, ''),
            break,
        end
    end
    fgetl(fid); % read empty line
    % p = ftell(fid);
    % fseek(fid,p,'bof');
    % names = textscan(fgetl(fid), '%s',12,'delimiter', '\t'); % read title line
    fgetl(fid); % read empty line
    data = textscan(fid, '%s %s %s %d %d %d %d %d %d %d %d %s', 'delimiter', '\t');
    fclose(fid);
    nrow = size(data{1},1);
    ntrial = 0;
    for irow = 1:nrow
        if strcmp(data{1,2}{irow},'correct')
            ntrial = ntrial +1;
            if ~isempty(data{1,2}{irow-1})
                array=char(array,data{1,2}{irow-1});
            elseif ~isempty(data{1,2}{irow-2})
                array=char(array,data{1,2}{irow-2});
            else
                array=char(array,'EMPTY');
            end
        end
    end
end
array(1,:)=[];
cd(P)