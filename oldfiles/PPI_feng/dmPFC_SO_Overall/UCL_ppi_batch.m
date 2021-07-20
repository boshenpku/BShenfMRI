% This batch script analyses the Attention to Visual Motion fMRI dataset
% available from the SPM site using PPI:
% http://www.fil.ion.ucl.ac.uk/spm/data/attention/
% as described in the SPM manual:
%  http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf

% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin & Darren Gitelman
% $Id: ppi_spm_batch.m 17 2009-09-28 15:37:01Z guillaume $

% Directory containing the attention data
%---------------------------------------------------------------------

ROIname = {'ROIGuiltMainrAI3617-5'...% main effect of guilt
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_MTG-51-7022'...% C1S-O & C2S-O & C1S-C3S & C2S-C3S, 请求原谅
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_Precuneus-3-6434'...
    'ROI1C1S-O&C2S-O&C1S-C3S&C2S-C3S_PCC-3-4022'...
    'ROI2C1S-O&C12S&C13S_STG-60-3119'...% C1S-O & C1S-C2S & C1S-C3S， 减少疼痛
    'ROI2C1S-O&C12S&C13S_SMG51-2825'... %6
    'ROI2C1S-O&C12S&C13S_vmPFC-347-8'...
    'ROI3C1S-O&C2S-O&C3S-O_LAG-54-6734'...% C1S-O & C2S-O & C3S-O， 自我惩罚
    'ROI3C1S-O&C2S-O&C3S-O_RAG54-6731'...
    'ROI3C1S-O&C2S-O&C3S-O_Precuneus-6-5528'...
    'ROI3C1S-O&C2S-O&C3S-O_dmPFC185343'...
    'ROI3C1S-O&C2S-O&C3S-O_dmPFC-155043'}; %12
data_fad = 'E:\ShenBo\GR\Model\FirstLevel';
SubList = dir(fullfile(data_fad,'2*'));
VOIName = ROIname{12};
PPIName = 'PPI_dmPFC_SO';
contrastmatrix = [3 1 1;4 1 -1;5 1 1;6 1 -1;7 1 1; 8 1 -1];
nb_sess =3;
% Initialise SPM
%---------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)

for sub = 1:length (SubList)
    for sess =1:nb_sess
        % Working directory (useful for .ps outputs only)
        %---------------------------------------------------------------------
        clear jobs
        
        data_path = fullfile(data_fad,SubList(sub).name);
        VOI_path = fullfile(data_fad,SubList(sub).name,'VOI');
        jobs{1}.util{1}.cdir.directory = cellstr(data_path);
        spm_jobman('run',jobs);
        
        
        load (fullfile(VOI_path, ['VOI_' VOIName '_' num2str(sess) '.mat']));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PSYCHO-PHYSIOLOGIC INTERACTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % GENERATE PPI STRUCTURE
        % =====================================================================
        PPI = spm_peb_ppi(fullfile(data_path,'SPM.mat'),'ppi',xY,...
            contrastmatrix,[PPIName,num2str(sess)],1);   % contrast!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %number of condition, 1, contrast
        
        clear jobs
        PPI_dir = fullfile(data_path,'PPI',PPIName);
        
        if ~exist (PPI_dir)
            mkdir(PPI_dir);
        end;
        
        jobs{1}.util{1}.md.basedir = cellstr(PPI_dir);
        jobs{1}.util{1}.md.name = 'PPI';
        spm_jobman('run',jobs);
    end;
end;

%
for sub=1:length(SubList)
    
    %dicom_path = fullfile(dicomfad, dicom_sub{subnr},'\attractive')
    old_path=fullfile(data_fad, SubList(sub).name);
    %mkdir([raw_path, '\gender']);
    new_path=fullfile(data_fad, SubList(sub).name,'PPI',PPIName);
    if ~exist (new_path)
        mkdir(new_path);
    end
    %destination2=fullfile(dicomfad, dicom_sub{subnr},'\attractive\run2');
    
    cd (old_path)
    movefile('PPI_*.mat',new_path);
    %copyfile('rp*.txt',new_path);
    % movefile('fr*-0002-*.hdr',destination1);
    display (['moving files from  ',old_path,' to ',new_path ]);
    % movefile('fr*-0003-*.img',destination2);
    % movefile('fr*-0003-*.hdr',destination2);
    % display (['moving files from',dicom_path,'to',destination2 ]);
end;