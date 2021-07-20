%%%%%%%%%%%%%%%%%%%%%%
%%%% PPI_contrast %%%%
%%%%%%%%%%%%%%%%%%%%%%

data_fad = '/data1/FengWangshu/CI_fMRI/FirstLevel_PPI';
SubList = dir(fullfile(data_fad,'Zhou*'));
contrast_dir = {};

data_source = '/data1/FengWangshu/CI_fMRI/NIFTI'; % NIFTI path of all subs


nb_sess =2;

spm('Defaults','fMRI');
spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)

for sub = 1:1%length (SubList)
    for sess =1:nb_sess

clear jobs

data_path = fullfile(data_fad,SubList(sub).name);
VOI_path = fullfile(data_fad,SubList(sub).name,'VOI');
jobs{1}.util{1}.cdir.directory = cellstr(data_path);
spm_jobman('run',jobs);


load ([VOI_path '/VOI_rAG_' num2str(sess) '.mat']);
PPI = spm_peb_ppi(fullfile(data_path,'SPM.mat'),'ppi',xY,...
    [1 1 -1;2 1 1],['rAG_b-a',num2str(sess)],1);
    %number of condition, 1, contrast
    
clear jobs
PPI_dir = [data_path,'/PPI'];

if ~exist (PPI_dir)
    mkdir(PPI_dir);
end

jobs{1}.util{1}.md.basedir = cellstr(PPI_dir);
jobs{1}.util{1}.md.name = 'PPI';
spm_jobman('run',jobs);
    end
end

% 
for sub=1:1%length(SubList)
    
    old_path=fullfile(data_fad, SubList(sub).name);
    new_path=fullfile(data_fad, SubList(sub).name,'PPI/rAG/b-a');
    if ~exist (new_path)
        mkdir(new_path);
    end

cd (old_path)
movefile('PPI_*.mat',new_path);
display (['moving files from  ',old_path,' to ',new_path ]);
end;


%%%%%%%%%%%%%%%%%%%%%%
%%%%% make_model %%%%%
%%%%%%%%%%%%%%%%%%%%%%


for subn=1:1%length(SubList)

	Data1_s=[]; % set for 'sw.nii' files in run1
    Data2_s=[];

    
    clear jobs;

%     res_path=fullfile(data_fad,SubList(subn).name,'/PPI/PPI_rAG') % path of each sub & each region
%     if ~exist(res_path)
%     mkdir(res_path);
%     end
%    delete([res_path,'/SPM.mat']);
    
    
    run1dir = dir(fullfile(data_source,SubList(subn).name,'geservice','*8CH_CI1*'));
    run2dir = dir(fullfile(data_source,SubList(subn).name,'geservice','*8CH_CI2*'));
    
    display(['extracting data from ',SubList(subn).name,'...']);
    
    data_path1= fullfile(data_source,SubList(subn).name,'geservice',run1dir.name);
    data_path2= fullfile(data_source,SubList(subn).name,'geservice',run2dir.name);
   
    Data1_s=spm_select('FPList', data_path1, '^sw.*\.nii$');
    Data2_s=spm_select('FPList', data_path2, '^sw.*\.nii$');

    
    %_____________________SPECIFY 1ST-LEVEL_____________________
	jobs{1}.stats{1}.fmri_spec.dir={new_path};
    jobs{1}.stats{1}.fmri_spec.timing.units='secs';
	jobs{1}.stats{1}.fmri_spec.timing.RT=2;
	jobs{1}.stats{1}.fmri_spec.timing.fmri_t=35;
	jobs{1}.stats{1}.fmri_spec.timing.fmri_t0=1;
    %_______Data and Design: Session1_______
      %____________________LOAD MOTION PARA______________
      
    mfilt='^rp_.*\.txt$';
	mfname1 = spm_select ('List',data_path1,mfilt);
    mfname2 = spm_select ('List',data_path2,mfilt);

    move1 = fullfile(data_path1,mfname1);
    move2 = fullfile(data_path2,mfname2);

    PPI_file1 = [new_path,'/PPI_rAG_b-a1.mat'];
    PPI_file2 = [new_path,'/PPI_rAG_b-a2.mat'];

    %%%%%%%run1
    load (PPI_file1);    
    jobs{1}.stats{1}.fmri_spec.sess(1).scans=cellstr(Data1_s);
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).val  = PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).name = 'rAG';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).val  = PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).name = 'b-a';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).val  = PPI.P;
    
    % 	jobs{1}.stats{1}.fmri_spec=struct('fact',{},'levels',{});
    jobs{1}.stats{1}.fmri_spec.sess(1).multi_reg=cellstr(move1);
    
    %%%%%%run2
    load (PPI_file2);    
    jobs{1}.stats{1}.fmri_spec.sess(2).scans=cellstr(Data2_s);
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).val  = PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).name = 'rAG';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).val  = PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).name = 'b-a';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).val  = PPI.P;
    
    
    % 	jobs{1}.stats{1}.fmri_spec=struct('fact',{},'levels',{});
    jobs{1}.stats{1}.fmri_spec.sess(2).multi_reg=cellstr(move2);
    
    
 	jobs{1}.stats{1}.fmri_spec.bases.hrf=struct('derivs',[0 0]); %hrf
    jobs{1}.stats{1}.fmri_spec.volt=1;
	jobs{1}.stats{1}.fmri_spec.global='None';
    jobs{1}.stats{1}.fmri_spec.mask={''};
	jobs{1}.stats{1}.fmri_spec.cvi='AR(1)';


	%_____________________ESTIMATE_____________________
	jobs{1}.stats{2}.fmri_est.spmmat={[new_path,'/','SPM.mat']};
  	jobs{1}.stats{2}.fmri_est.method.Classical=1;
    
	spm_jobman('run',jobs)
    display('mission complete!!! congratulation!')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% firstlevel_contrast %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add contrast

