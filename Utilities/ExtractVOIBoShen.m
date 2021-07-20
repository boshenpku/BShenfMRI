% % Extract VOI
clear;
clc;
% STEP 1: define your work dictory
raw_dir = '/data1/ShenBo/Guilt/YHB_Guilt_fMRI_RawData';
img_dir = '/data1/ShenBo/Guilt/NIFTI';
onset_dir = '/data1/ShenBo/Guilt/behavior/onsetlist1';
folderstruct_raw = dir(fullfile(raw_dir,'*guilt*'));
FunRaw_sublist = {};
for i = 1:length(folderstruct_raw)
    FunRaw_sublist{i} = folderstruct_raw(i).name;
end;
folderstruct = dir(fullfile(img_dir,'*guilt*'));
FunImg_sublist = {};
for i = 1:length(folderstruct)
    FunImg_sublist{i} = folderstruct(i).name;
end;
numsub = length(FunImg_sublist)
i = 100;
for sub = 1: numsub
    i = i + 1;
    while  isempty(dir(strcat(img_dir,'/*',num2str(i),'*')))
        i = i + 1;
    end;
    subid(sub) = i;
end;
%% VOI Extraction
FirstLevel_dir = '/data1/ShenBo/Guilt/FirstLevel13P';
seed.coord = [36,14,10;39,47,10;6,38,1;39,14,-5];
seed.name = {'rAI';'MidF';'mPFC';'rAI'};
seed.spmmat = {'/data1/ShenBo/Guilt/FirstLevel_Contrast13/Flexible_guilt/convention_flexible/SPM.mat'
    '/data1/ShenBo/Guilt/FirstLevel_Contrast13/Flexible_guilt/convention_flexible/SPM.mat'
    '/data1/ShenBo/Guilt/FirstLevel_Contrast13/Flexible_guilt/convention_flexible/SPM.mat'
    '/data1/ShenBo/Guilt/FirstLevel_Contrast13/Flexible_guilt/convention_flexible/SPM.mat'};
seed.contrast = [2 2 1 1];
for s = 1:length(seed.name)
    for sub = 1:numsub
        FirstLevel_path = fullfile(FirstLevel_dir,FunImg_sublist{sub});
        cd(FirstLevel_path);
        spmmat = fullfile(FirstLevel_path,'SPM.mat');
        existfile = dir(spmmat);
        if exist(FirstLevel_path,'dir') & length(existfile) == 1
            load(spmmat);
            for sess = 1:length(SPM.Sess)
                clear matlabbatch;
                matlabbatch{1}.spm.util.voi.spmmat = {spmmat};
                matlabbatch{1}.spm.util.voi.adjust = 1;
                matlabbatch{1}.spm.util.voi.session = sess;
                matlabbatch{1}.spm.util.voi.name = seed.name{s};
                matlabbatch{1}.spm.util.voi.roi{1}.sphere.centre = seed.coord(s,:);%[36 14 10];
                matlabbatch{1}.spm.util.voi.roi{1}.sphere.radius = 4;
                matlabbatch{1}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
                matlabbatch{1}.spm.util.voi.expression = 'i1';
                matlabbatch{2}.spm.util.print.fname = 'VOI';
                matlabbatch{2}.spm.util.print.opts.opt = {
                    '-dpsc2'
                    '-append'
                    }';
                matlabbatch{2}.spm.util.print.opts.append = true;
                matlabbatch{2}.spm.util.print.opts.ext = '.ps';
                spm_jobman('run',matlabbatch);
                clear matlabbatch;
                matlabbatch{1}.spm.stats.ppi.spmmat = {spmmat};
                matlabbatch{1}.spm.stats.ppi.type.ppi.voi = {sprintf('%s/VOI_%s_%i.mat',FirstLevel_path,seed.name{s},sess)};
                matlabbatch{1}.spm.stats.ppi.type.ppi.u = [2 1 -1
                    4 1 1];
                matlabbatch{1}.spm.stats.ppi.name = sprintf('%s_%i',seed.name{s},sess);
                matlabbatch{1}.spm.stats.ppi.disp = 1;
                spm_jobman('run',matlabbatch);
            end;
        end;
    end;
end;
