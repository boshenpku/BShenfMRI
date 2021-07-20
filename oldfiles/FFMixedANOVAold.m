function FFMixedANOVA(conditions,design,maininters,cname,ctype,secondleveldir,subjlist,report)
if (length(conditions) ~= length(design))
    error('Number of conditions and design miss match');
end;
if (length(cname) ~= length(ctype))
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
sz = length(subjlist);
i = 0;
Cond_mat = [];
for c = 1:length(conditions)
    tmp = [];
    for f = 1:nfact
        tmp = [tmp,str2double(condmat{f}{c}(end))];
    end;
    for subj = 1:sz
        i = i + 1;
        filelist{i} = fullfile(secondleveldir,conditions{c},[subjlist{subj},'_',conditions{c},'.img']);
        if length(tmp) == 1
            Cond_mat = [Cond_mat;[i tmp subj 1]];
        elseif length(tmp) == 2
            Cond_mat = [Cond_mat;[i tmp subj]];
        elseif length(tmp) == 3
            Cond_mat = [Cond_mat;[i tmp]];
        end;
    end;
end;
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

matlabbatch{1}.spm.stats.factorial_design.dir = {Design_dir};
for f = 1:nfact
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).name = factname{f};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).dept = 1; % independence No
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).variance = 0;% variance equal 
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f).ancova = 0;
end;
if nfact < 3
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).name = 'subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).dept = 0; % independence Yes
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).variance = 0;% variance equal 
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(f+1).ancova = 0;
elseif nfact >= 3
    error('only 2 Factors allowed for this script');
end;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = filelist;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = Cond_mat;
mi = 0;
regr = sz+sum(nlevel(mainlist))+ nlevel(1)*nlevel(2);
if nfact < 3 % for subject
    mi = mi + 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{mi}.fmain.fnum = nfact+1;
end;
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
    cname{numcon} = 'Main_Effect_Block_F';
    simp{numcon}=[zeros(1,numsub) 1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0; zeros(1,numsub)  0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'F';
    
    numcon = numcon+1;
    cname{numcon} = 'Main_Effect_Agent_F';
    simp{numcon}=[zeros(1,numsub) 0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'F';
    
    numcon = numcon+1;
    cname{numcon} = 'Main_Effect_Block_1-2_t';
    simp{numcon}=[zeros(1,numsub) 1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    numcon = numcon+1;
    cname{numcon} = '-Main_Effect_Block_1-2_t';
    simp{numcon}=-[zeros(1,numsub) 1 -1 0 0 0 1/2 1/2 -1/2 -1/2 0 0];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Main_Effect_Block_2-3_t';
    simp{numcon}=[zeros(1,numsub)  0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    numcon = numcon+1;
    cname{numcon} = '-Main_Effect_Block_2-3_t';
    simp{numcon}=-[zeros(1,numsub)  0 1 -1 0 0 0 0 1/2 1/2 -1/2 -1/2];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
     numcon = numcon+1;
    cname{numcon} = 'Main_Effect_Block_1-3_t';
    simp{numcon}=[zeros(1,numsub) 1 0 -1 0 0 1/2 1/2 0 0 -1/2 -1/2];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    numcon = numcon+1;
    cname{numcon} = '-Main_Effect_Block_1-3_t';
    simp{numcon}=-[zeros(1,numsub) 1 0 -1 0 0 1/2 1/2 0 0 -1/2 -1/2];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Main_Effect_Agent_t';
    simp{numcon}=[zeros(1,numsub) 0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    numcon = numcon+1;
    cname{numcon} = '-Main_Effect_Agent_t';
    simp{numcon}=-[zeros(1,numsub) 0 0 0 1 -1 1/3 -1/3 1/3 -1/3 1/3 -1/3];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_F';
    simp{numcon}=[zeros(1,numsub) 0 0 0 0 0 1 -1 -1 1 0 0;
        zeros(1,numsub) 0 0 0 0 0 0 0 1 -1 -1 1;
        zeros(1,numsub) 0 0 0 0 0 1 -1 0 0 -1 1];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'F';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_1-2_T';
    simp{numcon}=[zeros(1,numsub) 0 0 0 0 0 1 -1 -1 1 0 0];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_2-1_T';
    simp{numcon}=-[zeros(1,numsub) 0 0 0 0 0 1 -1 -1 1 0 0];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_2-3_T';
    simp{numcon}=[zeros(1,numsub) 0 0 0 0 0 0 0 1 -1 -1 1];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_3-2_T';
    simp{numcon}=-[zeros(1,numsub) 0 0 0 0 0 0 0 1 -1 -1 1];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_1-3_T';
    simp{numcon}=[zeros(1,numsub) 0 0 0 0 0 1 -1 0 0 -1 1];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    numcon = numcon+1;
    cname{numcon} = 'Interaction_3-1_T';
    simp{numcon}=-[zeros(1,numsub) 0 0 0 0 0 1 -1 0 0 -1 1];
    cons{numcon} = [simp{numcon}];
    ctype{numcon} = 'T';
    
    SPMest=load('SPM.mat');
    SPMest=SPMest.SPM;
    SPMest.xCon =[];
    for i = 1:size(cname,2)
        if isempty(SPMest.xCon)
            SPMest.xCon = spm_FcUtil('Set',cname{i}, ctype{i},'c',cons{i}',SPMest.xX.xKXs);
        else
            SPMest.xCon (end+1) = spm_FcUtil('Set',cname{i}, ctype{i},'c',cons{i}',SPMest.xX.xKXs);
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
                matlabbatch{1}.spm.stats.results.conspec.titlestr = cname{c};
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