% Feel free to run multiple copies of matlab to distribute this across the workstations.  Just don't use more than 25-30gb of ram on each one at any given time.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Bootstrapping for Gianaros Data Rating Prediction
% -----------------------------------------------------
%
% Will take approximately 10 days and 34gb of memory to run 5000 samples on
% one computer.  Parallel Computing toolbox can't handle this job on one
% computer due to memory limitations.
%
% This is a script to be run on different computers to break up the job.
% 180s per sample for 500 samples should take approximately 25 hours.  Can
% be run multiple times on the same computer.  Takes approx 10g of RAM for
% each instance
%
% Will run off of dropbox:
% -1:3 7:8 on Claustrum
% -4:6 9:10 on Calor
% -8:10 on Pilab
clear all;clc;
addpath(genpath('C:\Toolbox\CANLab'))
addpath(genpath('C:\Toolbox\CANLab\local_depositorywc\trunk'))
addpath(genpath('C:\Toolbox\CANLab\spider'))
addpath(genpath('C:\Toolbox\CANLab\lasso'))
% addpath(genpath('Volumes/RAID/Resources/spm8'))
 
fPath = 'E:\ShenBo\GR\Model\MVPA\bootstrap';
bPath = fPath;
load([fPath filesep 'SVM_ShC3S_O_dat.mat'])
% clear test
 
% [cverr1, stats1, optout1] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC3S_O_dat_boot1250_1.mat'],'cverr1','stats1','optout1','-v7.3')
% [cverr2, stats2, optout2] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC3S_O_dat_boot1250_2.mat'],'cverr2','stats2','optout2','-v7.3')
% [cverr3, stats3, optout3] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC3S_O_dat_boot1250_3.mat'],'cverr3','stats3','optout3','-v7.3')
[cverr4, stats4, optout4] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
save([fPath filesep 'SVM_ShC3S_O_dat_boot1250_4.mat'],'cverr4','stats4','optout4','-v7.3')

rmpath(genpath('C:\Toolbox\CANLab'));

% [cverr2, stats2, optout2] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC3S_O_dat_boot1250_2.mat'],'cverr2','stats2','optout2','-v7.3')

%  
% [cverr3, stats3, optout3] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC1S_O1250_3.mat'],'cverr3','stats3','optout3','-v7.3')
 
% [cverr4, stats4, optout4] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1250, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_ShC1S_O1250_4.mat'],'cverr4','stats4','optout4','-v7.3')
%  
% [cverr5, stats5, optout5] = predict(dat, 'algorithm_name', 'cv_svm', 'nfolds', 1, 'bootweights','bootsamples',1000, 'savebootweights', 'error_type', 'mcr');  
% save([fPath filesep 'SVM_H1_L1_LOSO_boot1000_5.mat'],'cverr5','stats5','optout5','-v7.3')
%  

%% Combine weights
clear all;clc;
addpath(genpath('C:\Toolbox\CANLab'))
addpath(genpath('C:\Toolbox\CANLab\local_depositorywc\trunk'))
addpath(genpath('C:\Toolbox\CANLab\spider'))
addpath(genpath('C:\Toolbox\CANLab\lasso'))

fPath = '/home/yuhongbo/Yu_fMRI_data/guilt_prediction/bootstrap';
bPath = '/home/yuhongbo/Yu_fMRI_data/guilt_prediction/bootstrap';
fPath = 'E:\ShenBo\GR\Model\MVPA\bootstrap';
bPath = fPath;
w=[];
for i = 1:4
    eval(['load([''' bPath filesep 'SVM_ShC3S_O_dat_boot1250_' num2str(i) '.mat''])'])
    eval(['w = [w; stats' num2str(i) '.WTS.w];'])
    eval(['clear stats' num2str(i) ' optout' num2str(i)])
end
 
load([bPath filesep 'SVM_ShC3S_O_dat_boot1250_1.mat'])
dat = stats1.weight_obj;
    
wste = nanstd(w);
wmean = nanmean(w);
wste(wste == 0) = Inf;  % in case unstable regression returns all zeros
wZ = wmean ./ wste;  % tor changed from wmean; otherwise bootstrap variance in mean inc in error; Luke renamed to avoid confusion
wP = 2 * (1 - normcdf(abs(wZ)));
 
% fdr 05
out = statistic_image();
out.dat = wZ';
out.p = wP';
out.volInfo = dat.volInfo;
thr = threshold(out, .05,'fdr','k',3);
t = replace_empty(thr);
th = dat;
th.dat = wZ';
th.dat(~logical(t.sig)) = 0;
th.fullpath = [fPath filesep 'SVM_ShC3S_O5000_fdr05_k3.nii'];
write(th,'mni')
 
% 001 uncorrected
out = statistic_image();
out.dat = wZ';
out.p = wP';
out.volInfo = dat.volInfo;
thr = threshold(out, .001, 'unc','k',10);
t = replace_empty(thr);
th = dat;
th.dat = wZ';
th.dat(~logical(t.sig)) = NaN;
th.fullpath = [fPath filesep 'SVM_ShC3S_O5000_001_unc_k10.nii'];
write(th,'mni')
 
% 005 uncorrected
out = statistic_image();
out.dat = wZ';
out.p = wP';
out.volInfo = dat.volInfo;
thr = threshold(out, .005, 'unc','k',30);
t = replace_empty(thr);
th = dat;
th.dat = wZ';
th.dat(~logical(t.sig)) = 0;
th.fullpath = [fPath filesep 'SVM_ShC3S_O5000_005_unc_k30.nii'];
write(th,'mni')

z = dat;
z.dat = wZ';
z.fullpath = [fPath filesep 'SVM_ShC3S_O5000_Z.nii'];
write(z,'mni')
 
p = dat;q  
p.dat = wP';
p.fullpath = [fPath filesep 'SVM_ShC3S_O5000_pVal.nii'];
write(p,'mni')

rmpath(genpath('C:\Toolbox\CANLab'));