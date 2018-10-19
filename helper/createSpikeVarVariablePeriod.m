function data = createSpikeVarVariablePeriod(sessionName, newSpikeSigName, ...
        spikeTimeVarName, sig, E, windows)
% creates variable with spike times time-locked to cue onset, including
% spikes from a specified time before cue onset to a specified time after
% array onset

cueTimes = unpackEventVar(E, spikeTimeVarName, 1);
arrTimes = unpackEventVar(E, spikeTimeVarName, 2);

cueTimes = cleanEventTimes(sessionName, newSpikeSigName, cueTimes);
arrTimes = cleanEventTimes(sessionName, newSpikeSigName, arrTimes);

if numel(cueTimes) ~= numel(arrTimes)
    error(['Expected same '...
            'number of cue presentations as array '...
            'presentations, which is required in order '...
            'to find all the spikes between the cue and '...
            'array on each trial']);
end

myWindow = windows(spikeTimeVarName.window);
beforeCueTime = myWindow(1);
afterArrTime = myWindow(2);
if ~isempty(cueTimes)
    data = fixedExtractdatapt(sig, [cueTimes-beforeCueTime arrTimes+afterArrTime], 1);
else
    data = struct([]);
end

delayDurs = arrTimes - cueTimes;
for k = 1:numel(data)
    data(k).delayDur = delayDurs(k);
end