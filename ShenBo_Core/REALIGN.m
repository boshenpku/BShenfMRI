function imghead = REALIGN(filepoolindv,lastimghead,headmovedir)
%% Realign
prefix = ['rrr'];
imghead = [prefix lastimghead];
%% check to do task
redo = 0;
for sessi = find(filepoolindv.nbehfile .* filepoolindv.nimgfile > 0)
    [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
    [d f e] = fileparts(commoncharacter);
    f = replaceWildcards(f,'**','*');
    if numel(dir(fullfile(d,[imghead f e]))) < filepoolindv.nimgfile(sessi)
        redo = 1;
    end;
end;
todolist = {};
if redo == 1
    for sessi = find(filepoolindv.nbehfile .* filepoolindv.nimgfile > 0)
        [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
        [d f e] = fileparts(commoncharacter);
        f = replaceWildcards(f,'**','*');
        todolist{end+1} = myfnames(fullfile(d,[lastimghead f e]));
    end;
end;

%% to do
if ~isempty(todolist)
    crtdir = pwd;
    cd(headmovedir);
    clear matlabbatch;
    matlabbatch{1}.spm.spatial.realign.estwrite.data = todolist';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % realign to mean
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = prefix;
    spm_jobman('run',matlabbatch);
    cd(crtdir);
end;

