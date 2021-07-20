%% INITIALIZE
% fMRI Data Analysis, Initializing Setting guide. by Bo Shen PKU�� 2017-12-2
% ���ܴŹ������ݷ�����������ʼ���������򲨣�������ѧ�� 2017-12-2
%% setting data path
spmDir = which('spm');
if isempty(spmDir)
    spmDir = uigetdir('*.*','��ѡ��spm12���߰������·��');
    addpath(genpath(spmDir));
end;
if exist('toolboxDir','var')
    toolboxDir = uigetdir('*.*','��ѡ���򲨵Ĺ��߰������·��');
end;
addpath(genpath(toolboxDir));
%% ��ʼ������
%% ��Ϊ����·������
behdir = uigetdir('*.*','��ѡ���š����б�����Ϊ�����ļ����ĸ�Ŀ¼');
behSaveOrder = menu('������Ϊ���ݴ洢��ʽ��', '��session�ġ��ļ��С�����ÿ�����Եġ������ļ���', '��ÿ�����Եġ��ļ��С������һ������session�ġ������ļ���','ÿ������һ���������ļ���������session','���϶�������');
switch  behSaveOrder
    case 1
        d = dir(behdir);
        str = {d.name};
        [s,v] = listdlg('PromptString','��ѡ����Ҫ�����session���ļ���',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('��û��ѡ���κ��ļ���');
        elseif v == 1
            sessnames_beh = {d(s).name};
            nsess_beh = numel(sessnames_beh);
            prompParamters = sprintf('�޸������ַ�����ʹ������������Ϊ���������ص㣺��ͬ�ַ���*.��չ��');
            defaultParameters = {'sub*.txt'};
            Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
            filepattern = Settings{1};
            filelistall = {};
            subjlistprint = [];
            for sessi = 1:nsess_beh
                filelist = foldernames(fullfile(behdir, sessnames_beh{sessi}, filepattern),'single');
                filelistall = [filelistall;filelist];
                if isempty(filelist)
                    error('û���ҵ�ָ���ļ�������������������ص����� �� ָ�����ļ���Ϊ�գ�����������');
                end;
                try
                    filelistmat = cell2mat(filelist);
                catch
                    error('�뱣֤ÿ�����������ļ����ַ�������ͬ���罫sub1,sub2,...,sub38,����Ϊsub101,sub102,...,sub138');
                end;
                nfile(sessi) = numel(filelist);
                subjlistprint = [subjlistprint '\n' sessnames_beh{sessi} '  ' num2str(nfile(sessi)) '���ļ�'];
            end;
            ButtonName = questdlg(sprintf(['Ϊ���ҵ������ļ�������' subjlistprint]), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % ����ʵ����%i������\n
                error('����ֹ�˲�����������Ϊ�����ļ�������');
            end;
            if std(nfile) > 0
                warning('��ͬsession�ı����ļ�������ͬ�����������');
            end;
            [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
%             heading = sprintf(['���ı��������ƺ������¹�ͬ��\n' subjcommoncharacter_beh '��ָ�����Ա����ռ�ַ�λ��\�˴�������ҲӦ�����ҵ���Щ��ͬ�ı��Ա��']);
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
        [s,v] = listdlg('PromptString','��ѡ����Ҫ����ı��Ե��ļ���',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('��û��ѡ���κ��ļ���');
        elseif v == 1
            subjnames_beh = {d(s).name};
            nsubj_beh = numel(subjnames_beh);
            prompParamters = sprintf('�޸������ַ�����ʹ������������Ϊ���������ص㣺��ͬ�ַ���*.��չ��');
            defaultParameters = {'sub*.txt'};
            Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
            filepattern = Settings{1};
            filelistall = {};
            subjlistprint = [];
            for subj = 1:nsubj_beh
                filelist = foldernames(fullfile(behdir, subjnames_beh{subj}, filepattern),'single');
                filelistall = [filelistall;filelist];
                if isempty(filelist)
                    error('û���ҵ�ָ���ļ�������������������ص����� �� ָ�����ļ���Ϊ�գ�����������');
                end;
                try
                    filelistmat = cell2mat(filelist);
                catch
                    error('�뱣֤ÿ�����������ļ����ַ�������ͬ���罫sub1,sub2,...,sub38,����Ϊsub101,sub102,...,sub138');
                end;
                nfile(subj) = numel(filelist);
                subjlistprint = [subjlistprint '\n' subjnames_beh{subj} '  ' num2str(nfile(subj)) '���ļ�'];
            end;
            ButtonName = questdlg(sprintf(['Ϊ���ҵ������ļ�������' subjlistprint]), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % ����ʵ����%i������\n
                error('����ֹ�˲�����������Ϊ�����ļ�������');
            end;
            if std(nfile) > 0
                warning('��ͬ�ı���session�ļ�������ͬ�����������');
            end;
            [sesscommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
            heading = sprintf(['�����ļ������ƺ������¹�ͬ��']);
            prompParamters = {heading};
            defaultParameters = {sesscommoncharacter_beh};
            for sessi = 1: max(nfile)
                if sessi == 1
                    prompParamters{end+1} = sprintf('�������Ӧÿ��session�������ַ�\nsession%i������',sessi);
                else
                    prompParamters{end+1} = sprintf('session%i������',sessi);
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
        [s,v] = listdlg('PromptString','��ѡ����Ҫ����ı��Ե��ļ�',...
            'SelectionMode','multiple',...
            'ListString',str);
        if v == 0
            error('��û��ѡ���κ��ļ���');
        elseif v == 1
            subjnames_beh = {d(s).name};
            nsubj_beh = numel(subjnames_beh);
            try
                filelistmat = cell2mat(subjnames_beh');
            catch
                error('�뱣֤ÿ�����������ļ����ַ�������ͬ���罫sub1,sub2,...,sub38,����Ϊsub101,sub102,...,sub138');
            end;
            nfile = numel(subjnames_beh);
            ButtonName = questdlg(sprintf('Ϊ���ҵ�%i���ļ�������',nfile), ...
                'Confirm Dialog', 'Yes'); 
            if ~strcmp(ButtonName, 'Yes') % ����ʵ����%i������\n
                error('����ֹ�˲�����������Ϊ�����ļ�������');
            end;
            [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(subjnames_beh);
            [d f e] = fileparts(subjcommoncharacter_beh);
            finalpath_beh = fullfile('[[behdir]]',[d '*[[subjID]]*' e]);
        end;
    case 4
        error('��Ǹ��������Ϊ���ݴ�ŷ�ʽ���޷������밴���Ի�session���');
end;
 %% �˴�����·������
imgdir = uigetdir('*.*','��ѡ���š����б��Ժ˴������ļ����ĸ�Ŀ¼');
ButtonName = questdlg(sprintf('���ĺ˴����ݴ洢��ʽ����Ϊ��\n��ÿ�����Եġ��ļ��С������һ������session�ġ������ļ���\n�����뷵���޸�'), ...
                'Confirm Dialog', 'Yes'); 
if ~strcmp(ButtonName, 'Yes') % ����ʵ����%i������\n
    error('����ֹ�˲����������޸� �˴��ļ��洢��ʽ������');
end;
d = dir(imgdir);
str = {d.name};
[s,v] = listdlg('PromptString','��ѡ����Ҫ����ı��Ե��ļ���',...
    'SelectionMode','multiple',...
    'ListString',str);
if v == 0
    error('��û��ѡ���κ��ļ���');
elseif v == 1
    subjnames_img = {d(s).name};
    nsubj_beh = numel(subjnames_beh);
    [subjcommoncharacter_img, uniquelist] = FindCommonCharacters(subjnames_img);
    heading = sprintf(['�����ļ������ƺ������¹�ͬ��']);
    prompParamters = {heading};
    
    prompParamters = sprintf('�޸������ַ�����ʹ������������Ϊ���������ص㣺��ͬ�ַ���*.��չ��');
    defaultParameters = {'sub*.txt'};
    Settings = inputdlg(prompParamters, 'File Format', 1, defaultParameters);
    filepattern = Settings{1};
    filelistall = {};
    subjlistprint = [];
    for subj = 1:nsubj_beh
        filelist = foldernames(fullfile(behdir, subjnames_beh{subj}, filepattern),'single');
        filelistall = [filelistall;filelist];
        if isempty(filelist)
            error('û���ҵ�ָ���ļ�������������������ص����� �� ָ�����ļ���Ϊ�գ�����������');
        end;
        try
            filelistmat = cell2mat(filelist);
        catch
            error('�뱣֤ÿ�����������ļ����ַ�������ͬ���罫sub1,sub2,...,sub38,����Ϊsub101,sub102,...,sub138');
        end;
        nfile(subj) = numel(filelist);
        subjlistprint = [subjlistprint '\n' subjnames_beh{subj} '  ' num2str(nfile(subj)) '���ļ�'];
    end;
    ButtonName = questdlg(sprintf(['Ϊ���ҵ������ļ�������' subjlistprint]), ...
        'Confirm Dialog', 'Yes');
    if ~strcmp(ButtonName, 'Yes') % ����ʵ����%i������\n
        error('����ֹ�˲�����������Ϊ�����ļ�������');
    end;
    if std(nfile) > 0
        warning('��ͬ�ı���session�ļ�������ͬ�����������');
    end;
    [sesscommoncharacter_beh, uniquelist] = FindCommonCharacters(filelistall);
    heading = sprintf(['�����ļ������ƺ������¹�ͬ��']);
    prompParamters = {heading};
    defaultParameters = {sesscommoncharacter_beh};
    for sessi = 1: max(nfile)
        if sessi == 1
            prompParamters{end+1} = sprintf('�������Ӧÿ��session�������ַ�\nsession%i������',sessi);
        else
            prompParamters{end+1} = sprintf('session%i������',sessi);
        end;
        defaultParameters{end+1} = '';
    end;
    Settings = inputdlg(prompParamters, heading, 1, defaultParameters);
    sessnames_beh = Settings(2:end);
    [subjcommoncharacter_beh, uniquelist] = FindCommonCharacters(subjnames_beh);
    [d f e] = fileparts(filepattern);
    finalpath_beh = fullfile('[[behdir]]','*[[subjID]]*',d, ['*[[sessname]]*' e]);
end;

