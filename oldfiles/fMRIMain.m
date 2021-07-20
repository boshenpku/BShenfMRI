%% clear workspace
clear all;
% close all;
clc;
 
%% ��������߰�·��
batchdir = 'E:\ShenBo\GR\batchforSpm12'; % ��Ľű����·��
addpath(batchdir); % ����Ľű����·������·������
toolboxDir = 'E:\ShenBo\MySPM12Library'; % �򲨵Ĺ��߰�·��
addpath(genpath(toolboxDir)); % ���򲨵Ĺ��߰�·������·������
if isempty(which('spm')) % ���spm�Ƿ��Ѽ���
    spmDir = uigetdir('*.*','��ѡ��spm12���߰������·��');
    addpath(genpath(spmDir));
end;
  
% ������Ϊ�ͳ����ļ�·��
subid_list = {'202','203','204','205','206','207','208','209','210','212',... % 
    '213','215','216','217','218','220','221','222','223','224','225','226',...
    '227','228','229','230','231','232','233','234','235','236','237','238',...
    '239','240','241','242','243','244','245','246','248','249','250','251',...
    '252','253','254','256','257','258','259','260','261','262'};% ��Ҫ�����
% ���Ա���б���Ϊ���ݺͺ˴����������ж���Ҫ���ҵ���Щ��ţ��������޸�����ļ���
behdir = 'E:\ShenBo\GR\behvdata'; % ������б�����Ϊ�����ļ���·��
session_list_beh = {'run1' 'run2' 'run3'}; % ��Ϊ����session�б�
path_beh = '[[behdir]]\[[session]]\log\*[[subid]]*.log'; % ��ȡ��Ϊ�ļ���·����ʽ��[[]]�е����ݽ����滻Ϊ��ʵ������
imgdir = 'E:\ShenBo\GR\niftispm12'; % dicomת����˴����ݣ�nii��img+hdr�ļ������ڸ�Ŀ¼
session_list_img = {'RUN1' 'RUN2' 'RUN3'}; % �˴�����session�б�
path_img = '[[imgdir]]\*[[subid]]*\*[[session]]*\*.nii'; % ��ȡ�˴����ݵ�·����ʽ��[[]]�е����ݽ����滻Ϊ��ʵ������
resultdir = 'E:\ShenBo\GR\Results\Univariate'; % ��������Ŀ¼
 
% �˴�ɨ����� Scanning Parameters
NSlice = 40; % number of slices in a volume
SliceOrder = [1:2:NSlice 2:2:NSlice];
refSlice = 39; % reference slice
TR = 2.0;
VoxSize = [3 3 3]; % voxel size

% ����һ�㲻���޸�
headmovedir = fullfile(resultdir,'headmove'); % Ԥ����ͷ���ļ��洢·��
normcheckdir = fullfile(resultdir,'NormCheckSimple'); % Ԥ�����׼������ļ��洢·��
onsetOutdir = fullfile(resultdir,'onsetUnivariate'); % ��Ϊonset��ȡ��洢���ļ���
firstleveldir = fullfile(resultdir,'FirstLevel'); % first level����洢·��
secondleveldir = fullfile(resultdir,'SecondLevel'); % second level����洢·��
paramsdir = fullfile(resultdir,'Parameters');

% �����ļ�����
PRECHECK; % proceeding sublist for behavior and imaging data

