

func_path= 'E:\ShenBo\GR\Model\FirstLevel';%PPI path
SubList = dir(fullfile(func_path,'2*'));
contrast_dir = {};
data_source = 'E:\ShenBo\GR\nifti';%NIFTI path

for subn=1:4%length(SubList)
   
    Data1_s=[];
    Data2_s=[];
    Data3_s = [];
    
    
    clear jobs;
    
    res_path=fullfile(func_path,SubList(subn).name,'/PPI/PPI_rAI_C1_Sh_S-O')
    if ~exist(res_path,'dir')
        error('PPI has not been made yet!');
    end
    %    delete([res_path,'/SPM.mat']);
    
    
    %     run1dir = dir(fullfile(data_source,SubList(subn).name,'geservice','*8CH_CI1*'));
    run1dir = dir(fullfile(data_source,SubList(subn).name,'*RUN1*'));
    run2dir = dir(fullfile(data_source,SubList(subn).name,'*RUN2*'));
    run3dir = dir(fullfile(data_source,SubList(subn).name,'*RUN3*'));
    
    
    display(['extracting data from ',SubList(subn).name,'...']);
    
    data_path1= fullfile(data_source,SubList(subn).name,run1dir.name);
    data_path2= fullfile(data_source,SubList(subn).name,run2dir.name);
    data_path3= fullfile(data_source,SubList(subn).name,run3dir.name);
    
    
    Data1_s=spm_get('Files', data_path1, 'sssnnn*.nii');
    Data2_s=spm_get('Files', data_path2, 'sssnnn*.nii');
    Data3_s=spm_get('Files', data_path3, 'sssnnn*.nii');
    
    %_____________________SPECIFY 1ST-LEVEL_____________________
    jobs{1}.stats{1}.fmri_spec.dir={res_path};
    
    jobs{1}.stats{1}.fmri_spec.timing.units='secs';
    jobs{1}.stats{1}.fmri_spec.timing.RT=2;
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t=40;
    jobs{1}.stats{1}.fmri_spec.timing.fmri_t0=20;
    %_______Data and Design: Session1_______
    %____________________LOAD MOTION PARA______________
    
    mfilt='^rp_.*\.txt$';
    mfname1 = spm_select ('List',data_path1,mfilt);
    mfname2 = spm_select ('List',data_path2,mfilt);
    mfname3 = spm_select ('List',data_path3,mfilt);
    
    move1 = fullfile(data_path1,mfname1);
    move2 = fullfile(data_path2,mfname2);
    move3 = fullfile(data_path3,mfname3);
    
    PPI_file1 = [res_path,'/PPI_PPI_rAI_C1_Sh_S-O1.mat'];
    PPI_file2 = [res_path,'/PPI_PPI_rAI_C1_Sh_S-O2.mat'];
    PPI_file3 = [res_path,'/PPI_PPI_rAI_C1_Sh_S-O3.mat'];
    
    
    %%%%%%%run1
    load (PPI_file1);
    jobs{1}.stats{1}.fmri_spec.sess(1).scans=cellstr(Data1_s);
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(1).val  = PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).name = 'lMVis';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(2).val  = PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).name = 'N_inc-c';
    jobs{1}.stats{1}.fmri_spec.sess(1).regress(3).val  = PPI.P;
    
    % 	jobs{1}.stats{1}.fmri_spec=struct('fact',{},'levels',{});
    jobs{1}.stats{1}.fmri_spec.sess(1).multi_reg=cellstr(move1);
    
    %%%%%%run2
    load (PPI_file2);
    jobs{1}.stats{1}.fmri_spec.sess(2).scans=cellstr(Data2_s);
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(1).val  = PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).name = 'lMVis';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(2).val  = PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).name = 'N_inc-c';
    jobs{1}.stats{1}.fmri_spec.sess(2).regress(3).val  = PPI.P;
    
    
    % 	jobs{1}.stats{1}.fmri_spec=struct('fact',{},'levels',{});
    jobs{1}.stats{1}.fmri_spec.sess(2).multi_reg=cellstr(move2);
    
    %%%%%%run3
    load (PPI_file3);
    jobs{1}.stats{1}.fmri_spec.sess(3).scans=cellstr(Data3_s);
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(1).name = 'PPI';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(1).val  = PPI.ppi;
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(2).name = 'lMVis';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(2).val  = PPI.Y;
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(3).name = 'N_inc-c';
    jobs{1}.stats{1}.fmri_spec.sess(3).regress(3).val  = PPI.P;
    %
    
    % 	jobs{1}.stats{1}.fmri_spec=struct('fact',{},'levels',{});
    jobs{1}.stats{1}.fmri_spec.sess(3).multi_reg=cellstr(move3);
    

    jobs{1}.stats{1}.fmri_spec.bases.hrf=struct('derivs',[0 0]); %hrf [1 0]
    jobs{1}.stats{1}.fmri_spec.volt=1;
    jobs{1}.stats{1}.fmri_spec.global='None';
    jobs{1}.stats{1}.fmri_spec.mask={''};
    jobs{1}.stats{1}.fmri_spec.cvi='AR(1)';
    
    
    %_____________________ESTIMATE_____________________
    jobs{1}.stats{2}.fmri_est.spmmat={[res_path,'/','SPM.mat']};
    jobs{1}.stats{2}.fmri_est.method.Classical=1;
    
    spm_jobman('run',jobs)
    display('mission complete!!! congratulation!')
end;