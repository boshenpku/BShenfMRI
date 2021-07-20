function OneSampTTest(filelist,type,Result_dir,model_name,includeNaN,report)
clear matlabbatch;
Result_dir = fullfile(Result_dir,model_name);
if ~exist(Result_dir,'dir')
    mkdir(Result_dir);
end;

%% recalculate to change NaN value into zero.
if includeNaN
    clear matlabbatch;
    existfilelist = {};
    for j = 1:numel(filelist)
        [d, ff, ee] = fileparts(filelist{j});
        ReCal_img_dir = fullfile(d,'ReCal_Img');
        if ~exist(ReCal_img_dir,'dir')
            mkdir(ReCal_img_dir);
        end;
        inname = [ff ee];
        matlabbatch{j}.spm.util.imcalc.input = filelist(j);
        matlabbatch{j}.spm.util.imcalc.output = ['zr' inname];
        matlabbatch{j}.spm.util.imcalc.outdir = {ReCal_img_dir};
        matlabbatch{j}.spm.util.imcalc.expression = 'i1';
        matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{j}.spm.util.imcalc.options.mask = -1;
        matlabbatch{j}.spm.util.imcalc.options.interp = 1;
        matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
        filelist{j} = fullfile(ReCal_img_dir,['zr' inname]);
        if ~isempty(myfnames(filelist{j}))
            existfilelist{end+1} = filelist{j};
        end;
    end;
    if numel(existfilelist) ~= numel(filelist)
        spm_jobman('run',matlabbatch);
    end;
end;
%% run
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {Result_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = filelist';
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
% %matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
% %matlabbatch{1}.spm.stats.factorial_design.masking.em = {which('rMask_withoutCerebelum.nii')};
% matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
% matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
existfile = dir(fullfile(Result_dir,'SPM.mat'));
if isempty(existfile)
    spm_jobman('run',matlabbatch);
end;
% Estimate
clear matlabbatch;
filelist = filenames(fullfile(Result_dir,'SPM.mat'));
matlabbatch{1}.spm.stats.fmri_est.spmmat = filelist;
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
existfile = dir(fullfile(Result_dir,'beta*'));
if isempty(existfile)
    spm_jobman('run',matlabbatch);
end;
% Contrast
cd(Result_dir);
existfile1 = dir(fullfile(Result_dir,'*beta*'));
existfile2 = dir(fullfile(Result_dir,'*spmT*'));
if isempty(existfile1) || ~isempty(existfile2)
else
    cnametmp{1} = model_name;
    cons{1} = [1];
    cnametmp{2} = ['-' model_name];
    cons{2} = [-1];
    SPMest=load('SPM.mat');
    SPMest=SPMest.SPM;
    SPMest.xCon =[];
    for i = 1:numel(cnametmp)
        if isempty(SPMest.xCon)
            SPMest.xCon = spm_FcUtil('Set',cnametmp{i}, type,'c',cons{i}',SPMest.xX.xKXs);
        else
            SPMest.xCon (end+1) = spm_FcUtil('Set',cnametmp{i}, type,'c',cons{i}',SPMest.xX.xKXs);
        end
    end
    spm_contrasts(SPMest);
end;
if report == 1
    %% report contrast results
    first_result_report.threshdesc = {'none'};
    first_result_report.thresh = [0.005];
    first_result_report.extent = [20];
    % result report spm
    if ~exist('cnametmp','var')
        cnametmp = {model_name ['-' model_name]};
    end;
    for rc = 1:length(cnametmp)
        for i = 1:length(first_result_report.threshdesc)
            clear matlabbatch;
            con_name = cnametmp{rc};
            matlabbatch{1}.spm.stats.results.spmmat = {fullfile(Result_dir,'SPM.mat')};
            matlabbatch{1}.spm.stats.results.conspec.titlestr = con_name;
            matlabbatch{1}.spm.stats.results.conspec.contrasts = rc;
            matlabbatch{1}.spm.stats.results.conspec.threshdesc = char(first_result_report.threshdesc{i});
            matlabbatch{1}.spm.stats.results.conspec.thresh = first_result_report.thresh(i);
            matlabbatch{1}.spm.stats.results.conspec.extent = first_result_report.extent(i);
            matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.print = true;
            spm_jobman('run',matlabbatch);
        end;
    end;
end;
