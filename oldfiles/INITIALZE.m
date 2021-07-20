%% INITIALIZE
% fMRI Data Analysis, Initializing Setting guide. by Bo Shen PKU， 2017-12-2
% 功能磁共振数据分析，参数初始化导引，沈波，北京大学， 2017-12-2
%% setting language 设置语言
if ~exist('Language', 'var')
    Language = menu('Please Choose Language 请选择语言', '中文简体');
end;
%% setting data path
spmDir = which('spm');
if isempty(spmDir)
    spmDir = uigetdir('*.*','请选择【spm12工具包】存放路径');
    addpath(genpath(spmDir));
end;
toolboxDir = uigetdir('*.*','请选择【沈波的工具包】存放路径');
addpath(genpath(toolboxDir));
behdir = uigetdir('*.*','请选择【所有被试】【行为数据文件】存放路径');
d = dir(behdir);
str = {d.name};
[s,v] = listdlg('PromptString','哪些是你有用行为数据文件？',...
    'SelectionMode','multiple',...
    'ListString',str);
if v == 0
    warning('你没有选择有效的行为数据文件夹');
elseif v == 1
    tmpfolder = {d(s).name};
    behSaveOrder = menu('以上所选文件（夹）是？', '实验session的【文件夹】，内包含每个被试的文件', '每个被试的【文件夹】，内包含一个或多个session文件','每个被试的【数据文件】，不分session','其他');
    switch  behSaveOrder
        case 1
            sessnames_beh = tmpfolder;
            nsess = numel(sessnames_beh);
            sesslistprint = [];
            for sessi = 1:nsess
                sesslistprint = [sesslistprint '\n' sessnames_beh{sessi}];
            end;
            ButtonName = questdlg(sprintf(['您的实验有%i个session:\n' sesslistprint], nsess), ...
                         'Confirm Dialog', 'Yes');
                     
        case 2
            behsubjlist = tmpfolder;
            nsubj_beh =  numel(behsubjlist);
            subjnames_beh = behsubjlist;
            subjlistprint = [];
            for subj = 1:nsubj_beh
                subjlistprint = [subjlistprint '\n' subjnames_beh{subj}];
            end;
            ButtonName = questdlg(sprintf(['您的实验有%i个被试\n' subjlistprint],nsubj_beh), ...
                'Confirm Dialog', 'Yes');
            if strcmp(ButtonName, 'Yes')
                [filename, pathname] = uigetfile(fullfile(behdir,'*.*'),sprintf('请选择一名【没有缺失任何一个session数据】的被试的【所有session】的【行为数据文件】'),'MultiSelect', 'on');
                nsess_beh = numel(filename);
                [~,~,fileformat] = fileparts(filename{1});
                for sessi = 1:nsess_beh
                    [~,~,e] = fileparts(filename{i});
                    if ~strcmp(fileformat,e)
                        error('行为数据文件后缀名冲突：有%s 也有%s，请统一之后重新运行此程序',fileformat,e);
                    end;
                end;
                stringOut = strrep(pathname, behdir, '[[behdir]]');
                i = 0;
                finalpath_beh = stringOut;
                while strcmp(stringOut,finalpath_beh)
                    i = i + 1;
                    finalpath_beh = strrep(stringOut, behsubjlist{i},'[[subjname]]');
                end;
                filelist = {};
                for subj = 1:nsubj_beh
                    subjname = subjnames_beh{subj};
                    [searchpath, rep] = replaceWildcards(finalpath_beh,'[[behdir]]',behdir,'[[subjname]]',subjname);
                    filelist = [filelist; foldernames(fullfile(searchpath, ['*' fileformat]),'single')];
                end;
                [commoncharacter, uniquelist] = FindCommonCharacters(filelist);
                if ~isempty(commoncharacter)
                    ButtonName = questdlg(sprintf('遍历所有被试文件夹，共找到%s的文件%i个',commoncharacter,numel(filelist)), ...
                'Confirm Dialog', 'Yes');
                    if strcmp(ButtonName, 'No')
                        error('您终止了操作，请检查被试行为数据文件夹,之后重新运行此程序');
                    elseif strcmp(ButtonName, 'Cancel')
                        error('您终止了操作');
                    end;
                else
                    error('文件没有相同字符：遍历所有被试文件夹,共找到文件%i个，但这些文件没有共同点，可能是你存放了其他无关文件在文件夹中，请核对后重跑该程序',numel(filelist));
                end;
                for i = 1:size(uniquelist,2)
                    if length(unique(uniquelist(:,i))) == nsess_beh
                        break;
                    end;
                end;
                if length(unique(uniquelist(:,i))) ~= nsess_beh
                    error('您的行为数据文件命名可能欠妥，找不到一个随session变化的字符');
                end;
                tmp = find(commoncharacter == '*');
                if i == 1
                    sess_common_chara = commoncharacter(1:tmp(i)-1);
                else
                    sess_common_chara = commoncharacter(tmp(i-1)+1:tmp(i)-1);
                end;
                sess_indicators = unique(uniquelist(:,i));
                for sessi = 1:nsess_beh % sess_indicator
                    sess_indicator = sess_indicators(sessi);
                    prompParamters{sessi} = sprintf('确认或修改能代表session%i的字符串', sessi);
                    defaultParameters{sessi} = sprintf('%s%s', sess_common_chara,sess_indicator);
                end;
                sessnames_beh = inputdlg(prompParamters, 'Session Naming', 1, defaultParameters);
                if nsess > 1
                    [sess_common_chara uniquelist] = FindCommonCharacters(sessnames_beh);
                    finalpath_beh = fullfile(finalpath_beh, strrep(commoncharacter,sess_common_chara,'[[sessname]]'));
                elseif nsess == 1
                    finalpath_beh = fullfile(finalpath_beh, commoncharacter);
                end;
                ButtonName = CheckData(finalpath_beh,subjnames_beh,sessnames_beh);
                if strcmp(ButtonName, 'No') % 最终确认行为数据列表
                   error('如有不对，请检查后重新运行此程序'); 
                elseif strcmp(ButtonName, 'Cancel') % 最终确认行为数据列表
                   error('您终止了操作');
                end;
            elseif strcmp(ButtonName, 'No') % 您的实验有%i个被试\n
                error('请重新选择被试行为数据文件夹,之后重新运行此程序');
            elseif strcmp(ButtonName, 'Cancel') % 您的实验有%i个被试\n
                error('您终止了操作');
            end;
                     
        case 3
            behsubjlist = tmpfolder;
            nsubj_beh =  numel(behsubjlist);
            ButtonName = questdlg(sprintf('你共选中了%i个被试。你的实验不分session？',nsubj_beh), ...
                         'Confirm Dialog', 'Yes');
            if strcmp(ButtonName, 'Yes')
                nsess = 1;
                for i = 1:nsubj_beh
                    behfilelist{i} = fullfile(behdir,behsubjlist{i});
                    [d,subjnames_beh{i},e] = fileparts(tmpfolder{i});
                end;
            elseif strcmp(ButtonName, 'No')
                error('请将实验不同session的数据分文件夹储存,之后重新运行此程序');
            elseif strcmp(ButtonName, 'Cancel')
                error('您终止了操作');
            end;
        case 4
            error('抱歉，您的行为数据存放方式我无法处理，请按被试或按session存放');
    end;
            
end;


imgdir = uigetdir('*.*','请选择【dicom转换后】【所有被试】【脑成像nifti文件（.nii或.img+.hdr)】存放路径');


%%
LibraryDir = fullfile(ProjectDir,'batch');

Language = '中文简体'; % English
prompParamters = {};
defaultParameters = {Language};
Settings = inputdlg(prompParamters, 'Data Path', 2, defaultParameters);
Language = Settings{1};

prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
   name='Input for Peaks function';
   numlines=1;
   defaultanswer={'20','hsv'};
 
   answer=inputdlg(prompt,name,numlines,defaultanswer);
 
   options.Resize='on';
   options.WindowStyle='normal';
   options.Interpreter='tex';
 
   answer=inputdlg(prompt,name,numlines,defaultanswer,options);
 
 