
%%
% % % script for multisubject VOI extraction
% % %=======================================================================
% % %             ________  ____  ____  ___
% % %            / ___/ _ \/ __ \/ __ \/ _ \
% % %           (__  )  __/ /_/ / /_/ /  __/
% % %          /____/\___/ .___/ .___/\___/
% % %                   /_/   /_/
% % %
% % % script written by Seppe Santens, 99% of the code stolen from Friston
% % %=======================================================================
% % 
% % 
warning('off','MATLAB:dispatcher:InexactMatch');
% make sure the scriptdir is in the path
addpath(pwd);
data_fad = '/data1/YuHongbo/cui_expectation/NIFTI150208_noT1';
% subs={'cuixirui_01'  'cuixirui_04' 'cuixirui_05' 'cuixirui_06' 'cuixirui_07' 'cuixirui_08' 'cuixirui_10' 'cuixirui_11' 'cuixirui_12' 'cuixirui_13' 'cuixirui_14' 'cuixirui_15'  'cuixirui_16' 'cuixirui_17' 'cuixirui_18' 'cuixirui_19' 'cuixirui_20' 'cuixirui_21'  'cuixirui_22'  'cuixirui_23' 'cuixirui_25'  'cuixirui_26' 'cuixirui_28'};% 'cuixirui_12' 'sub113' 'sub113' 'sub114' 'sub115' 'sub116'  'sub103' 'sub104' 'sub105' 'sub106' 'sub107' 'sub108' 'sub109' 'sub111' 'sub112' 'sub114' 'sub115' 'sub116' 'sub118' 'sub119' 'sub120' 'sub121' 'sub122' 'sub124' 'sub125' 'sub126' 'sub127' 'sub128' 'sub129' 'sub130' };%'sub105' 'sub106' 'sub107' 'sub108' 'sub109' 'sub110' 'sub111' 'sub112' 'sub113' 'sub113' 'sub114' 'sub115' 'sub116' 'sub117' 'sub118' };% 'sub101' 'sub102' 'sub103''sub4' 'sub5' 'sub6' 'sub7' 'sub8' 'sub9' 'sub10' 'sub11' 'sub12' 'sub13' 'sub14' 'sub15' 'sub16'};%{ 'sub2'  'sub3' 'sub4' 'sub5' 'sub6' 'sub7' 'sub8' 'sub9' 'sub10' 'sub11' 'sub12'};
 subs={'cuixirui_03'};
% rootDIR =[]; 'sub113'
%%%%'sub116' 'sub117' 'sub118' 'sub119' 'sub120' 'sub121' 

% set parameters
nsessions = 2;
nsubjects =length(subs);

% VOIx = 9;
% VOIy = 14;
% VOIz = -14;
% VOIname = 'rVS_pain_nopain';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;   

% VOIx = -12;
% VOIy = 14;
% VOIz = -17;
% VOIname = 'lVS_pain_nopain';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;  

% VOIx = 15;
% VOIy = -1;
% VOIz = -11;
% VOIname = 'midbrain_interaction';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;       

% VOIx = 3;
% VOIy = -16;
% VOIz = -8;
% VOIname = 'midbrain_pain-nopain';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;    

% VOIx = 6;
% VOIy = 9;
% VOIz = -9;
% VOIname = 'rVS_dreher';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;  

VOIx = 2;
VOIy = -12;
VOIz = -10;
VOIname = 'VTA_Pecina';% 
VOIdef = 'sphere';                                  % type of VOI
VOIradius = 4; 

%%%%%% PPI voi
% VOIx = 51;
% VOIy = -1;
% VOIz = -8;
% VOIname = 'rIns_PPI';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;  

% VOIx = -6;
% VOIy = 17;
% VOIz = 28;
% VOIname = 'MCC_PPI';% 
% VOIdef = 'sphere';                                  % type of VOI
% VOIradius = 4;  


VOIxyz = [VOIx VOIy VOIz];

% create a subject loop
for subj = 1:nsubjects
% VOIx = individual_x (subj);
% VOIy = individual_y (subj);
% VOIz = individual_z (subj);

    x=subj;
      rootDIR = fullfile(data_fad,subs{subj},'stat/noT1_outcome_T0ts_noTD');
      VOI_dir = fullfile(data_fad,subs{subj},'stat/noT1_outcome_T0ts_noTD/VOI');
     
    if ~exist(VOI_dir)
    mkdir(VOI_dir);
    end
    
    fprintf('Working on participant %d\n',subj);

    SJ = sprintf('pp%02d',x);
    % take subject directory
    swd = rootDIR;
    %change to the subjects directory
    cd(swd);




    %=======================================================================
    % - C O P Y   P A S T I N G   F R O M   spm_getSPM.m
    %=======================================================================

    %-Load SPM.mat
    %-----------------------------------------------------------------------

    load(fullfile(swd,'SPM.mat'));
    SPM.swd = swd;

    %-Get volumetric data from SPM.mat
    %-----------------------------------------------------------------------
    try
        xX   = SPM.xX;                  %-Design definition structure
        XYZ  = SPM.xVol.XYZ;			%-XYZ coordinates
        S    = SPM.xVol.S;              %-search Volume {voxels}
        R    = SPM.xVol.R;              %-search Volume {resels}
        M    = SPM.xVol.M(1:4,1:4);		%-voxels to mm matrix
        VOX  = sqrt(diag(M'*M))';		%-voxel dimensions
    catch
        error ('This model has not been estimated.');
    end

    %-----------------------------------------------------------------------
    % - SKIPPING ALL (HOPEFULLY) UNNECESSARY STEPS
    %-----------------------------------------------------------------------

    %-Assemble ONLY NECESSARY output structures of unfiltered data
    %-----------------------------------------------------------------------
    xSPM   = struct('swd',		swd,...                                         
                    'XYZ',		XYZ,...                                         
                    'XYZmm',	SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))]);  
