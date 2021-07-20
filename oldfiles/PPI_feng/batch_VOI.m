
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
data_fad = 'E:\ShenBo\GR\Model\FirstLevel';
SubList = dir(fullfile(data_fad,'2*'));
% set parameters
nsessions = 3;
FconLocation = 25; % the location of F contrast

%%%%%%%%%%%%%%%%%%%%%%%%%%%% VOI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOIx = 36;
% VOIy = 17;
% VOIz = -5;
% VOIname = 'rAI'; % Guilt Main effect

ROIname = {'ROIGuiltMainrAI3617-5'...% main effect of guilt
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_MTG-51-7022'...% C1S-O & C2S-O & C1S-C3S & C2S-C3S, 请求原谅
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_Precuneus-3-6434'...
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_PCC-3-4022'...
    'ROI2C1S-O&C12S&C13S_STG-60-3119'...% C1S-O & C1S-C2S & C1S-C3S， 减少疼痛
    'ROI2C1S-O&C12S&C13S_SMG51-2825'...
    'ROI2C1S-O&C12S&C13S_vmPFC-347-8'...
    'ROI3C1S-O&C2S-O&C3S-O_LAG-54-6734'...% C1S-O & C2S-O & C3S-O， 自我惩罚
    'ROI3C1S-O&C2S-O&C3S-O_RAG54-6731'...
    'ROI3C1S-O&C2S-O&C3S-O_Precuneus-6-5528'...
    'ROI3C1S-O&C2S-O&C3S-O_dmPFC185343'...
    'ROI3C1S-O&C2S-O&C3S-O_dmPFC-155043'};
coordinate = [
    36 17 -5;
    -51 -70 22;
    -3 -64 34;
    -3 -40 22;
    -60 -31 19;
    51 -28 25;
    -3 47 -8;
    -54 -67 34;
    54 -67 31;
    -6 -55 28;
    18 53 43;
    -15 50 43];

outputxyz = []; % just for test
for roi = 12:length(ROIname)
    VOIx = coordinate(roi,1);
    VOIy = coordinate(roi,2);
    VOIz = coordinate(roi,3);
    VOIname = ROIname{roi};
    

    VOIdef = 'sphere';                                  % type of VOI
    VOIradius = 3;
    
    
    
    
    VOIxyz = [VOIx VOIy VOIz];
    
    % create a subject loop
    for subj = 1:length(SubList)
        % VOIx = individual_x (subj);
        % VOIy = individual_y (subj);
        % VOIz = individual_z (subj);
        
        x=subj;
        rootDIR = fullfile(data_fad,SubList(subj).name);
        VOI_dir = fullfile(data_fad,SubList(subj).name,'VOI');
        
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
            outputxyz = [outputxyz;xyz];
            
            %-Get adjustment options and VOI name
            %------------------------------------------------------------------
            xY.name = VOIname;
            
            xY.Ic = FconLocation;                      % effects of interest/No. of interested regressors
            
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
                y     = y - spm_FcUtil('Y0',SPM.xCon(xY.Ic),SPM.xX.xKXs,beta); % F-test is the 1st contrast
                
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
    end;
    
end;
% clear all;
%
