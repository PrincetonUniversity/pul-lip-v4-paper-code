function fileName = getFileName(filePath)

[~,name,ext] = fileparts(filePath);
fileName = [name ext];