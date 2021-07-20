%% make required directories
if ~exist(resultdir,'dir')
    mkdir(resultdir);
end;
if ~exist(headmovedir,'dir')
    mkdir(headmovedir);
end;
if ~exist(normcheckdir,'dir')
    mkdir(normcheckdir);
end;
if ~exist(onsetOutdir,'dir')
    mkdir(onsetOutdir);
end;
if ~exist(firstleveldir,'dir')
    mkdir(firstleveldir);
end;
if ~exist(secondleveldir,'dir')
    mkdir(secondleveldir);
end;
if ~exist(paramsdir,'dir')
    mkdir(paramsdir);
end;
save(fullfile(paramsdir,'initial_params.mat'));

%% check the definitions
for i = 1:numel(subid_list)
    for j = 1:numel(subid_list)
        if i ~= j
            if strcmp(subid_list{i},subid_list{j})
                error('subid_list contains two identical subid %s', subid_list{i});
            end;
        end;
    end;
end;
if numel(session_list_beh) ~= numel(session_list_beh)
    error('behavioral session list length is different from img session list length');
else
    nsess = numel(session_list_img);
end;
nsubj = numel(subid_list);
%% read and compare files
if exist(fullfile(paramsdir,'filepool.mat'),'file')
    load(fullfile(paramsdir,'filepool.mat'));
else
    filepool = [];
    for subj = 1:nsubj
        subid = subid_list{subj};
        filepool(subj).subid = subid;
        nbehfile = zeros(1,nsess);
        nimgfile = zeros(1,nsess);
        behfile = {};
        imgfile = {};
        for sessi = 1:nsess
            behfilepattern = replaceWildcards(path_beh,'[[behdir]]',behdir,'[[session]]',session_list_beh{sessi},'[[subid]]',subid);
            nbehfile(sessi) = numel(dir(behfilepattern));
            if nbehfile(sessi) == 1
                behfile(sessi) = myfnames(behfilepattern);
            elseif nbehfile(sessi) == 0
                warning('%s not exist',behfilepattern);
            elseif nbehfile(sessi) > 1
                error('%s More than two files match', behfilepattern);
            end;
            
            imgfilepattern = replaceWildcards(path_img,'[[imgdir]]',imgdir,'[[session]]',session_list_img{sessi},'[[subid]]',subid);
            nimgfile(sessi) = numel(dir(imgfilepattern));
            if nimgfile(sessi) > 0
                listforcehck = myfnames(imgfilepattern);
                try
                    cell2mat(listforcehck);
                    imgfile{sessi} = myfnames(imgfilepattern);
                    fprintf('%s: checking files\n',imgfilepattern);
                catch
                    warning('%s: length of filenames different within a session, have already been preprocessed?',imgfilepattern);
                    flen = [];
                    for f = 1:numel(listforcehck)
                        flen(f) = numel(listforcehck{f});
                    end;
                    imgfile{sessi} = listforcehck(flen == min(flen));
                    nimgfile(sessi) = numel(imgfile{sessi});
                end;
            elseif nimgfile(sessi) == 0
                warning('%s not exist',imgfilepattern);
            end;
        end;
        filepool(subj).nbehfile = nbehfile;
        filepool(subj).nimgfile = nimgfile;
        filepool(subj).behfile = behfile;
        filepool(subj).imgfile = imgfile;
    end;
    save(fullfile(paramsdir,'filepool.mat'),'filepool');
end;
open filepool;