cwd=pwd
% get the subdirectories in the main directory
% datapath= '/data1/FengWangshu/CI_fMRI/FirstLevel_PPI';
% SubList = dir(fullfile(datapath,'Zhou*'));
% contrast_dir = {};    


nsub=length(SubList);
nsub

for i=1:1%nsub
    i
    cwd=pwd;
        
        subj_dir = fullfile(data_fad,SubList(i).name);
    
        cd(new_path);

% set up the contrasts
%         mov=[0 0 0 0 0 0]; %   movements
%         mns=[0 0]; % session means         Step3: change it if you have more than one session


        cname{1} = 'b-a';            %Step4: last step, add contrast!!!{'wingood','lossgood', 'winbad','lossbad'};
%       cons{1} = [1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0];
        
        cons{1} = [1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0];
        ctype{1} ='T';  % contrast type

          
        % Now set up contrasts...
        SPMest=load('SPM.mat');
        SPMest=SPMest.SPM;
        % use this to make the con images
        SPMest.xCon =[];
        for i = 1:size(cname,2)

            if length(SPMest.xCon)==0
                SPMest.xCon = spm_FcUtil('Set',cname{i}, ctype{i},'c',cons{i}',SPMest.xX.xKXs);
            else
                SPMest.xCon (end+1) = spm_FcUtil('Set',cname{i}, ctype{i},'c',cons{i}',SPMest.xX.xKXs);
            end
        end

        spm_contrasts(SPMest);

        cd (cwd);
 
end;



%%%%%%%%%%%%%%%%%%%%%%
%%% extra_contrast %%%
%%%%%%%%%%%%%%%%%%%%%%

function CreateRFX
clear; % Clean up your workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Change your parameters in following section:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cwd = '/data1/FengWangshu/CI_fMRI/FirstLevel_PPI';
% SubList = dir(fullfile(cwd,'Zhou*'));
% contrast_dir = {}; 

cwdadd = '/data1/FengWangshu/CI_fMRI/FirstLevel_PPI/PPI_result/rAG_b-a';
mkdir(cwdadd);


stats = 'PPI/rAG/b-a';               %The name of dir of stats 'sub10'
%?? nses = 2;                       %How many sessions per subject?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End of your parameters section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_defaults
global defaults
cd(cwd)   % CHANGE TO YOUR PATH
tic

RFXHOME = cwdadd;

subdir = fullfile(cwd,SubList(1).name);
cd(subdir);
cd(stats);
load SPM;

ocon=length(SPM.xCon);   %How many contrasts are totally in SPM.mat.
ionc=1;
%length(SPM.Sess(1).U)*length(SPM.Sess)+1+1; %The order that user define

%create rfxdir of every contrast defined by users
for xcon= ionc:ocon
    swd=SPM.xCon(xcon).name;
    swd(find(swd == ' ')) = '';
    swd(find(swd == '&')) = '+';
    rfxdir=fullfile(RFXHOME, sprintf('%d_%s',xcon,swd));
    if (exist(rfxdir) ~= 7)
        disp(sprintf('creating %s directory',rfxdir)) 
        switch (spm_platform('filesys'))
            case 'win' 
                eval(sprintf('!md %s', rfxdir));
            case 'unx'
                eval(sprintf('!mkdir %s', rfxdir));
        end
    end
end

for subnum = 1:1%length(SubList)
    
    %disp(sprintf('copying sub%d files',subs(sub))) 

    subdir = fullfile(cwd, SubList(subnum).name);
    cd(subdir);
    cd(stats);
    load SPM;
    pwd
    
    for xcon= ionc:ocon
        swd=SPM.xCon(xcon).name;
        swd(find(swd == ' ')) = '';
        swd(find(swd == '&')) = '+';
        rfxdir=fullfile(RFXHOME, sprintf('%d_%s',xcon,swd));
        
        
        surfile=SPM.xCon(xcon).Vcon.fname;
        if xcon < 10
            desfile=fullfile(rfxdir, [SubList(subnum).name, sprintf('_con_000%d.img',xcon)]);
        elseif xcon >= 10
            desfile=fullfile(rfxdir, [SubList(subnum).name, sprintf('_con_00%d.img', xcon)]);
        end
        % desfile=fullfile(rfxdir, sprintf('sub%d_%s', sub, SPM.xCon(xcon).Vcon.fname));
        copyfile(surfile,desfile);
        
        [pth,nam,ext] = fileparts(surfile);
        hdr_surfile=fullfile(pth,[nam '.hdr']);
        if xcon < 10
            hdr_desfile=fullfile(rfxdir, [SubList(subnum).name,sprintf('_con_000%d.hdr', xcon)]);
        elseif xcon >= 10
            hdr_desfile=fullfile(rfxdir, [SubList(subnum).name,sprintf('_con_00%d.hdr', xcon)]);
        end
        copyfile(hdr_surfile,hdr_desfile);
    end
    
end % for sub
disp(sprintf('.........copying files is over.........')) 
toc

