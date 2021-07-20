function FFMixedANOVA(conditions,design,maininters,effects,efftype,secondleveldir,subid_list,includeNaN,report)
if (length(conditions) ~= length(design))
    error('Number of conditions and design miss match');
end;
if (length(effects) ~= length(efftype))
    error('Number of cname and ctype miss match');
end;
Design_dir = fullfile(secondleveldir,'FFMixedANOVA');
if ~exist(Design_dir,'dir')
    mkdir(Design_dir);
end;
for c = 1:length(conditions)
    tp = find(design{c}==',');
    nfact = length(tp)+1;
    for f = 1:(length(tp)+1)
        if f == 1
            condmat{f}{c} = design{c}(1:(tp(f)-1));
        elseif f > 1 && f < (length(tp)+1)
            condmat{f}{c} = design{c}((tp(f-1)+1):(tp(f)-1));
        elseif f == length(tp)+1
            condmat{f}{c} = design{c}((tp(f-1)+1):end);
        end;
    end;
end;
for f = 1:nfact
    factlevel{f} = unique(condmat{f});
    nlevel(f) = length(factlevel{f});
    factname{f} =  factlevel{f}{1}(1:end-1);
end;
%%
sz = length(subid_list);
i = 0;
filelist = {};
Cond_mat = [];
for c = 1:length(conditions)
    tmp = [];
    for f = 1:nfact
        tmp = [tmp,str2double(condmat{f}{c}(end))];
    end;
    filedir = fullfile(secondleveldir,'Contrasts',conditions{c});
    if ~exist(filedir, 'dir')
        error('Condition %s does not exist, Please Check',conditions{c});
    end;
    for subj = 1:sz
        i = i + 1;
        imgfile = myfnames(fullfile(filedir,[subid_list{subj} '*.img']));
        niifile = myfnames(fullfile(filedir,[subid_list{subj} '*.nii']));
        if ~isempty(imgfile)
            filelist(end+1) = imgfile;
        else
            filelist(end+1) = niifile;
        end;
        if length(tmp) == 1
            Cond_mat = [Cond_mat;[i tmp subj 1]];
        elseif length(tmp) == 2
            Cond_mat = [Cond_mat;[i tmp subj]];
        elseif length(tmp) == 3
            Cond_mat = [Cond_mat;[i tmp]];
        end;
    end;
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

%% 
nmain = 0;
ninter = 0;
for mi = 1:length(maininters)
    if ~sum(maininters{mi} == ':')
        nmain = nmain + 1;
        mainlist(nmain) = find(ismember(factname,maininters{mi}));
    elseif sum(maininters{mi} == ':')
        ninter = ninter + 1;
        tmpcell = regexp(maininters{3},':','split');
        tmpvec = [];
        for f = 1:length(tmpcell)
            tmpvec = [tmpvec;find(ismember(factname,tmpcell{f}))];
        end;
        interlist{ninter} = tmpvec;
    end;
end;
%% to run
clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {Design_dir};
for f = 1:nfact
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).name = factname{f};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).dept = 1; % independence No
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).variance = 0; % variance equal 
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).ancova = 0;
end;
if nfact < 3
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).name = 'subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).dept = 0; % independence Yes
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).variance = 0; % variance equal 
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).ancova = 0;
elseif nfact >= 3
    error('only 2 Factors allowed for this script');
end;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = filelist';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = Cond_mat;
mi = 0;
regr = sz+sum(nlevel(mainlist))+ nlevel(1)*nlevel(2);
for m = 1:nmain
    mi = mi + 1;
    %     for shift = 1:length(factlevel{mainlist(m)})
    %         regr = regr + 1;
    %         tmpvec = dftCntr;
    %         tmpvec(regr) = 1;
    %         eval(['CntrP.' factlevel{mainlist(m)}{shift} '=tmpvec']);
    %     end;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{mi}.fmain.fnum = mainlist(m);
end;
for i = 1:ninter
    mi = mi + 1;
    %     add = length(factlevel{interlist{i}(1)});
    %     for cross = 2:length(interlist{i})
    %         add = nlevel(interlist{i}(cross))*add;
    %     end;
    %     regr = regr + add;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{mi}.inter.fnums = interlist{i};
end;
if nfact < 3 % for subject
    mi = mi + 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{mi}.fmain.fnum = nfact+1;
end;

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = ~includeNaN;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
% matlabbatch{1}.spm.stats.factorial_design.masking.em = {which('rMask_withoutCerebelum.nii')};
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
filestruct = dir(fullfile(Design_dir,'SPM.mat'));
filelist = {};
for i = 1:length(filestruct)
    filelist{i} = fullfile(Design_dir,filestruct(i).name);
end;
matlabbatch{1}.spm.stats.fmri_est.spmmat = filelist;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
existfile = dir(fullfile(Design_dir,'beta*'));
if isempty(existfile)
    spm_jobman('run',matlabbatch);
end;

