clear;clc;
ROIs={
    'E:\ShenBo\GR\Model\SecondLevel\OneSamplet-test\gsw-gow\BinaryMask_guiltdACC.nii'
    'E:\ShenBo\GR\Model\SecondLevel\OneSamplet-test\gsw-gow\BinaryMask_guiltlAI.nii'
    'E:\ShenBo\GR\Model\SecondLevel\OneSamplet-test\gsw-gow\BinaryMask_guiltrAI.nii'
    'E:\ShenBo\GR\Model\SecondLevel\OneSamplet-test\gsw-gow\BinaryMask_guiltrIFG.nii'
    };
ROIname={'dACC' 'lAI' 'rAI' 'rIFG'};
for i=1:length(ROIs)
    V = spm_vol(ROIs{i});
    [ROI xyz] = spm_read_vols(V);
    ROI_all{i}=ROI;
end
%%
img_dir = 'E:\ShenBo\GR\nifti';
onset_dir = 'E:\ShenBo\GR\Model\onset';
dirfold = dir(fullfile(img_dir,'2*'));
subjlist = {};
subid = [];

for i = 1:length(dirfold)
    subjlist{i} = dirfold(i).name;
    subid(i) = str2num(subjlist{i}(1:3));
end;
blacklist = [1 11 14 19 47 55];
subjlist(blacklist) = [];
subid(blacklist) = [];
num2str(subid')
numsub = length(subjlist)

%%
FirstLevel_dir = 'E:\ShenBo\GR\Model\FirstLevel';
secondleveldir = 'E:\ShenBo\GR\Model\SecondLevel';
outputdir = 'TimeCourse';
%%
for subj=1:length(subjlist)
    subjlist(subj)
    clear tCourse
    FirstLevel_path = fullfile(FirstLevel_dir,subjlist{subj});
    load(fullfile(FirstLevel_path,'SPM.mat'));
    
    %% generate time series signal in ROI for each session
    scans = 0;
    for run = 1:3 % loop for session
        for i=1:SPM.nscan(run) % loop for scan in a session
            V = spm_vol(SPM.xY.P(i+scans,1:end)); % prepare for spm_read_vols
            [M xyz] = spm_read_vols(V); % read value on each voxel in this volume
            for j=1:length(ROIs) % loop for ROI
                Mmask=M.*ROI_all{j}; % apply ROI mask on the volume
                Mmask(isnan(Mmask))=0;
                tCourse{j}(i,run)=mean(Mmask(Mmask~=0)); % record in TimeCourse
            end;
        end;
        scans = scans + SPM.nscan(run);
    end;
    
    %% extract time course at each onset point
    start = -5; % TR
    ending = 10; % TR
    TR = 2;
    % load onsets
    load(fullfile(onset_dir,[num2str(subid(subj)) 'onset.mat']));
    for jj=1:length(ROIs)
        samp=10;% number of intrapolation
        for run = 1:3
            for agent = {'sw' 'ow'}
                for context = {'gc1' 'gc2' 'gc3'}
                    % Interpolate the timecourse
                    x = 1:1:sum(tCourse{jj}(:,run)>0);
                    x1 = 1:1/samp:sum(tCourse{jj}(:,run)>0);
                    temp = interp1(x,tCourse{jj}(x,run),x1);
                    eval(['onsetpoint = onset(run).' context{1} agent{1} '/TR;']);
                    % extract signal,  size of extracted mat = onsetpoint * 1 * time points
                    eval(['RUN' num2str(run) context{1} agent{1} '= waveform_extract_pp(onsetpoint,temp,[start ending],samp);']);  
                end;
            end;
        end;
        % mean for runs
        for agent = {'sw' 'ow'}
            for context = {'gc1' 'gc2' 'gc3'}
                eval([context{1} agent{1} '(:,jj)' '= (mean(' 'RUN1' context{1} agent{1} ',1)+mean(' 'RUN2' context{1} agent{1} ',1)+mean(' 'RUN3' context{1} agent{1} ',1))/3;']);
                eval([context{1} agent{1} '(:,jj)' '= (mean(' 'RUN1' context{1} agent{1} ',1)+mean(' 'RUN2' context{1} agent{1} ',1)+mean(' 'RUN3' context{1} agent{1} ',1))/3;']);
            end;
        end;  
    end;
    tCoursedir = fullfile(FirstLevel_path,outputdir);
    if ~exist('tCoursedir','dir')
        mkdir(tCoursedir);
    end;
    save(fullfile(tCoursedir,'tCourse'),'gc1sw','gc2sw','gc3sw','gc1ow','gc2ow','gc3ow');
    % combine subject
    for agent = {'sw' 'ow'}
        for context = {'gc1' 'gc2' 'gc3'}
            eval(['tCourseAll{subj}.' context{1} agent{1} '=' context{1} agent{1} ';']);
        end;
    end;
end;
tCoursedir = fullfile(secondleveldir,outputdir);
if ~exist('tCoursedir','dir')
    mkdir(tCoursedir);
end;
save(fullfile(tCoursedir,'tCourseAll'),'tCourseAll');

%% plot
linelist = {'r-' 'g-' 'b-' 'r--' 'g--' 'b--' };
for i=1:length(ROIs)
    H = figure;hold on;title(ROIname{i});
    l = 0;
    for agent = {'sw' 'ow'}
        for context = {'gc1' 'gc2' 'gc3'}
            temp = [];
            for subj = 1:length(subjlist)
                eval(['temp = [temp tCourseAll{subj}.' context{1} agent{1} '(:,i)];']);
            end;
            l = l + 1;
            plot([start:1/samp:ending], mean(temp,2),linelist{l},'linewidth',2);
        end;
    end;
    legend('gc1sw','gc2sw', 'gc3sw','gc1ow','gc2ow','gc3ow','Location','SouthWest');
    saveas(H,fullfile(tCoursedir,sprintf('%s.eps',ROIname{i})),'eps');
    saveas(H,fullfile(tCoursedir,sprintf('%s.bmp',ROIname{i})),'bmp');
    close all;
end;