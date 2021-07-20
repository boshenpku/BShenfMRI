% Paired Ssample T Test
clear all;
% PECIFY SECOND MODEL
FolderPath = 'E:\ShenBo\GR\Model\FirstLevel';
SourcePath1 = 'E:\ShenBo\GR\Model\SecondLevel\PPI\1_rAI_C2_Sh_S-O';
SourcePath2 = 'E:\ShenBo\GR\Model\SecondLevel\PPI\1_rAI_C3_Sh_S-O';
OutputPath = 'E:\ShenBo\GR\Model\SecondLevel\PPI\PairedSampleTrAIShC2C3\';
mkdir(OutputPath);
SubList = dir(fullfile(FolderPath,'2*'));
% contrast_dir = {};
blacklist = [1 11 14 19 47 55];
SubList(blacklist) = [];
matlabbatch{1}.spm.stats.factorial_design.dir = {OutputPath};
for i = 1:length(SubList)% number of subject
    contrast_folder = dir(fullfile(SourcePath1,[SubList(i).name '*con*.img']));
    filepair{1} = fullfile(SourcePath1,contrast_folder.name);
    contrast_folder = dir(fullfile(SourcePath2,[SubList(i).name '*con*.img']));
    filepair{2} = fullfile(SourcePath2,contrast_folder.name);
    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(i).scans = filepair;
end;
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'E:\ShenBo\GR\batch\rMask_withoutCerebelum.nii,1'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm_jobman('run',matlabbatch);
%% estimate model
clear matlabbatch;
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(OutputPath,'SPM.mat')};
spm_jobman('run',matlabbatch);
%% define contrasts
SPMest=load(fullfile(OutputPath,'SPM.mat'));
SPMest=SPMest.SPM;
second_level_contrast = {['PPI_pos_'],['PPI_neg_']};
SPMest.xCon = [];
SPMest.xCon    = spm_FcUtil('Set',second_level_contrast{1}, 'T','c',[zeros(1,length(SubList)) 1 -1]',SPMest.xX.xKXs);
SPMest.xCon(2) = spm_FcUtil('Set',second_level_contrast{2}, 'T','c',[zeros(1,length(SubList)) -1 1]',SPMest.xX.xKXs);
spm_contrasts(SPMest);