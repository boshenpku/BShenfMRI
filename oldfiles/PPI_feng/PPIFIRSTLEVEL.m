function [CntrP, regr] = PPIFIRSTLEVEL(onset,CondList,DursCond,Parametric_under_condition,...
    Nuisance,DursNuisance,Parametric_under_nuisance,derivs,...
    TR,NSlice,refSlice,imgdir,subfold_img,SessFold_img,imghead,firstleveldir)
SubOutput = fullfile(firstleveldir,subfold_img);
if ~exist(SubOutput,'dir')
    mkdir(SubOutput);
end;
for regi = 1:length(CondList)
    eval(['CntrP.' CondList{regi} '=[];']);
end;
for para = 1:length(Parametric_under_condition)
    if iscell(Parametric_under_condition{para})
        for regi = 1:length(Parametric_under_condition{para})
            eval(['CntrP.' Parametric_under_condition{para}{regi} '=[];']);
        end;
    end;
end;
for regi = 1:length(Nuisance)
    eval(['CntrP.' Nuisance{regi} '=[];']);
end;
for para = 1:length(Parametric_under_nuisance)
    if iscell(Parametric_under_nuisance{para})
        for regi = 1:length(Parametric_under_nuisance{para})
            eval(['CntrP.' Parametric_under_nuisance{para}{regi} '=[];']);
        end;
    end;
end;

clear matlabbatch;
matlabbatch{1}.spm.stats.fmri_spec.dir = {SubOutput};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = NSlice;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refSlice;
regr = 0;
for runi = 1:length(SessFold_img)
    clear Files FileList FilePath;
    RunList = dir(fullfile(imgdir,subfold_img,SessFold_img{runi}));
    FilePath = fullfile(imgdir,subfold_img,RunList.name);
    FileList = dir(fullfile(FilePath,imghead));
    for nfile = 1:length(FileList)
        Files(nfile) = {fullfile(FilePath,FileList(nfile).name)};
    end;
    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).scans = Files;
    for condi = 1:length(CondList)
        regr = regr + 1;
        eval(['CntrP.' CondList{condi} '=[' 'CntrP.' CondList{condi} ' regr];']);
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).name = CondList{condi};
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).onset = eval(['onset(runi).' CondList{condi}]);
        if isnumeric(DursCond{condi})
            duration = DursCond{condi};
        elseif ischar(DursCond{condi})
            duration = eval(['onset(runi).' DursCond{condi}]);
        end;
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).duration = duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).tmod = 0;
        regr = regr + sum(derivs);
        if iscell(Parametric_under_condition{condi})
            for para = 1:length(Parametric_under_condition{condi})
                regr = regr + 1;
                eval(['CntrP.' Parametric_under_condition{condi}{para} '=[' 'CntrP.' Parametric_under_condition{condi}{para} ' regr];']);
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).name = Parametric_under_condition{condi}{para};
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).param = eval(['onset(runi).' Parametric_under_condition{condi}{para}]);
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).poly = 1;
                regr = regr + sum(derivs);
            end;
        elseif isnumeric(Parametric_under_condition{condi})
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod = struct('name', {}, 'param', {}, 'poly', {});
        end;
    end
    for nui = 1:length(Nuisance)
        regr = regr + 1;
        eval(['CntrP.' Nuisance{nui} '=[' 'CntrP.' Nuisance{nui} ' regr];']);
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).name = Nuisance{nui};
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).onset = eval(['onset(runi).' Nuisance{nui}]);
        if isnumeric(DursNuisance{nui})
            duration = DursNuisance{nui};
        elseif ischar(DursNuisance{nui})
            duration = eval(['onset(runi).' DursNuisance{nui}]);
        end;
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).duration = duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).tmod = 0;
        regr = regr + sum(derivs);
        if iscell(Parametric_under_nuisance{nui})
            for para = 1:length(Parametric_under_nuisance{nui})
                regr = regr + 1;
                eval(['CntrP.' Parametric_under_nuisance{nui}{para} '=[' 'CntrP.' Parametric_under_nuisance{nui}{para} ' regr];']);
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).pmod(para).name = Parametric_under_nuisance{nui}{para};
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).pmod(para).param = eval(['onset(runi).' Parametric_under_nuisance{nui}{para}]);
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).pmod(para).poly = 1;
                regr = regr + sum(derivs);
            end;
        elseif isnumeric(Parametric_under_nuisance{nui})
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(length(CondList)+nui).pmod = struct('name', {}, 'param', {}, 'poly', {});
        end;
    end;
    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).regress = struct('name', {}, 'val', {});
    MultiReg = dir(fullfile(FilePath,'rp_*.txt'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).multi_reg = {fullfile(FilePath,MultiReg.name)};
    regr = regr + 6;
    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).hpf = 128;
end;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = derivs;
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
regr = regr + runi;

Checkfolder = fullfile(SubOutput,'ChkMsgSpecifyDone');
if ~exist(Checkfolder,'dir')
    spm_jobman('run',matlabbatch);
    save(fullfile(SubOutput,'CntrP.mat'),'CntrP','regr');
    clear matlabbatch;
    cd(firstleveldir);
    matlabbatch{1}.spm.util.print.fname = 'DsgnMatrix';
    matlabbatch{1}.spm.util.print.opts.opt = {'-dpsc2'; '-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
    mkdir(Checkfolder);
end;

% estimate model
Checkfolder = fullfile(SubOutput,'ChkMsgEstimateDone');
if ~exist(Checkfolder,'dir')
    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(SubOutput,'SPM.mat')};
    spm_jobman('run',matlabbatch);
    mkdir(Checkfolder);
end;
    