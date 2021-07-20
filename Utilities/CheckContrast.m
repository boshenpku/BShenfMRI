%% Normalise Check
% orthview for check EPI image preprocessing, comparing with single_sub_T1.nii
% created by Shen Bo
% based on CANLAB SCNcore script
normcheckdir = 'E:\ShenBo\GR\Model\SecondLevel\gsw';
imgfold = 'E:\ShenBo\GR\Model\SecondLevel\gsw';
outputfilename = 'NormaliseChk';
T1file = which('single_subj_T1.nii');
if ~exist(normcheckdir,'dir')
    mkdir(normcheckdir);
end;
filelist = {};
tmpstrct = dir(fullfile(imgfold,'2*.img'));
for i = 1:length(tmpstrct)
    filelist = fullfile(imgfold,tmpstrct(i).name);
    mask = which('EPI.nii');
    data = fmri_data(filelist,mask);
    Chkfor = 1;
    if Chkfor == 1
        orthviews(data,'overlay',T1file);
    elseif Chkfor == 0
        orthviews(data);
    end;
    cd(normcheckdir);
    clear matlabbatch;
    matlabbatch{1}.spm.util.print.fname = outputfilename; %% Orthview Graphics Filename for saving
    matlabbatch{1}.spm.util.print.opts.opt = { '-dpsc2';'-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
end;