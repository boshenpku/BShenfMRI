clear
spm fmri

FolderPath = '/data1/FengWangshu/CI_fMRI/NIFTI';
OutputPath = '/data1/FengWangshu/CI_fMRI/FirstLevel';

cd('/data1/FengWangshu/CI_fMRI/Script');
CI_onset_all

NSlice = 40;
refSlice = 20;
TR = 2.0;
SubList = dir(fullfile(FolderPath,'Zhou*'));
CondList = {'t1d1' 't1d2' 't1d3' 't1d4' 't2d1' 't2d2' 't2d3' 't2d4'};
Parametric_under_condition = [];
Nuisance = {'context' 'end' 'button'};% question

cname = {'task_main','diff_main21','diff_main32','diff_main43','t1_diff21','t1_diff32','t1_diff43','t2_diff21','t2_diff32','t2_diff43'};
ctype = {'T', 'T', 'T','T','T', 'T', 'T','T','T', 'T'};
simple_cons = [1 1 1 1 -1 -1 -1 -1; -1 1 0 0 -1 1 0 0; 0 -1 1 0 0 -1 1 0; 0 0 -1 1 0 0 -1 1;-1 1 0 0 0 0 0 0;0 -1 1 0 0 0 0 0 ;0 0 -1 1 0 0 0 0;0 0 0 0 -1 1 0 0;0 0 0 0 0 -1 1 0;0 0 0 0 0 0 -1 1;];

% run SPM


for nsub = 1:length(SubList)
    SubOutput = fullfile(OutputPath,SubList(nsub).name);
    if ~exist(SubOutput,'dir')
        mkdir(SubOutput);
    end
    for c= 1:length(cname)
        contrast_dir{c} = fullfile(SubOutput,['contrast',num2str(c),'_',char(cname{c})]);
        if ~exist(contrast_dir{c})
            mkdir(contrast_dir{c});
        end
    end

    Checkfolder = fullfile(SubOutput,'ChkMsg2EstimateDone');
    RunList = dir(fullfile(FolderPath,SubList(nsub).name,'geservice','*8CH_CI*'));
    
    sub =SubList(nsub).name ;
    subnum = sub(17:18);
    
    clear matlabbatch;
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {SubOutput};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = NSlice;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = refSlice;
    
    for nrun = 1:length(RunList)
        clear Files FileList FilePath;
        question_onset = [];
        question_duration = [];

        FilePath = fullfile(FolderPath,SubList(nsub).name,'geservice',RunList(nrun).name);
        FileList = dir(fullfile(FilePath,'swra*.nii'));
        for i = 1:length(CondList)
            question_onset = [question_onset,eval(strcat('sub',subnum,'_run',num2str(nrun),'_',CondList{i},'_question_onset'))];
            question_duration = [question_duration,eval(strcat('sub',subnum,'_run',num2str(nrun),'_',CondList{i},'_question_duration'))];
        end
        
        for nfile = 1:length(FileList)
            Files(nfile) = {fullfile(FilePath,FileList(nfile).name)};
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).scans = Files;
        for ncond = 1:length(CondList)
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).name = CondList{ncond};
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).onset = eval(strcat('sub',subnum,'_run',num2str(nrun),'_',CondList{ncond},'_answer_onset'))-eval(strcat('sub',subnum,'_run',num2str(nrun),'_dummy_onset'))-10;
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).duration = eval(strcat('sub',subnum,'_run',num2str(nrun),'_',CondList{ncond},'_answer_duration'));
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).tmod = 0;
            if isempty(Parametric_under_condition)
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(ncond).pmod = struct('name', {}, 'param', {}, 'poly', {});
            else
                for p_c = 1:length(Parametric_under_condition)
                    p_c
%                    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(i).pmod(p_c).name = char(parametric_under_condition_name{p_c});
%                    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(i).pmod(p_c).param = eval(sprintf('DM(1,s).onset.%s_para_%s_run%d_%d;',condition_name, parametric_under_condition{p_c},r,i));
%                    matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(i).pmod(p_c).poly = 1;
                end
            end
        end
        for n = 1:length(Nuisance)
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).name = Nuisance{n};
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).onset = eval(strcat('sub',subnum,'_run',num2str(nrun),'_',Nuisance{n},'_onset'))-eval(strcat('sub',subnum,'_run',num2str(nrun),'_dummy_onset'))-10;
            if ~exist(strcat('sub',subnum,'_run',num2str(nrun),'_',Nuisance{n},'_duration'),'var')
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).duration = 0;
            else
                matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).duration = eval(strcat('sub',subnum,'_run',num2str(nrun),'_',Nuisance{n},'_duration'));
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+n).pmod = struct('name', {}, 'param', {}, 'poly', {});
        end
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+length(Nuisance)+1).name = 'question';
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+length(Nuisance)+1).onset = question_onset-eval(strcat('sub',subnum,'_run',num2str(nrun),'_dummy_onset'))-10;
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+length(Nuisance)+1).duration = question_duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).cond(length(CondList)+length(Nuisance)+1).tmod = 0;
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).regress = struct('name', {}, 'val', {});
        MultiReg = dir(fullfile(FilePath,'rp_a*.txt'));
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).multi_reg = {fullfile(FilePath,MultiReg.name)};
        matlabbatch{1}.spm.stats.fmri_spec.sess(nrun).hpf = 128;
    end
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0]; % [0 0]
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    if ~exist(Checkfolder,'dir')
        spm_jobman('run',matlabbatch);
