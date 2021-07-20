%% INITIALIZE
% fMRI Data Analysis, Initializing Setting guide. by Bo Shen PKU�� 2017-12-2
% ���ܴŹ������ݷ�����������ʼ���������򲨣�������ѧ�� 2017-12-2
%% setting language ��������
if ~exist('Language', 'var')
    Language = menu('Please Choose Language ��ѡ������', '���ļ���');
end;
%% setting data path
spmDir = which('spm');
if isempty(spmDir)
    spmDir = uigetdir('*.*','��ѡ��spm12���߰������·��');
    addpath(genpath(spmDir));
end;
toolboxDir = uigetdir('*.*','��ѡ���򲨵Ĺ��߰������·��');
addpath(genpath(toolboxDir));
behdir = uigetdir('*.*','��ѡ�����б��ԡ�����Ϊ�����ļ������·��');
d = dir(behdir);
str = {d.name};
[s,v] = listdlg('PromptString','��Щ����������Ϊ�����ļ���',...
    'SelectionMode','multiple',...
    'ListString',str);
if v == 0
    warning('��û��ѡ����Ч����Ϊ�����ļ���');
elseif v == 1
    tmpfolder = {d(s).name};
    behSaveOrder = menu('������ѡ�ļ����У��ǣ�', 'ʵ��session�ġ��ļ��С����ڰ���ÿ�����Ե��ļ�', 'ÿ�����Եġ��ļ��С����ڰ���һ������session�ļ�','ÿ�����Եġ������ļ���������session','����');
    switch  behSaveOrder
        case 1
            sessnames_beh = tmpfolder;
            nsess = numel(sessnames_beh);
            sesslistprint = [];
            for sessi = 1:nsess
                sesslistprint = [sesslistprint '\n' sessnames_beh{sessi}];
            end;
            ButtonName = questdlg(sprintf(['����ʵ����%i��session:\n' sesslistprint], nsess), ...
                         'Confirm Dialog', 'Yes');
                     
        case 2
            behsubjlist = tmpfolder;
            nsubj_beh =  numel(behsubjlist);
            subjnames_beh = behsubjlist;
            subjlistprint = [];
            for subj = 1:nsubj_beh
                subjlistprint = [subjlistprint '\n' subjnames_beh{subj}];
            end;
            ButtonName = questdlg(sprintf(['����ʵ����%i������\n' subjlistprint],nsubj_beh), ...
                'Confirm Dialog', 'Yes');
            if strcmp(ButtonName, 'Yes')
                [filename, pathname] = uigetfile(fullfile(behdir,'*.*'),sprintf('��ѡ��һ����û��ȱʧ�κ�һ��session���ݡ��ı��Եġ�����session���ġ���Ϊ�����ļ���'),'MultiSelect', 'on');
                nsess_beh = numel(filename);
                [~,~,fileformat] = fileparts(filename{1});
                for sessi = 1:nsess_beh
                    [~,~,e] = fileparts(filename{i});
                    if ~strcmp(fileformat,e)
                        error('��Ϊ�����ļ���׺����ͻ����%s Ҳ��%s����ͳһ֮���������д˳���',fileformat,e);
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
                    ButtonName = questdlg(sprintf('�������б����ļ��У����ҵ�%s���ļ�%i��',commoncharacter,numel(filelist)), ...
                'Confirm Dialog', 'Yes');
                    if strcmp(ButtonName, 'No')
                        error('����ֹ�˲��������鱻����Ϊ�����ļ���,֮���������д˳���');
                    elseif strcmp(ButtonName, 'Cancel')
                        error('����ֹ�˲���');
                    end;
                else
                    error('�ļ�û����ͬ�ַ����������б����ļ���,���ҵ��ļ�%i��������Щ�ļ�û�й�ͬ�㣬�����������������޹��ļ����ļ����У���˶Ժ����ܸó���',numel(filelist));
                end;
                for i = 1:size(uniquelist,2)
                    if length(unique(uniquelist(:,i))) == nsess_beh
                        break;
                    end;
                end;
                if length(unique(uniquelist(:,i))) ~= nsess_beh
                    error('������Ϊ�����ļ���������Ƿ�ף��Ҳ���һ����session�仯���ַ�');
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
                    prompParamters{sessi} = sprintf('ȷ�ϻ��޸��ܴ���session%i���ַ���', sessi);
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
                if strcmp(ButtonName, 'No') % ����ȷ����Ϊ�����б�
                   error('���в��ԣ�������������д˳���'); 
                elseif strcmp(ButtonName, 'Cancel') % ����ȷ����Ϊ�����б�
                   error('����ֹ�˲���');
                end;
            elseif strcmp(ButtonName, 'No') % ����ʵ����%i������\n
                error('������ѡ������Ϊ�����ļ���,֮���������д˳���');
            elseif strcmp(ButtonName, 'Cancel') % ����ʵ����%i������\n
                error('����ֹ�˲���');
            end;
                     
        case 3
            behsubjlist = tmpfolder;
            nsubj_beh =  numel(behsubjlist);
            ButtonName = questdlg(sprintf('�㹲ѡ����%i�����ԡ����ʵ�鲻��session��',nsubj_beh), ...
                         'Confirm Dialog', 'Yes');
            if strcmp(ButtonName, 'Yes')
                nsess = 1;
                for i = 1:nsubj_beh
                    behfilelist{i} = fullfile(behdir,behsubjlist{i});
                    [d,subjnames_beh{i},e] = fileparts(tmpfolder{i});
                end;
            elseif strcmp(ButtonName, 'No')
                error('�뽫ʵ�鲻ͬsession�����ݷ��ļ��д���,֮���������д˳���');
            elseif strcmp(ButtonName, 'Cancel')
                error('����ֹ�˲���');
            end;
        case 4
            error('��Ǹ��������Ϊ���ݴ�ŷ�ʽ���޷������밴���Ի�session���');
    end;
            
end;


imgdir = uigetdir('*.*','��ѡ��dicomת���󡿡����б��ԡ����Գ���nifti�ļ���.nii��.img+.hdr)�����·��');


%%
LibraryDir = fullfile(ProjectDir,'batch');

Language = '���ļ���'; % English
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
 
 