%% Extract Onset
% Define time parameters in the logfiles
dummy_onset = 'dummy_onset'; % trigger/dummy onset name in logfile
gap = 10; % second, duration from 's' trigger onset to imaging recording onset
logfiletime2secs = 1000; % multiplier unit of time recorded in logfile into second��logfile��¼ʱ�䵥λת������ķŴ���?000=ms
clear onset;
for subj = 1:nsubj
    %% special issues in my experiment
    if  sum(ismember({'202' '203' '204'}, subid_list{subj})) % this is specific in my experiment
        gap = 12;
    else
        gap = 10;
    end;
    for sessi = find(filepool(subj).nbehfile == 1) % ֻ�����ļ����ڵ�session
        %% read in logfile and specify starttime
        log = tdfread(filepool(subj).behfile{sessi});
        startt = unique(log.(dummy_onset)); % get the dummy onset
        if length(startt) > 1
            error(['dummy_onset problem: ' filepool(subj).behfile{sessi}]);
        end;
        startt = startt/logfiletime2secs + gap; % image recording onset in second
        %% response trials' mask, rule out non-response trials
        rspmask = log.dot_response_onset~=-99;
        %% regressors of interests
        % guilt stage, 2*2 within-subject design: self correct, self wrong, other correct, other wrong
        scmask = mod(log.trial_type,4)==1;
        swmask = mod(log.trial_type,4)==2;
        ocmask = mod(log.trial_type,4)==3;
        owmask = mod(log.trial_type,4)==0;
        wmask = mod(log.trial_type,2)==0;
        onset(subj,sessi).gsc = log.guilt_onset(rspmask & scmask)/logfiletime2secs - startt;
        onset(subj,sessi).gsw = log.guilt_onset(rspmask & swmask)/logfiletime2secs - startt;
        onset(subj,sessi).goc = log.guilt_onset(rspmask & ocmask)/logfiletime2secs - startt;
        onset(subj,sessi).gow = log.guilt_onset(rspmask & owmask)/logfiletime2secs - startt;
        % shock sharing stage, context 1 2 3 * sw/ow
        c1mask = log.comp == 1;
        c2mask = log.comp == 2;
        c3mask = log.comp == 3;
        onset(subj,sessi).shc1sw = log.sharing_onset(rspmask & c1mask & swmask)/logfiletime2secs - startt;
        onset(subj,sessi).shc1ow = log.sharing_onset(rspmask & c1mask & owmask)/logfiletime2secs - startt;
        onset(subj,sessi).shc2sw = log.sharing_onset(rspmask & c2mask & swmask)/logfiletime2secs - startt;
        onset(subj,sessi).shc2ow = log.sharing_onset(rspmask & c2mask & owmask)/logfiletime2secs - startt;
        onset(subj,sessi).shc3sw = log.sharing_onset(rspmask & c3mask & swmask)/logfiletime2secs - startt;
        onset(subj,sessi).shc3ow = log.sharing_onset(rspmask & c3mask & owmask)/logfiletime2secs - startt;
        %% regressors of non interest
        onset(subj,sessi).grouping = log.group_onset/logfiletime2secs - startt;
        onset(subj,sessi).grouping(onset(subj,sessi).grouping<0) = [];
        onset(subj,sessi).bearing = log.bear_head_onset(rspmask & wmask)/logfiletime2secs - startt;
        onset(subj,sessi).bearQ = log.trigger_times(rspmask & wmask) - startt;
    end;
end;
save(fullfile(onsetOutdir,['onset.mat']),'onset');

%% Define Design Matrix
% regressors of interests
% SingleTrialList = {'choice'}; % regressprs' name for sinsgle trial in onset.mat
% SingleTrialCond = {'choice_condition'}; % varables for labeling each single trial in onset.mat
% DursSingleTrial = {2}; % duration of each single trial regressor
CondList = {'shc1sw' 'shc1ow' 'shc2sw' 'shc2ow' 'shc3sw' 'shc3ow' 'gsw' 'gow' 'gsc' 'goc' 'grouping' 'bearing'}; % regressors in onset.mat, plz notice the order
DursCond = { 2 2 2 2 2 2 2 2 2 2 2 2 }; % DursCond = {2 2 2 2 2 2 2 2 2 2 2 2 2 2 'cond12durs'};
Parametric_under_condition = {1 1 1 1 1 1 1 1 1 1 1 {'bearQ'}}; % Parametric_under_condition = {{'cond1para1' 'cond1para2'} 0 0 0 0};
derivs = [0 0];
% check for errors in design
DESIGNCHECK;
DsgMat % show design matrix, plz check your design matrix specified above
%%
spm fmri;
for subj = 1:nsubj
    %% load individual files
    filepoolindv = filepool(subj);
    onsetindv = onset(subj,:);
    subid = filepoolindv.subid;
    if ~strcmp(subid_list{subj},subid) % Check the matching order for subid
        error('subid mismatch when subj = %i: filepool vs.subid_list',subj);
    end;
    %% special issues in my experiment
    if sum(ismember({'214' '248'}, subid))
        NSlice = 41; % number of slices in a volume
        SliceOrder = [1:2:NSlice 2:2:NSlice];
        refSlice = 41; % reference slice
    elseif sum(ismember({'250'}, subid))
        NSlice = 39; % number of slices in a volume
        SliceOrder = [1:2:NSlice 2:2:NSlice];
        refSlice = 39; % reference slice
    else
        NSlice = 40; % number of slices in a volume
        SliceOrder = [1:2:NSlice 2:2:NSlice];
        refSlice = 39; % reference slice
    end;
    %% preprocessing
    imghead = PREPROCESSING(filepoolindv,NSlice,TR,SliceOrder,refSlice,headmovedir,VoxSize,normcheckdir);
    %% firstlevel
    Microt0 = find(SliceOrder==refSlice); % the microtime t0
    [CntrP] = FIRSTLEVEL(filepoolindv,onsetindv,DsgMat,derivs,...
        TR,NSlice,Microt0,imghead,firstleveldir);
end;
save(fullfile(paramsdir,'AllParameters.mat'));

