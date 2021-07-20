function imghead = SMOOTH(filepoolindv,lastimghead)
%% Smooth
prefix = ['zzz'];
imghead = [prefix lastimghead];
%% check to do task
todolist = {};
for sessi = find(filepoolindv.nbehfile .* filepoolindv.nimgfile > 0)
    [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
    [d f e] = fileparts(commoncharacter);
    f = replaceWildcards(f,'**','*');
    if numel(dir(fullfile(d,[imghead f e]))) < filepoolindv.nimgfile(sessi)
        todolist = [todolist; myfnames(fullfile(d,[lastimghead f e]))];
    end;
end;
%% to do
if ~isempty(todolist)
    clear matlabbatch;
    %%
    matlabbatch{1}.spm.spatial.smooth.data = todolist;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = prefix;
    spm_jobman('run',matlabbatch);
end;