% Contrast
cd(Design_dir);
existfile1 = dir(fullfile(Design_dir,'*beta*'));
existfile2 = dir(fullfile(Design_dir,'*spmT*'));
if isempty(existfile1) || ~isempty(existfile2)
else
    %     ci = 0;
    %     for c = 1:length(cname)
    %         cnametmp = cname{c};
    %         if ~sum(cnametmp == '+') && ~sum(cnametmp == '-')
    %             if ctype{c} ~= 'F'
    %                 warning('Type of %s is wrong, convert to F-contrast',cnametmp);
    %                 ctype{c} == 'F';
    %             end;
    %             tp = find(cnametmp == ':')
    %             if isempty(tp) % interaction
    %                cons = ;
    %             else % main effect
    %                 ifac = find(ismember(factname,cname{c}));
    %                 if isempty(ifac)
    %                     error('%s: Main effect name error',cname{c});
    %                 end;
    %                 nlevel = length(factlevel{ifac});
    %                 cons = zeros(nlevel,regr);
    %             end;
    %         elseif sum(cnametmp == '+') || sum(cnametmp == '-')
    %             if ctype{c} ~= 'T'
    %                 warning('Type of %s is wrong, convert to T-contrast',cnametmp);
    %                 ctype{c} == 'T';
    %             end;
    %         end;
    %     end;
    numsub = sz;
    numcon = 0;
    
    numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Block_F';
    simp{numcon}=[1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0 zeros(1,numsub); 0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'F';
    
    numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Agent_F';
    simp{numcon}=[0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'F';
    
    numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Block_1-2_t';
    simp{numcon}=[1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0 zeros(1,numsub) ];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    numcon = numcon+1;
    effects{numcon} = '-Main_Effect_Block_1-2_t';
    simp{numcon}=-[1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0 zeros(1,numsub) ];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Block_2-3_t';
    simp{numcon}=[0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    numcon = numcon+1;
    effects{numcon} = '-Main_Effect_Block_2-3_t';
    simp{numcon}=-[0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
     numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Block_1-3_t';
    simp{numcon}=[1 0 -1 0 0 1/2 1/2 0 0 -1/2 -1/2 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    numcon = numcon+1;
    effects{numcon} = '-Main_Effect_Block_1-3_t';
    simp{numcon}=-[1 0 -1 0 0 1/2 1/2 0 0 -1/2 -1/2 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Main_Effect_Agent_t';
    simp{numcon}=[0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    numcon = numcon+1;
    effects{numcon} = '-Main_Effect_Agent_t';
    simp{numcon}=-[0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_F';
    simp{numcon}=[0 0 0 0 0 1 -1 -1 1 0 0 zeros(1,numsub) ;
        0 0 0 0 0 0 0 1 -1 -1 1 zeros(1,numsub);
        0 0 0 0 0 1 -1 0 0 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'F';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_1-2_T';
    simp{numcon}=[0 0 0 0 0 1 -1 -1 1 0 0 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_2-1_T';
    simp{numcon}=-[0 0 0 0 0 1 -1 -1 1 0 0 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_2-3_T';
    simp{numcon}=[0 0 0 0 0 0 0 1 -1 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_3-2_T';
    simp{numcon}=-[0 0 0 0 0 0 0 1 -1 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_1-3_T';
    simp{numcon}=[0 0 0 0 0 1 -1 0 0 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_3-1_T';
    simp{numcon}=-[0 0 0 0 0 1 -1 0 0 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_1-23_T';
    simp{numcon}=[0 0 0 0 0 1 -1 -.5 .5 -.5 .5 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'Interaction_12-3_T';
    simp{numcon}=[0 0 0 0 0 .5 -.5 .5 -.5 -1 1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'main1_s-o_T';
    simp{numcon}=[1 0 0 1 -1 1 -1 0 0 0 0 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    numcon = numcon+1;
    effects{numcon} = 'main2_s-o_T';
    simp{numcon}=[0 1 0 1 -1 0 0 1 -1 0 0 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
     numcon = numcon+1;
    effects{numcon} = 'main3_s-o_T';
    simp{numcon}=[0 0 1 1 -1 0 0 0 0 1 -1 zeros(1,numsub)];
    cons{numcon} = [simp{numcon}];
    efftype{numcon} = 'T';
    
    SPMest=load('SPM.mat');
    SPMest=SPMest.SPM;
    SPMest.xCon =[];
    for i = 1:size(effects,2)
        if isempty(SPMest.xCon)
            SPMest.xCon = spm_FcUtil('Set',effects{i}, efftype{i},'c',cons{i}',SPMest.xX.xKXs);
        else
            SPMest.xCon (end+1) = spm_FcUtil('Set',effects{i}, efftype{i},'c',cons{i}',SPMest.xX.xKXs);
        end
    end
    spm_contrasts(SPMest);
    %% report contrast results
    if report == 1
        first_result_report.threshdesc = {'none'};
        first_result_report.thresh = [0.005];
        first_result_report.extent = [20];
        % result report spm
        for c = 1:numcon
            for i = 1:length(first_result_report.threshdesc)
                clear matlabbatch;
                matlabbatch{1}.spm.stats.results.spmmat = {fullfile(Design_dir,'SPM.mat')};
                matlabbatch{1}.spm.stats.results.conspec.titlestr = effects{c};
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