function [CntrP] = FIRSTLEVEL(filepoolindv,onsetindv,DsgMat,derivs,...
    TR,NSlice,Microt0,imghead,firstleveldir,mask,orthogonalize)
%%
if ~exist('mask','var')
    mask = '';
end;
if ~exist('orthogonalize','var')
    orthogonalize = 1;
end;
%% Firstlevel for single trial analysis
Outputdir = fullfile(firstleveldir,filepoolindv.subid);
if ~exist(Outputdir,'dir')
    mkdir(Outputdir);
end;
%% pre-define parameters
if isfield(DsgMat,'SingleTrialList')
    SingleTrialList = DsgMat.SingleTrialList;
    SingleTrialCond = DsgMat.SingleTrialCond;
    DursSingleTrial = DsgMat.DursSingleTrial;
    for regi = 1:length(SingleTrialList)
        CntrP.(SingleTrialList{regi})=[];
    end;
end;

if isfield(DsgMat,'CondList')
    CondList = DsgMat.CondList;
    DursCond = DsgMat.DursCond;
    for regi = 1:length(CondList)
        CntrP.(CondList{regi}) =[];
    end;
end;

if isfield(DsgMat,'Parametric_under_condition')
    Parametric_under_condition = DsgMat.Parametric_under_condition;
    for para = 1:length(Parametric_under_condition)
        if iscell(Parametric_under_condition{para})
            for regi = 1:length(Parametric_under_condition{para})
                CntrP.(Parametric_under_condition{para}{regi})=[];
            end;
        end;
    end;
end;

if isfield(DsgMat,'Nuisance')
    Nuisance = DsgMat.Nuisance;
    DursNuisance = DsgMat.DursNuisance;
    for regi = 1:length(Nuisance)
        CntrP.(Nuisance{regi})=[];
    end;
end;

if isfield(DsgMat,'Parametric_under_nuisance')
    Parametric_under_nuisance = DsgMat.Parametric_under_nuisance;
    for para = 1:length(Parametric_under_nuisance)
        if iscell(Parametric_under_nuisance{para})
            for regi = 1:length(Parametric_under_nuisance{para})
                CntrP.(Parametric_under_nuisance{para}{regi}) = [];
            end;
        end;
    end;
end;

%% check to do task
todolist = {};
todoindex = 0;
for sessi = find(filepoolindv.nimgfile .* filepoolindv.nbehfile > 0)
    if ~isempty(filepoolindv.imgfile{sessi})
        [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
        [d f e] = fileparts(commoncharacter);
        f = replaceWildcards(f,'**','*');
        if numel(dir(fullfile(d,[imghead f e]))) == filepoolindv.nimgfile(sessi) &&...
                (filepoolindv.nbehfile(sessi) .* filepoolindv.nimgfile(sessi) > 0)
            todolist{end+1} = myfnames(fullfile(d,[imghead f e]));
        end;
        todoindex = todoindex + 1;
    else
        todolist{end+1} = {};
    end;
end;

%% to do
%% model specify
if  ~exist(fullfile(Outputdir,'SPM.mat'),'file') && todoindex > 0
    clear matlabbatch;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.dir = {Outputdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = NSlice;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = Microt0;
    regr = 0;
    runi = 0;
    for sessi = find(filepoolindv.nimgfile .* filepoolindv.nbehfile > 0)
        runi = runi + 1;
        if ~isempty(todolist{runi})
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).scans = todolist{runi};
            condi = 0;
            if exist('SingleTrialList','var')
                for si = 1:numel(SingleTrialList)
                    for triali = 1:length(onsetindv(sessi).(SingleTrialList{si}))
                        regr = regr + 1;
                        condi = condi + 1;
                        CntrP.(SingleTrialList{si}) =[CntrP.(SingleTrialList{si}) regr];
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).name = [SingleTrialList{si} num2str(onsetindv(sessi).(SingleTrialCond{si})(triali))];
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).onset = onsetindv(sessi).(SingleTrialList{si})(triali);
                        if isnumeric(DursSingleTrial{si})
                            duration = DursSingleTrial{si};
                        elseif ischar(DursSingleTrial{si})
                            error('duration for single trial must be a 1x1 numeric');
                        end;
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).duration = duration;
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).tmod = 0;
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod = struct('name', {}, 'param', {}, 'poly', {});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).orth = orthogonalize;
                        regr = regr + sum(derivs);
                    end;
                end;
            end;
            for ci = 1:length(CondList)
                condi = condi + 1;
                regr = regr + 1;
                CntrP.(CondList{ci}) =[CntrP.(CondList{ci}) regr];
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).name = CondList{ci};
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).onset = onsetindv(sessi).(CondList{ci});
                if isnumeric(DursCond{ci})
                    duration = DursCond{ci};
                elseif ischar(DursCond{ci})
                    duration = onsetindv(sessi).(DursCond{ci});
                end;
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).duration = duration;
                matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).tmod = 0;
                regr = regr + sum(derivs);
                if iscell(Parametric_under_condition{ci})
                    for para = 1:length(Parametric_under_condition{ci})
                        regr = regr + 1;
                        CntrP.(Parametric_under_condition{ci}{para}) = [CntrP.(Parametric_under_condition{ci}{para}) regr];
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).name = Parametric_under_condition{ci}{para};
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).param = onsetindv(sessi).(Parametric_under_condition{ci}{para});
                        matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod(para).poly = 1;
                        regr = regr + sum(derivs);
                    end;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).orth = orthogonalize;
                elseif isnumeric(Parametric_under_condition{ci})
                    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).pmod = struct('name', {}, 'param', {}, 'poly', {});
                    matlabbatch{1}.spm.stats.fmri_spec.sess(runi).cond(condi).orth = orthogonalize;
                end;
            end;
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).regress = struct('name', {}, 'val', {});
            [d, ~, ~] = fileparts(todolist{runi}{1});
            MultiReg = myfnames(fullfile(d,'rp_*.txt'));
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).multi_reg = MultiReg;
            regr = regr + 6;
            matlabbatch{1}.spm.stats.fmri_spec.sess(runi).hpf = 128;
           
        end;
    end;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = derivs;
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {mask};
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    regr = regr + runi;
    %% run
    spm_jobman('run',matlabbatch);
    
    %% save design matrix
    clear matlabbatch;
    cd(firstleveldir);
    matlabbatch{1}.spm.util.print.fname = 'DsgnMatrix';
    matlabbatch{1}.spm.util.print.opts.opt = {'-dpsc2'; '-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
    save(fullfile(Outputdir,sprintf('CntrP.mat')),'CntrP');
end;

%% estimate model
if isempty(dir(fullfile(Outputdir,'beta_000*')))
    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(Outputdir,'SPM.mat')};
    spm_jobman('run',matlabbatch);
end;
