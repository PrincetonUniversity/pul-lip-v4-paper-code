function createSpikeStatsAll(S, doOverwriteFiles, workspaceFilePath)

fprintf('Computing more detailed spike data...\n');
S.spikeFilesDetailedAll = cell(size(S.spikeFilesAll));

spikeStatsAll = cell(size(S.spikeFilesAll));

for i = 1:numel(S.spikeFilesAll)
    spikeFilePath = S.spikeFilesAll{i};
    fprintf('Processing %s (%d/%d): ', getFileName(spikeFilePath), i, numel(S.spikeFilesAll));
    
    detailedSpikeFilePath = getDetailedFileName(spikeFilePath);

    if ~doOverwriteFiles && exist(detailedSpikeFilePath, 'file') == 2
        fprintf('%s already exists, skipping\n', getFileName(detailedSpikeFilePath));
        continue;
    end
    
    spikeStats = createSpikeStats(S, spikeFilePath);
    
    save(detailedSpikeFilePath, 'spikeStats');
    fprintf('saved in %s\n', getFileName(detailedSpikeFilePath));
    
    spikeStatsAll{i} = spikeStats;
    S.spikeFilesDetailedAll{i} = detailedSpikeFilePath;
end

if ~doOverwriteFiles && exist(workspaceFilePath, 'file') == 2
    fprintf('Not overwriting detailed workspace file.\n');
else
    save(workspaceFilePath, 'S', 'spikeStatsAll');
    fprintf('Done. Detailed workspace file saved to %s.\n', getFileName(workspaceFilePath));
end