clear all
CANLabdir = 'C:\Toolbox\CANLab';
addpath(genpath(CANLabdir));
Outdir = 'E:\ShenBo\GR\Model\MVPA\weight_map';
mkdir(Outdir);
Outdir = 'E:\ShenBo\GR\Model\MVPA\dat';
mkdir(Outdir);
Outdir = 'E:\ShenBo\GR\Model\MVPA\stats';
mkdir(Outdir);
Outdir = 'E:\ShenBo\GR\Model\MVPA\ROC';
mkdir(Outdir);
Outdir = 'E:\ShenBo\GR\Model\MVPA';
%% load data
% subjects={'sub101' 'sub102' 'sub103' 'sub104' 'sub105' 'sub106' 'sub107' 'sub109' 'sub110'  'sub112' 'sub113' 'sub114'  'sub115' 'sub116' 'sub117' 'sub119' 'sub120' 'sub121' 'sub122' 'sub123' 'sub124' 'sub125' 'sub126' 'sub127'};
% f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');%fristlevel contrast: flexible factorial
% f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');
% f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');%fristlevel contrast: flexible factorial
% f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f2 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc3sw\zr*.img');%fristlevel contrast: flexible factorial
f1 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc3ow\zr*.img');
% f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
% mask = '/data3/FengWangshu/GPI_fMRI/MVPA/mask/NeuroSynth_TemporoparietalJunctionMask_only400plus_right_FDR.01.img';
% f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast6_PCI_effect/*con*.img');
% f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast8_GCI_effect2/*con*.img');
mask = '/data3/FengWangshu/GPI_fMRI/SecondLevel_simple_m1/flexible_28/BinaryMask_Conjunction_PI&GI_p05uncorrected_mPFC.nii';
mask = 'E:\ShenBo\GR\batch\rMask_withoutCerebelum.nii';

% masks:
% GPI_PIactivationMask_exclGIactivation_p.001FWE
% GPI_ConjunctionActivationMask_p.001FWE
% NeuroSynth_TemporoparietalJunctionMask_only400plus_FDR.01
% NeuroSynth_TemporoparietalJunctionMask_only400plus_right_FDR.01
% NeuroSynth_meaningMask_FDR.01
% NeuroSynth_semanticMask_FDR.01.img
% Template_bilateralIFG_Mask
% 
% ToMlocMask_peakFWE.img

f = vertcat(f1,f2);
% dat= fmri_data(f); %%%whole brain
% dat = fmri_data(f,ToM_mask);  %%% for mask
dat = fmri_data(f,mask);
% f_names = cell2mat(f);
% sharing = str2num(f_names(:,end-4));
% sharing = -1*(sharing*2-3);%self_incorrect = 1; both_incorrect = -1
% sharing = -1*(sharing-2);%self_incorrect = 1; both_incorrect = 0; ptn_err = -1
nsub = length(f1);
% nsub = length(a);
label = [ones(nsub,1);-1*ones(nsub,1)];
sub =  [1:nsub,1:nsub]';
dat.Y = label;
[cverr, stats, optout] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', sub, 'error_type', 'mcr');   % run leave-one-subject-out cross-validation
% [cverr, stats, optout] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', sub,'multiclass', 'error_type', 'mcr');   % run leave-one-subject-out cross-validation

% dist_from_hyperplane_xval
create_figure('ROC'); ROC = roc_plot(stats.dist_from_hyperplane_xval, stats.Y > 0, 'color', 'r', 'threshold', 0, 'twochoice'); %forced 
% create_figure('ROC'); ROC = roc_plot(to_be_test, label > 0, 'color', 'g', 'threshold', 0, 'twochoice'); %forced based on other's pattern, get ROC


% create_figure('ROC'); ROC = roc_plot(to_be_test, stats.Y > 0, 'color', 'r', 'threshold', 0, 'twochoice'); %forced based on other's pattern, get ROC

% create_figure('ROC'); ROC = roc_plot(stats.other_output{3}, stats.Y > 0, 'color', 'r', 'threshold', 0); %singler interval
% create_figure('ROC'); ROC = roc_plot(predNegVReg, stats.Y > 0, 'color', 'r', 'threshold', 0, 'twochoice'); %forced 


%write out image of pattern;
w = stats.weight_obj;
wname = 'ShC3S_O';
w.fullpath = fullfile(Outdir,'weight_map',['SVM_',wname,'.nii']);
% w.fullpath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/SVM_GI_NG2_GPIfws_withSemanticMask.nii';
write(w, 'mni')
save(fullfile(Outdir,'dat',['SVM_',wname,'_dat.mat']),'dat');
save(fullfile(Outdir,'stats',['SVM_',wname,'_stats.mat']),'stats');
save(fullfile(Outdir,'ROC',['SVM_',wname,'_ROC.mat']),'ROC');

% save('/data3/FengWangshu/GPI_fMRI/MVPA/dat/SVM_GI_NG2_GPIfws_withSemanticMask_dat.mat',dat);
% save('/data3/FengWangshu/GPI_fMRI/MVPA/stats/SVM_GI_NG2_GPIfws_withSemanticMask_stats.mat',stats);
% save('/data3/FengWangshu/GPI_fMRI/MVPA/ROC/SVM_GI_NG2_GPIfws_withSemanticMask_ROC.mat',ROC);


%plot arbitrarily thresholded results
w = stats.weight_obj;
% w = stats2.weight_obj;
% w = stats3.weight_obj;
thr = [prctile(w.dat, 1) prctile(w.dat, 99)];
wthr = w;
wthr.dat(wthr.dat > thr(1) & wthr.dat < thr(2)) = 0;

o2 = fmridisplay;
o2 = montage(o2, 'axial', 'slice_range', [-20 30], 'onerow', 'spacing', 6);
o2 = montage(o2, 'sagittal', 'slice_range', [-12 12], 'onerow', 'spacing', 6);
o2 = montage(o2, 'coronal', 'slice_range', [-20 26], 'onerow', 'spacing', 6);

% add blobs to first 'appraisal' montage only
wr = region(wthr);
colorrange = [prctile(w.dat, 1) prctile(w.dat, 99)];
o2 = addblobs(o2, wr, 'splitcolor', {[0 0 1] [0 1 1] [1 .5 0] [1 1 0]}, 'cmaprange', colorrange);