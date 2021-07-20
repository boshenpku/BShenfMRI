  
function ButtonName = CheckData(finalpath,subjnames,sessnames)
subjsesslistprint = [];
for subj = 1:numel(subjnames)
    subjname = subjnames{subj};
    subjsesslistprint = [subjsesslistprint '\n' subjname];
    for sessi = 1:numel(sessnames)
        sessname = sessnames{sessi};
        filename = replaceWildcards(finalpath,'[[subjname]]',subjname,'[[sessname]]',sessname);
        if exist(filename, 'file')
            subjsesslistprint = [subjsesslistprint '\t' sessname];
        elseif exist(filename,'dir')
            nfiles = dir(filename);
            subjsesslistprint = [subjsesslistprint '\t' sessname ' ' num2str(numel(nfiles)) 'files'];    
        end;
    end;
end;
ButtonName = questdlg(sprintf(['请逐个确认您的实验数据' sesslistprint]), ...
                         'Confirm Dialog', 'Yes');
return;