%% Define Contrast
% define contrast
cntrstname = {'gsw','gow','shc1sw','shc1ow','shc2sw','shc2ow','shc3sw','shc3ow',...
    'gsw-gow','gsc-goc','gsw-gow-gsc+goc',...
    'shc1sw-shc1ow','shc2sw-shc2ow','shc3sw-shc3ow',...
    'shc1sw-shc1ow-shc2sw+shc2ow','shc1sw-shc1ow-shc3sw+shc3ow','shc2sw-shc2ow-shc3sw+shc3ow',...
    'gsw-gow-shc1sw+shc1ow','gsw-gow-shc2sw+shc2ow','gsw-gow-shc3sw+shc3ow',...
    'shc1sw-shc1ow+shc2sw-shc2ow+shc3sw-shc3ow',...
    'shc1sw-shc2sw','shc2sw-shc3sw','shc1sw-shc3sw',...
    {'shc1sw','shc1ow','shc2sw','shc2ow','shc3sw','shc3ow'}};
cntrsttype = [repmat({'T'},1,length(cntrstname)-1),{'F'}]; % 
% apply contrast to subjects
for subj = 1:nsubj
    subid = subid_list{subj};
    CONTRAST(cntrstname,cntrsttype,subid,firstleveldir,secondleveldir);
end;

%% Second Level Analysis

%% One-sample t-test
Maps_dir = fullfile(secondleveldir,'Contrasts');
OST_dir = fullfile(secondleveldir,'OneSampleTTest');
if ~exist(OST_dir,'dir')
    mkdir(OST_dir);
end;
includeNaN = 1; 
report = 1;
cntrstname_t = {'gsw-gow','shc1sw-shc1ow','shc2sw-shc2ow','shc3sw-shc3ow',...
    'shc1sw-shc1ow-shc2sw+shc2ow','shc1sw-shc1ow-shc3sw+shc3ow','shc2sw-shc2ow-shc3sw+shc3ow',...
    'gsw-gow-shc1sw+shc1ow','gsw-gow-shc2sw+shc2ow','gsw-gow-shc3sw+shc3ow',...
    'shc1sw-shc1ow+shc2sw-shc2ow+shc3sw-shc3ow',...
    'shc1sw-shc2sw','shc2sw-shc3sw','shc1sw-shc3sw'
    };
ctypeg_t = repmat({'T'},1,length(cntrstname_t)); % only support T contrast at 1st level
for c = 1:numel(cntrstname_t)
    filelist = {};
    for subj = 1:numel(subid_list)
        imgfile = myfnames(fullfile(Maps_dir,cntrstname_t{c},[subid_list{subj} '*.img']));
        niifile = myfnames(fullfile(Maps_dir,cntrstname_t{c},[subid_list{subj} '*.nii']));
        if ~isempty(imgfile)
            filelist(end+1) = imgfile;
        else
            filelist(end+1) = niifile;
        end;
    end;
    OneSampTTest(filelist,'T',OST_dir,cntrstname_t{c},includeNaN,1); % filelist,
    % contrast type, output directory, model's name, include nan?, report?
end;
%% Flexible Factorial (Mixed model for contrasts)
factors = {'shc1sw','shc1ow','shc2sw','shc2ow','shc3sw','shc3ow'};
effects = {'shc1sw+shc2sw+shc3sw-shc1ow-shc2ow-shc3ow',...
    'shc1sw-shc1ow-shc2sw+shc2ow',...
    'shc1sw-shc1ow-shc3sw+shc3ow',...
    'shc2sw-shc2ow-shc3sw+shc3ow',...
    {'shc1sw-shc1ow-shc2sw+shc2ow','shc1sw-shc1ow-shc3sw+shc3ow','shc2sw-shc2ow-shc3sw+shc3ow'},...
    'shc1sw-shc1ow',...
    'shc2sw-shc2ow',...
    'shc3sw-shc3ow'
    };
efftype = {'T','T','T','T','F','T','T','T'};
FFMixedCntrst(factors,effects,efftype,secondleveldir,subid_list,includeNaN,report);
%% Flexible Factorial (Mixed model for ANOVA)
conditions = {'shc1sw','shc1ow','shc2sw','shc2ow','shc3sw','shc3ow'};
design = {'g1,c1','g2,c1','g1,c2','g2,c2','g1,c3','g2,c3'}; % define factors 
% and levels corresponding to the above conditions; for each factor, 9 levels at maximum would be allowed 
maininters = {'c','g','c:g'}; % specify main effects and interactions, only 2 factors at maximum would be allowed
effects = {'g','g1-g2','c','c1-c2','c1-c3','g:c',... % speficy effects that you want to see
    'g1,c1-g2,c1-g1,c2+g2,c2','g1,c1-g2,c1-g1,c3+g2,c3','g1,c2-g2,c2-g1,c3+g2,c3'};
efftype = {'F','T','F','T','T','F','T','T','T'};
FFMixedANOVA(conditions,design,maininters,effects,efftype,secondleveldir,subid_list,includeNaN,report);

