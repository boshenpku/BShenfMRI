function FFMixedCntrst(factors,cname,ctype,secondleveldir,subjlist,report)
% generate specify all imaging file list
i = 0;
Cond_mat = [];
for f = 1:length(factors)
    filedir = fullfile(secondleveldir,factors{f});
    if ~exist(filedir, 'dir')
        error('Factor %s does not exist, Please Check',factors{f});
    end;
    for subj = 1:length(subjlist)
        i = i + 1;
        filelist{i} = fullfile(filedir,[subjlist{subj} '_' factors{f} '.img']);
        Cond_mat = [Cond_mat; [i,subj,f,1]];
    end;
    eval(['CntrP.' factors{f} '=' num2str(f) ';']);
end;
regr = f+subj;
Design_dir =  fullfile(secondleveldir,'FFMixedContrast');
if ~exist(Design_dir,'dir')
    mkdir(Design_dir);
end;
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {Design_dir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'subj';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'factor';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = filelist;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = Cond_mat;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {which('rMask_withoutCerebelum.nii')};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
existfile = dir(fullfile(Design_dir,'SPM.mat'));
if isempty(existfile)
    spm_jobman('run',matlabbatch);
    clear matlabbatch;
    cd(Design_dir);
    matlabbatch{1}.spm.util.print.fname = 'DsgnMatrix';
    matlabbatch{1}.spm.util.print.opts.opt = {'-dpsc2'; '-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
end;

% Estimate
clear matlabbatch;
filelist = fullfile(Design_dir,'SPM.mat');
matlabbatch{1}.spm.stats.fmri_est.spmmat = {filelist};
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
existfile = dir(fullfile(Design_dir,'beta*'));
if isempty(existfile)
    spm_jobman('run',matlabbatch);
end;
% Contrast
cd(Design_dir);
existfile1 = dir(fullfile(Design_dir,'*beta*'));
existfile2 = dir(fullfile(Design_dir,'*spm*'));
if isempty(existfile1) || ~isempty(existfile2)
else
    SPMest=load(fullfile(Design_dir,'SPM.mat'));
    SPMest=SPMest.SPM;
    SPMest.xCon = [];
    ci = 0;
    for c = 1:length(cname)
        if ctype{c} == 'T'
            cons = zeros(1,regr);
            if (cname{c}(1) ~= '-' && cname{c}(1) ~= '+')
                cnametmp = ['+' cname{c}];
            end;
            tp = find(cnametmp=='+'|cnametmp=='-');
            for cal = 1:length(tp)
                if cal < length(tp)
                    r = cnametmp((tp(cal)+1):(tp(cal+1)-1));
                elseif cal == length(tp)
                    r = cnametmp((tp(cal)+1):end);
                end;
                eval(['cons(CntrP.' r ')=' cnametmp(tp(cal)) '1']);
            end;
            ci = ci + 1;
            contrast(ci).cname = cname{c};
            contrast(ci).ctype = ctype{c};
            contrast(ci).cons = cons';
            ci = ci + 1;
            contrast(ci).cname = ['-' cname{c}];
            contrast(ci).ctype = ctype{c};
            contrast(ci).cons = -cons';
        elseif ctype{c} == 'F'
            cons = zeros(length(cname{c}),regr);
            for f = 1:length(cname{c})
                if (cname{c}{f}(1) ~= '-' && cname{c}{f}(1) ~= '+')
                    cnametmp = ['+' cname{c}{f}];
                end;
                tp = find(cnametmp=='+'|cnametmp=='-');
                for cal = 1:length(tp)
                    if cal < length(tp)
                        r = cnametmp((tp(cal)+1):(tp(cal+1)-1));
                    elseif cal == length(tp)
                        r = cnametmp((tp(cal)+1):end);
                    end;
                    eval(['cons(f,CntrP.' r ')=' cnametmp(tp(cal)) '1']);
                end;
            end;
            ci = ci + 1;
            contrast(ci).cname = [num2str(f) 'F' cname{c}{1} '...' cname{c}{f}];
            contrast(ci).ctype = ctype{c};
            contrast(ci).cons = cons';
        end;
    end;
    for c = 1:ci
        if isempty(SPMest.xCon)
            SPMest.xCon = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
        else
            SPMest.xCon (end+1) = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
        end;
    end;
    spm_contrasts(SPMest);
    %% report contrast results
    if report == 1
        first_result_report.threshdesc = {'none'};
        first_result_report.thresh = [0.005];
        first_result_report.extent = [20];
        % result report spm
        for c = 1:ci
            for i = 1:length(first_result_report.threshdesc)
                clear matlabbatch;
                matlabbatch{1}.spm.stats.results.spmmat = {fullfile(Design_dir,'SPM.mat')};
                matlabbatch{1}.spm.stats.results.conspec.titlestr = contrast(c).cname;
                matlabbatch{1}.spm.stats.results.conspec.contrasts = c;
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
end;