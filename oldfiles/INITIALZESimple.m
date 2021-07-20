%% INITIALIZE
% fMRI Data Analysis, Initializing Setting guide. by Bo Shen PKU， 2017-12-2
% 功能磁共振数据分析，参数初始化导引，沈波，北京大学， 2017-12-2
%% setting data path
spmDir = which('spm');
if isempty(spmDir)
    spmDir = uigetdir('*.*','请选择【spm12工具包】存放路径');
    addpath(genpath(spmDir));
end;
if exist('toolboxDir','var')
    toolboxDir = uigetdir('*.*','请选择【沈波的工具包】存放路径');
end;
addpath(genpath(toolboxDir));
%% 初始化参数
%% 行为数据路径定义
behdir = uigetdir('*.*','请选择存放【所有被试行为数据文件】的根目录');
behSaveOrder = menu('您的行为数据存储方式？', '先session的【文件夹】，后每个被试的【数据文件】', '先每个被试的【文件夹】，后分一个或多个session的【数据文件】','每个被试一个【数据文件】，不分session','以上都不符合');
switch  behSaveOrder
    case 1
        d = dir(behdir);
        str = {d.name};
        [s,v] = listdlg('PromptString','请选择需要处理的session的文件夹',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('你没有选择任何文件夹');
        elseif v == 1
            sessnames_beh = {d(s).name};
            nsess_beh = numel(sessnames_beh);
            prompParamters = sprintf('修改以下字符串，使它符合您的行为数据命名特点：共同字符串*.扩展名');
            defaultParameters = {'sub*.txt'};
            Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
            filepattern = Settings{1};
            filelistall = {};
            subjlistprint = [];
            for sessi = 1:nsess_beh
                filelist = foldernames(fullfile(behdir, sessnames_beh{sessi}, filepattern),'single');
                filelistall = [filelistall;filelist];
                if isempty(filelist)
                    error('没有找到指定文件，您输入的数据命名特点有误 或 指定的文件夹为空，请重新运行');
                end;
                try
                    filelistmat = cell2mat(filelist);
                catch
                    error('请保证每个被试数据文件的字符长度相同，如将sub1,sub2,...,sub38,命名为sub101,sub102,...,sub138');
                end;
                nfile(sessi) = numel(filelist);
                subjlistprint = [subjlistprint '\n' sessnames_beh{sessi} '  ' num2str(nfile(sessi)) '个文件'];
            end;
            ButtonName = questdlg(sprintf(['为您找到以下文件，请检查' subjlistprint]), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % 您的实验有%i个被试\n
                error('您终止了操作，请检查行为数据文件后重试');
            end;
            if std(nfile) > 0
                warning('不同session的被试文件数量不同，请谨慎处理');
            end;
            [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
%             heading = sprintf(['您的被试命名似乎有以下共同点\n' subjcommoncharacter_beh '请指出被试编号所占字符位置\核磁数据中也应当能找到这些相同的被试编号']);
%             prompParamters = {heading};
%             defaultParameters = {'4:6'};
%             Settings = inputdlg(prompParamters, heading, 1, defaultParameters);
%             IDloc_beh = Settings{1};
%             IDloc_beh = [str2double(IDloc_beh(1)) str2double(IDloc_beh(3))];
            [d f e] = fileparts(filepattern);
            finalpath_beh = fullfile('[[behdir]]','[[sessname]]',d, ['*[[subjID]]*' e]);
        end;
    case 2
        d = dir(behdir);
        str = {d.name};
        [s,v] = listdlg('PromptString','请选择需要处理的被试的文件夹',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('你没有选择任何文件夹');
        elseif v == 1
            subjnames_beh = {d(s).name};
            nsubj_beh = numel(subjnames_beh);
            prompParamters = sprintf('修改以下字符串，使它符合您的行为数据命名特点：共同字符串*.扩展名');
            defaultParameters = {'sub*.txt'};
            Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
            filepattern = Settings{1};
            filelistall = {};
            subjlistprint = [];
            for subj = 1:nsubj_beh
                filelist = foldernames(fullfile(behdir, subjnames_beh{subj}, filepattern),'single');
                filelistall = [filelistall;filelist];
                if isempty(filelist)
                    error('没有找到指定文件，您输入的数据命名特点有误 或 指定的文件夹为空，请重新运行');
                end;
                try
                    filelistmat = cell2mat(filelist);
                catch
                    error('请保证每个被试数据文件的字符长度相同，如将sub1,sub2,...,sub38,命名为sub101,sub102,...,sub138');
                end;
                nfile(subj) = numel(filelist);
                subjlistprint = [subjlistprint '\n' subjnames_beh{subj} '  ' num2str(nfile(subj)) '个文件'];
            end;
            ButtonName = questdlg(sprintf(['为您找到以下文件，请检查' subjlistprint]), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % 您的实验有%i个被试\n
                error('您终止了操作，请检查行为数据文件后重试');
            end;
            if std(nfile) > 0
                warning('不同的被试session文件数量不同，请谨慎处理');
            end;
            [sesscommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
            heading = sprintf(['您的文件命名似乎有以下共同点']);
            prompParamters = {heading};
            defaultParameters = {sesscommoncharacter_beh};
            for sessi = 1: max(nfile)
                if sessi == 1
                    prompParamters{end+1} = sprintf('请给出对应每个session命名的字符\nsession%i的命名',sessi);
                else
                    prompParamters{end+1} = sprintf('session%i的命名',sessi);
                end;
                defaultParameters{end+1} = '';
            end;
            Settings = inputdlg(prompParamters, heading, 1, defaultParameters);
            sessnames_beh = Settings(2:end);
            [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(subjnames_beh);
            [d f e] = fileparts(filepattern);
            finalpath_beh = fullfile('[[behdir]]','*[[subjID]]*',d, ['*[[sessname]]*' e]);
        end;
    case 3
        nsess = 1;
        d = dir(behdir);
        str = {d.name};
        [s,v] = listdlg('PromptString','请选择需要处理的被试的文件',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('你没有选择任何文件夹');
        elseif v == 1
            subjnames_beh = {d(s).name};
            nsubj_beh = numel(subjnames_beh);
            try
                filelistmat = cell2mat(subjnames_beh');
            catch
                error('请保证每个被试数据文件的字符长度相同，如将sub1,sub2,...,sub38,命名为sub101,sub102,...,sub138');
            end;
            nfile = numel(subjnames_beh);
            ButtonName = questdlg(sprintf('为您找到%i个文件，请检查',nfile), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % 您的实验有%i个被试\n
                error('您终止了操作，请检查行为数据文件后重试');
            end;
            [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(subjnames_beh);
            [d f e] = fileparts(subjcommoncharacter_beh);
            finalpath_beh = fullfile('[[behdir]]',[d '*[[subjID]]*' e]);
        end;
    case 4
        error('抱歉，您的行为数据存放方式我无法处理，请按被试或按session存放');
end;
 %% 核磁数据路径定义
imgdir = uigetdir('*.*','请选择存放【所有被试核磁数据文件】的根目录');
ButtonName = questdlg(sprintf('您的核磁数据存储方式必须为：\n先每个被试的【文件夹】，后分一个或多个session的【数据文件】\n否则请返回修改'), ...
                'Confirm Dialog', 'Yes'); 
if ~strcmp(ButtonName, 'Yes') % 您的实验有%i个被试\n
    error('您终止了操作，返回修改 核磁文件存储方式后重试');
end;
d = dir(imgdir);
str = {d.name};
[s,v] = listdlg('PromptString','请选择需要处理的被试的文件夹',...
    'SelectionMode','multiple',...
    'ListString',str);
if v == 0
    error('您没有选择任何文件夹');
elseif v == 1
    subjnames_img = {d(s).name};
    nsubj_beh = numel(subjnames_beh);
    [subjcommoncharacter_img, uniquelist] = FindCommonCharacters(subjnames_img);
    heading = sprintf(['您的文件命名似乎有以下共同点']);
    prompParamters = {heading};
    
    prompParamters = sprintf('修改以下字符串，使它符合您的行为数据命名特点：共同字符串*.扩展名');
    defaultParameters = {'sub*.txt'};
    Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
    filepattern = Settings{1};
    filelistall = {};
    subjlistprint = [];
    for subj = 1:nsubj_beh
        filelist = foldernames(fullfile(behdir, subjnames_beh{subj}, filepattern),'single');
        filelistall = [filelistall;filelist];
        if isempty(filelist)
            error('没有找到指定文件，您输入的数据命名特点有误 或 指定的文件夹为空，请重新运行');
        end;
        try
            filelistmat = cell2mat(filelist);
        catch
            error('请保证每个被试数据文件的字符长度相同，如将sub1,sub2,...,sub38,命名为sub101,sub102,...,sub138');
        end;
        nfile(subj) = numel(filelist);
        subjlistprint = [subjlistprint '\n' subjnames_beh{subj} '  ' num2str(nfile(subj)) '个文件'];
    end;
    ButtonName = questdlg(sprintf(['为您找到以下文件，请检查' subjlistprint]), ...
        'Confirm Dialog', 'Yes');
    if ~strcmp(ButtonName, 'Yes') % 您的实验有%i个被试\n
        error('您终止了操作，请检查行为数据文件后重试');
    end;
    if std(nfile) > 0
        warning('不同的被试session文件数量不同，请谨慎处理');
    end;
    [sesscommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
    heading = sprintf(['您的文件命名似乎有以下共同点']);
    prompParamters = {heading};
    defaultParameters = {sesscommoncharacter_beh};
    for sessi = 1: max(nfile)
        if sessi == 1
            prompParamters{end+1} = sprintf('请给出对应每个session命名的字符\nsession%i的命名',sessi);
        else
            prompParamters{end+1} = sprintf('session%i的命名',sessi);
        end;
        defaultParameters{end+1} = '';
    end;
    Settings = inputdlg(prompParamters, heading, 1, defaultParameters);
    sessnames_beh = Settings(2:end);
    [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(subjnames_beh);
    [d f e] = fileparts(filepattern);
    finalpath_beh = fullfile('[[behdir]]','*[[subjID]]*',d, ['*[[sessname]]*' e]);
end;