% location of voxels {mm}

    for VOIsession=1:nsessions

        fprintf('\tWorking on session %d\n',VOIsession);

        
%=======================================================================
        % - C O P Y   P A S T I N G   F R O M   spm_regions.m
        
%=======================================================================

        % xY     - VOI structure
        
%-----------------------------------------------------------------------
        try
            xY;
        catch
            xY = {};
        end

        %-Find nearest voxel [Euclidean distance]
        
%-----------------------------------------------------------------------
        if ~length(xSPM.XYZmm)
            spm('alert!','No suprathreshold voxels!',mfilename,0);
            Y = []; xY = [];
            return
        end
        [xyz,i] = spm_XYZreg('NearestXYZ',VOIxyz,xSPM.XYZmm);
        xY.xyz  = xyz;


        %-Get adjustment options and VOI name
        %------------------------------------------------------------------
        xY.name = VOIname;

        xY.Ic = 6;                      % effects of interest/No. of interested regressors

        %-if fMRI data get sessions and filtering options
        
%-----------------------------------------------------------------------
       % if isfield(SPM,'Sess')

        %    s         = length(SPM.Sess);
%             if s > 1
                s = VOIsession;
%             end
                xY.Sess   = s;

%         end

        %-Specify VOI
        
%-----------------------------------------------------------------------
        if ~isfield(xY,'def')
            xY.def    = VOIdef;
        end
        Q       = ones(1,size(xSPM.XYZmm,2));

        switch xY.def

            case 'sphere'
            %---------------------------------------------------------------
            if ~isfield(xY,'spec')
                xY.spec = VOIradius;
            end
            d     = [xSPM.XYZmm(1,:) - xyz(1);
                 xSPM.XYZmm(2,:) - xyz(2);
                 xSPM.XYZmm(3,:) - xyz(3)];
            Q     = find(sum(d.^2) <= xY.spec^2);

            case 'box'
            %---------------------------------------------------------------
            if ~isfield(xY,'spec')
                xY.spec = spm_input('box dimensions [x y z] {mm}',...
                    '!+0','r','0 0 0',3);
            end
            Q     = find(all(abs(xSPM.XYZmm - xyz*Q) <= xY.spec(:)*Q/2));

            case 'cluster'
            %---------------------------------------------------------------
            [x i] = spm_XYZreg('NearestXYZ',xyz,xSPM.XYZmm);
            A     = spm_clusters(xSPM.XYZ);
            Q     = find(A == A(i));
        end

        %-Extract required data from results files
        
%=======================================================================

        %-Get raw data, whiten and filter
        
%-----------------------------------------------------------------------
        y        = spm_get_data(SPM.xY.VY,xSPM.XYZ(:,Q));
        y        = spm_filter(SPM.xX.K,SPM.xX.W*y);
        xY.XYZmm = xSPM.XYZmm(:,Q);

        %-Computation
        
%=======================================================================

        % remove null space of contrast
        
%-----------------------------------------------------------------------
        if xY.Ic

            %-Parameter estimates: beta = xX.pKX*xX.K*y
            %---------------------------------------------------------------
            beta  = spm_get_data(SPM.Vbeta,xSPM.XYZ(:,Q));

            %-subtract Y0 = XO*beta,  Y = Yc + Y0 + e
            %---------------------------------------------------------------
            y     = y - spm_FcUtil('Y0',SPM.xCon(13),SPM.xX.xKXs,beta);

        end

        % confounds
        
%-----------------------------------------------------------------------
        xY.X0     = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);

        % extract session-specific rows from data and confounds
        
%-----------------------------------------------------------------------
        try
            i     = SPM.Sess(xY.Sess).row;
            y     = y(i,:);
            xY.X0 = xY.X0(i,:);
        end

        % and add session-specific filter confounds
        
%-----------------------------------------------------------------------
        try
            xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).X0];
        end

        
%=======================================================================
        try
            xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).KH]; % Compatibility check
        end
        
%=======================================================================


        % Remove null space of X0
        
%-----------------------------------------------------------------------
        xY.X0   = xY.X0(:,~~any(xY.X0));


        % compute regional response in terms of first eigenvariate
        
%-----------------------------------------------------------------------
        [m n]   = size(y);
        if m > n
            [v s v] = svd(spm_atranspa(y));
            s       = diag(s);
            v       = v(:,1);
            u       = y*v/sqrt(s(1));
        else
            [u s u] = svd(spm_atranspa(y'));
            s       = diag(s);
            u       = u(:,1);
            v       = y'*u/sqrt(s(1));
        end
        d       = sign(sum(v));
        u       = u*d;
        v       = v*d;
        Y       = u*sqrt(s(1)/n);

        % set in structure
        
%-----------------------------------------------------------------------
        xY.y    = y;
        xY.u    = Y;
        xY.v    = v;
        xY.s    = s;

        % save
        
%-----------------------------------------------------------------------
        str     = ['VOI_' xY.name];
        if isfield(xY,'Sess')
            if length(xY.Sess) == 1
                str = sprintf('VOI_%s_%i',xY.name,xY.Sess);
            end
        end
        fprintf('\t\tsaving file %s\n',str);
         current_dir =  VOI_dir;
        save_name = [current_dir,'/',str]
        save(save_name,'Y','xY')

    end

    cd (rootDIR);
   %rootDIR =['C:\Li_data\first_level\modified_hrf\']; 
end

clear all;
% 
