function preprocLFP = removeTEOFromPreprocLfp(preprocLFP)

teoInd = 2;

for i = 1:numel(preprocLFP.postCleanByLoc)
    fn = fieldnames(preprocLFP.postCleanByLoc{i});
    for j = 1:numel(fn)
        preprocLFP.postCleanByLoc{i}.(fn{j})(:,:,teoInd) = [];
    end
end