%         eval(sprintf('%s_DM = DM(1,s)',DM(1,s).img_folder));
%         save(fullfile(SubOutput,[SubList(nsub).name,'_','1st_DM.mat']),strcat(SubList(nsub).name,'_DM'),'matlabbatch')
    end
    
    % estimate model
    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(SubOutput,'SPM.mat')};
    spm_jobman('run',matlabbatch);
    mkdir(Checkfolder);
    
    % define contrasts
    Checkfolder = fullfile(SubOutput,'ChkMsg2ContrastDone');
    if exist(Checkfolder,'dir')
    else
        SPMest=load(fullfile(SubOutput,'SPM.mat'));
        SPMest=SPMest.SPM;
        SPMest.xCon = [];
        headmotion_constant = [0 0 0 0 0 0];
        for c= 1:length(cname)
            combined_cons = [];
            for s_c = 1:length(simple_cons(c,:))
                combined_cons = [combined_cons simple_cons(c,s_c) zeros(1,length(Parametric_under_condition)) 0]
            end
            run_cons(c,:) = [combined_cons zeros(1,2+2*length(Nuisance))  headmotion_constant];
            cons = [];
            for r = 1:length(RunList)
                cons = [cons run_cons(c,:)];
            end
            cons = [cons zeros(1,length(RunList))];
            contrast(c).cname = char(cname(c));
            contrast(c).ctype = char(ctype(c));
            %cons = [cons 0 0];
            contrast(c).cons = cons';

            if isempty(SPMest.xCon)
                SPMest.xCon = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
            else
                SPMest.xCon (end+1) = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
            end
        end
        spm_contrasts(SPMest);
        save(fullfile(SubOutput,[SubList(nsub).name,'_','1stLevel_contrast.mat']),'contrast');
        %% copy contrast files
        for c= 1:length(cname)
            sourcefile = ['con_',strrep(num2str(c+100000000),'10000','')];
            copyfile(fullfile(SubOutput,[sourcefile,'.img']),fullfile(contrast_dir{c},[SubList(nsub).name,'_',sourcefile,'.img']));
            copyfile(fullfile(SubOutput,[sourcefile,'.hdr']),fullfile(contrast_dir{c},[SubList(nsub).name,'_',sourcefile,'.hdr']));
        end
        %% report contrast results
        first_result_report.threshdesc = {'FWE' 'none' 'none' 'none' 'none'};
        first_result_report.thresh = [0.05 0.001 0.005 0.01 0.05];
        first_result_report.extent = [0 22 46 74 389];
        % result report spm
        for c = 1:length(cname)
            for i = 1:length(first_result_report.threshdesc)
                clear matlabbatch;
                con_name = [SubList(nsub).name,'  ',char(cname(c))];
                matlabbatch{1}.spm.stats.results.spmmat = {fullfile(SubOutput,'SPM.mat')};
                matlabbatch{1}.spm.stats.results.conspec.titlestr = con_name;
                matlabbatch{1}.spm.stats.results.conspec.contrasts = c;
                matlabbatch{1}.spm.stats.results.conspec.threshdesc = char(first_result_report.threshdesc{i});
                matlabbatch{1}.spm.stats.results.conspec.thresh = first_result_report.thresh(i);
                matlabbatch{1}.spm.stats.results.conspec.extent = first_result_report.extent(i);
                matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
                matlabbatch{1}.spm.stats.results.units = 1;
                matlabbatch{1}.spm.stats.results.print = true;
                spm_jobman('run',matlabbatch);
%                 save_spm_results(xSPM,hReg)
            end
            close('all');
            % result report xjview
%             xjview_dir = dir([con_name,'*.img']);
%             for i = 1:length(xjview_dir)
%                 rest_sliceviewer_ljt('ShowOverlay', fullfile(SubOutput,xjview_dir(i).name));
%                 rest_sliceviewer_ljt('Overlay_SetThrdAbsValue_LJT',1,0.05);%set p
%                 rest_sliceviewer_ljt('Overlay_SetThrdClusterSize_LJT',1,1,5);%set k and rmm
%                 rest_sliceviewer_ljt('ClustersReport_LJT', 1);%save CI report
%                 close(gcf);
%             end
        end
        mkdir(Checkfolder);
    end
end            