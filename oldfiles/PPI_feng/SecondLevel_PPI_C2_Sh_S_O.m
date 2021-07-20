clear all;
%% PECIFY SECOND MODEL
FolderPath = 'E:\ShenBo\GR\Model\FirstLevel';
OutputPath = 'E:\ShenBo\GR\Model\SecondLevel\PPI\1_rAI_C2_Sh_S-O';
SubList = dir(fullfile(FolderPath,'2*'));
% contrast_dir = {};
blacklist = [1 11 14 19 47 55];
SubList(blacklist) = [];
% for nsub = 1:length(SubList)
%     ContrastList = dir(fullfile(FolderPath,SubList(nsub).name,'contrast*'));
%     for ncon = 1:length(ContrastList)
%         contrast_dir{ncon,nsub} = fullfile(FolderPath,SubList(nsub).name,ContrastList(ncon).name);
%     end
% end
%%
result_report.contrast = [1 1 1 1 2 2 2 2]; 
result_report.threshdesc = {'FWE' 'none' 'none' 'none' 'FWE' 'none' 'none' 'none'};  
result_report.thresh = [0.05 0.001 0.005 0.005 0.05 0.001 0.005 0.005]; 
result_report.extent = [0 17 27 73 0 17 27 73];  

% for c = 1:size(contrast_dir,1)
%% specify model
    spm fmri;
    second_dir = OutputPath;
    clear contrast_flielist;
    for i = 1:length(SubList)% number of subject
        contrast_folder = dir(fullfile(second_dir,[SubList(i).name '*con*.img']));
        contrast_flielist{i} = fullfile(second_dir,contrast_folder.name);
    end
    clear matlabbatch;
    matlabbatch{1}.spm.stats.factorial_design.dir = {second_dir};
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = contrast_flielist;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    %matlabbatch{1}.spm.stats.factorial_design.masking.tm.tma.athresh = 0.1;
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'E:\ShenBo\GR\batch\rMask_withoutCerebelum.nii'}; % white matter mask...
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    spm_jobman('run',matlabbatch); 
%% estimate model
    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(second_dir,'SPM.mat')};
    spm_jobman('run',matlabbatch);
%% define contrasts
    SPMest=load(fullfile(second_dir,'SPM.mat'));
    SPMest=SPMest.SPM;
    second_level_contrast = {['PPI_pos_'],['PPI_neg_']};
    SPMest.xCon = [];
    SPMest.xCon    = spm_FcUtil('Set',second_level_contrast{1}, 'T','c',[1]',SPMest.xX.xKXs);
    SPMest.xCon(2) = spm_FcUtil('Set',second_level_contrast{2}, 'T','c',[-1]',SPMest.xX.xKXs);
    spm_contrasts(SPMest);
%% result report spm
    for i = 1:length(result_report.contrast)
        clear matlabbatch;
        matlabbatch{1}.spm.stats.results.spmmat = {fullfile(second_dir,'SPM.mat')};
        matlabbatch{1}.spm.stats.results.conspec.titlestr = second_level_contrast{result_report.contrast(i)};
        matlabbatch{1}.spm.stats.results.conspec.contrasts = result_report.contrast(i);
        matlabbatch{1}.spm.stats.results.conspec.threshdesc = char(result_report.threshdesc{i});
        matlabbatch{1}.spm.stats.results.conspec.thresh = result_report.thresh(i);
        matlabbatch{1}.spm.stats.results.conspec.extent = result_report.extent(i);
        matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
        matlabbatch{1}.spm.stats.results.units = 1;
        matlabbatch{1}.spm.stats.results.print = true;
        spm_jobman('run',matlabbatch);
        save_spm_results(xSPM,hReg)
    end
    close('all');
%% result report xjview
    xjview_dir = dir([con_name,'*.img']);
    for i = 1:length(xjview_dir)
        rest_sliceviewer_ljt('ShowOverlay', fullfile(second_dir,xjview_dir(i).name));
        rest_sliceviewer_ljt('Overlay_SetThrdAbsValue_LJT',1,0.05);%set p
        rest_sliceviewer_ljt('Overlay_SetThrdClusterSize_LJT',1,1,5);%set k and rmm
        rest_sliceviewer_ljt('ClustersReport_LJT', 1);%save CI report
        close(gcf);
    end
% end