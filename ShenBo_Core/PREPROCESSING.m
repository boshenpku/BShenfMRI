function imgheadarwz = PREPROCESSING(filepoolindv,NSlice,TR,SliceOrder,refSlice,headmovedir,VoxSize,normcheckdir)
imghead = [];
%% Slice timing
imgheada = SLICETIME(filepoolindv,NSlice,TR,SliceOrder,refSlice,imghead);
%% Relignment
imgheadar = REALIGN(filepoolindv,imgheada,headmovedir);
%% Normalization
imgheadarw = NORMALIZE(filepoolindv,imgheadar,VoxSize);
%% Normalization Check
subid = filepoolindv.subid;
filelist = filepoolindv.imgfile;
if ~exist(fullfile(normcheckdir,sprintf('subj%sNormaliseChked.mat',subid)),'file')
    %% check to do task
    todolist = {};
    if ischar(filelist{numel(filelist)})
        todolist = filelist{1};
    elseif iscell(filelist{numel(filelist)})
        for sessi = 1:numel(filelist)
            [d f e] = fileparts(filelist{sessi}{1});
            todolist = [todolist; myfnames(fullfile(d,[imgheadarw f e]))];
        end;
    end;
    %% to do
    crtdir = pwd;
    cd(normcheckdir);
    NormaliseChk(todolist);
    save(sprintf('subj%sNormaliseChked.mat',subid),'todolist');
    cd(crtdir);
end;
%% Smooth
imgheadarwz = SMOOTH(filepoolindv,imgheadarw);
