% add contrast
clear all;
cwd=pwd
% get the subdirectories in the main directory
datapath= 'E:\ShenBo\GR\Model\FirstLevel';
SubList = dir(fullfile(datapath,'2*'));
% contrast_dir = {};


nsub=length(SubList);
nsub

for i=1:nsub
    i
    cwd=pwd;
    
    subj_dir = fullfile(datapath,SubList(i).name);
    
    %number of blocks
    %         nsess = 1;
    
    %         movefilt = '^rp_.*\.txt$';
    %         mnames = {'x_trans' 'y_trans' 'z_trans' 'x_rot' 'y_rot' 'z_rot'};
    
    %  analysis directory
    stats_suffix='\PPI\PPI_rAI_C3_Sh_S-O';
    anadir = fullfile(subj_dir, stats_suffix);
    
    cd(anadir);
    
    % set up the contrasts
    mov=[0 0 0 0 0 0]; %   movements
    mns=[0 0 0]; % 5 session means         Step3: change it if you have more than one session
    
    
    cname{1} = 'rAI_C3_Sh_S-O';            %Step4: last step, add contrast!!!{'wingood','lossgood', 'winbad','lossbad'};
    cons{1} = [1 0 0 mov 1 0 0 mov 1 0 0 mov mns]; % 3nrun nconstants %%%%%%%
    ctype{1} ='T';  % contrast type
%     cname{2} = '-C3_Sh_S-O';            %Step4: last step, add contrast!!!{'wingood','lossgood', 'winbad','lossbad'};
%     cons{2} = -[1 0 0 mov 1 0 0 mov 1 0 0 mov mns]; % 3nrun nconstants %%%%%%%
%     ctype{2} ='T';  % contrast type
    
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



