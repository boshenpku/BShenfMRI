%% library and package path setup
myLibdir = 'E:\ShenBo\MySPM12Library';
addpath(genpath(myLibdir)); % add Shen Bo's Library into path
addpath('C:\Toolbox\spm12'); % add spm12 into path
%% Define data type and directories
ProjectDir = 'E:\ShenBo\GR';
imgdir = fullfile(ProjectDir,'nifti');
cd(imgdir);
SubjFold_img = '2*';
SessFold_img = {'*RUN1*' '*RUN2*' '*RUN3*'};
imghead  = 'aaa*.nii';
folderlist = foldernames(fullfile(imgdir,SubjFold_img),'full');
subjlist = foldernames(fullfile(imgdir,SubjFold_img),'single');

results_file = {};
results_mean = [];
for subj = 1:numel(subjlist)
    fprintf('Processing %s',subjlist{subj});
    for sess = 1:numel(SessFold_img)
        fprintf('...');
        sessdir = foldernames(fullfile(folderlist{subj},SessFold_img{sess}),'full');
        imglist = filenames(fullfile(sessdir{1},imghead));
        for img = 1:numel(imglist)
            FullBrainVols = spm_read_vols(spm_vol(imglist{img}));
            % sizeimg = size(FullBrainVols);
            % FullBrainVols = reshape(FullBrainVols,sizeimg(1) * sizeimg(2) * sizeimg(3),1);
            FullBrainVols = FullBrainVols(FullBrainVols > 3000);
            averSignal = mean(FullBrainVols);
            results_file{end+1} = imglist{img};
            results_mean(end+1) = averSignal;
            if averSignal > 10000
                warning(imglist{img});
            end;
        end;
    end;
    fprintf('Done\n');
end;
save('DataQualityCheckResults.mat','results_file', 'results_mean');