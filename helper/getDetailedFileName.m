function detailedFileName = getDetailedFileName(fileName)
% quick extracted fcn to get the name of the detailed spike file, given the
% name of the normal spike file, since it comes up a few times
% e.g. L110523_sig1a_5D_v10.mat -> L110523_sig1a_5D_v10_detailed.mat

detailedFileName = [fileName(1:end-4) '_detailed.mat'];
