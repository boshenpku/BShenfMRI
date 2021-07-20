function imghead = NORMALIZE(filepoolindv,lastimghead,VoxSize)
%% Normalization
prefix = ['www'];
imghead = [prefix lastimghead];
%% check to do task
todolist = {};
meanboldfile = {};
deffile = {};
for sessi = find(filepoolindv.nbehfile .* filepoolindv.nimgfile > 0)
    [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
    [d f e] = fileparts(commoncharacter);
    f = replaceWildcards(f,'**','*');
    meanboldfile = [meanboldfile; myfnames(fullfile(d,['mean*' f e]))];
    if numel(dir(fullfile(d,[imghead f e]))) < filepoolindv.nimgfile(sessi)
        todolist = [todolist; myfnames(fullfile(d,[lastimghead f e]))];
    end;
    deffile = [deffile; myfnames(fullfile(d,['y_mean*' f e]))];
end;
if numel(meanboldfile) > 1
    error('subj %s: there are 2 or more meanboldfiles',filepoolindv.subid);
elseif numel(meanboldfile) == 0
    error('subj %s: there is no meanboldfile',filepoolindv.subid);
end;
%% to do
if ~isempty(todolist)
    clear matlabbatch;
    %%
    if numel(deffile) == 1
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = deffile;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = todolist;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = VoxSize;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = prefix;
    else
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = meanboldfile;
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = todolist;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
        [d, ~, ~] = fileparts(which('spm'));
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {fullfile(d,'tpm','TPM.nii')};
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
        matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = VoxSize;
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = prefix;
    end;
    spm_jobman('run',matlabbatch);
end;
