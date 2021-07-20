clear all;clc;close all;
spm fmri
%% ------ CHANGE BELOW TO MATCH YOUR DESIGN �޸����������ʺ����ʵ����� ------ %%
% Define Data path and Data structure
% variable meanings:
% *dir is a certain folder or file path
% *Fold is subpart of folder's name, for recognizing purpose
% *head is subpart of file's name, for recognizing purpose
ProjectDir = 'E:\ShenBo\GR';
batchdir = fullfile(ProjectDir,'batch');
addpath(batchdir);
CANLabdir = 'E:\ShenBo\GR\batch\CANLab';
addpath(genpath(CANLabdir));
behdir = fullfile(ProjectDir,'behvdata');
sessdir_beh = {fullfile('run1','log') fullfile('run2','log') fullfile('run3','log')};
subjhead_beh = 'sub2*.log';
imgdir = fullfile(ProjectDir,'nifti');
normcheckdir = fullfile(ProjectDir,'NormCheckSimple');
headmovedir = fullfile(ProjectDir,'headmove');
SubjFold_img = '2*';
SessFold_img = {'*RUN1*' '*RUN2*' '*RUN3*'};
imghead  = '*.nii';
strctimgFold = '*Ax_FSPGR_3D*';
strctimghead = '*Ax_FSPGR_3D.nii';
subjhead_common = [4:6]; % position of common part in subjhead_beh between beh and img subject name
OnsetOutdir = fullfile(ProjectDir,'Model','onset');
firstleveldir = fullfile(ProjectDir,'Model','FirstLevelSplitPunish');
secondleveldir = fullfile(ProjectDir,'Model','SecondLevelSplitPunish');
contrastcheckdir = fullfile(ProjectDir,'Model','NormCheck');
% Define Scanning Parameters & Design Matrix
NSlice = 40; % number of slices in a volume
SliceOrder = [1:2:NSlice 2:2:NSlice];
refSlice = 39; % reference slice
TR = 2.0;

PRECHECK; % proceeding sublist for behavior and imaging data

%% Define Design Matrix
% regressors of interests
CondList = {'gsw' 'gow' 'shc1sw' 'shc1ow' 'shc2sw' 'shc2ow' 'shc3swp' 'shc3swnp' 'shc3ow'}; % regressors' name, notice the order
DursCond = {2 2 2 2 2 2 2 2 2}; % DursCond = {2 2 2 2 2 2 2 2 2 2 2 2 2 2 'cond12durs'};
Parametric_under_condition = {1 1 1 1 1 1 1 1 1}; % Parametric_under_condition = {{'cond1para1' 'cond1para2'} 0 0 0 0};
% regressors of non-interest
Nuisance = {'gsc' 'goc' 'grouping' 'bearing'};% regressors' name
DursNuisance = {2 2 2 2};
Parametric_under_nuisance = {1 1 1 {'bearQ'}};
derivs = [0 0];
% define contrast
cname = {'gsw','gow','shc1sw','shc1ow','shc2sw','shc2ow','shc3swp','shc3swnp','shc3ow',...
    'shc3swp-shc3swnp',...
    {'gsw','gow','shc1sw','shc1ow','shc2sw','shc2ow','shc3swp','shc3swnp','shc3ow'}};
ctype = [repmat({'T'},1,length(cname)-1),{'F'}]; %

% check errors in design
DESIGNCHECK;
%%
blacklist2 = [1 11 14 19 47 55];
subjlist = 1:sz;
subjlist(blacklist2) = [];
medlist = [];
for subj = subjlist
    %
    sharec3sw = [];
    for sessi = 1:nsess
        clear log;
        logdir = fullfile(behdir,sessdir_beh{sessi});
        logfile = dir(fullfile(logdir,['*' subid{subj} '*.log']));
        log = tdfread(fullfile(logdir,logfile.name));
        outimemask = log.dot_response_onset~=-99;
        swmask = mod(log.trial_type,4)==2;
        c3mask = log.comp == 3;
        temp = log.sharing_amount(outimemask&swmask&c3mask);
        sharec3sw = [sharec3sw; temp];
    end;
    varshare = var(sharec3sw);
    if varshare == 0
        medlist = [medlist; NaN NaN NaN];
    else
        med =  median(sharec3sw);
        small = sum(sharec3sw < median(sharec3sw));
        equal = sum(sharec3sw == median(sharec3sw));
        large = sum(sharec3sw > median(sharec3sw));
        if small+equal > large + equal
            ratio = [small large+equal];
            medlist = [medlist; [med-0.1 ratio]];
        elseif small+equal < large + equal
            ratio = [small+equal large];
            medlist = [medlist; [med+0.1 ratio]];
        elseif small+equal == large + equal
            select = (rand-0.5)*0.2;
            if select >= 0
                ratio = [small+equal large];
            elseif select < 0
                ratio = [small large+equal];
            end;
            medlist = [medlist; [med+select ratio]];
        end;
    end;
end;
sublist = subjlist;
sublist = sublist(~isnan(medlist(:,1)));
dlmwrite('medlist.txt', medlist, '\t');
        
%%
for subj = sublist
    %% preprocessing
    PREPROCESSINGSimple;
    %% Onset Extract & firstlevel
    % Define time parameters in the logfile
    dummy_onset = 'dummy_onset'; % trigger/dummy onset name in logfile
    gap = 10; % second, duration from 's' trigger onset to imaging recording onset
    logfiletime2secs = 1000; % multiplier unit of time recorded in logfile into second��logfile��¼ʱ�䵥λת������ķŴ���?000=ms
    clear onset;
    for sessi = 1:nsess
        clear log;
        logdir = fullfile(behdir,sessdir_beh{sessi});
        logfile = dir(fullfile(logdir,['*' subid{subj} '*.log']))
        log = tdfread(fullfile(logdir,logfile.name));
        eval(['startt = unique(log.' dummy_onset ');']);
        if length(startt) > 1
            error([sessdir_beh{sessi} '\' logfile.name ' dummy_onset problem']);
        end;
        if  sum(ismember([202 203 204],str2double(subid{subj})))
            gap = 12;
        end;
        startt = startt/logfiletime2secs + gap; % image recording onset in second
        %% ------ CHANGE BELOW TO MATCH YOUR DESIGN �޸����������ʺ����ʵ����� ------
        %% Onset Extract
        %-- use mask and simple calculation to extract regressor's onset --%
        % non interest regressors
        onset(sessi).grouping = log.group_onset/logfiletime2secs - startt;
        onset(sessi).grouping(onset(sessi).grouping<0) = [];
        onset(sessi).dotpresent = log.predot_onset/logfiletime2secs - startt;
        onset(sessi).dotpresent(onset(sessi).dotpresent<0) = [];
        onset(sessi).dotchoice = log.dot_choice_onset/logfiletime2secs - startt;
        onset(sessi).dotchoice(onset(sessi).dotchoice<0) = [];
        outimemask = log.dot_response_onset~=-99;
        onset(sessi).dotresponse = log.dot_response_onset(outimemask)/logfiletime2secs - startt;
        % guilt onset, self correct, self wrong, other correct, other wrong
        scmask = mod(log.trial_type,4)==1;
        scmaskp = (log.corect == 1 & log.agent == 1);
        if ~all(scmask == scmaskp)
            error([subj{1} run{1} 'logfile error:scmask']);
        end;
        swmask = mod(log.trial_type,4)==2;
        swmaskp = (log.corect == 0 & log.agent == 1);
        if ~all(swmask == swmaskp)
            error([subj{1} run{1} 'logfile error:swmask']);
        end;
        ocmask = mod(log.trial_type,4)==3;
        ocmaskp = (log.corect == 1 & log.agent == 2);
        if ~all(ocmask == ocmaskp)
            error([subj{1} run{1} 'logfile error:ocmask']);
        end;
        owmask = mod(log.trial_type,4)==0;
        owmaskp = (log.corect == 0 & log.agent == 2);
        if ~all(owmask == owmaskp)
            error([subj{1} run{1} 'logfile error:owmask']);
        end;
        wmask = mod(log.trial_type,2)==0;
        wmaskp = (log.corect == 0);
        if ~all(wmask == wmaskp)
            error([subj{1} run{1} 'logfile error:wmask']);
        end;
        cmask = mod(log.trial_type,2)==1;
        cmaskp = (log.corect == 1);
        if ~all(cmask == cmaskp)
            error([subj{1} run{1} 'logfile error:cmask']);
        end;
        onset(sessi).gsc = log.guilt_onset(outimemask & scmask)/logfiletime2secs - startt;
        onset(sessi).gsw = log.guilt_onset(outimemask & swmask)/logfiletime2secs - startt;
        onset(sessi).goc = log.guilt_onset(outimemask & ocmask)/logfiletime2secs - startt;
        onset(sessi).gow = log.guilt_onset(outimemask & owmask)/logfiletime2secs - startt;
        onset(sessi).gs = log.guilt_onset(outimemask & (swmask|scmask))/logfiletime2secs - startt;
        onset(sessi).go = log.guilt_onset(outimemask & (owmask|ocmask))/logfiletime2secs - startt;
        onset(sessi).gw = log.guilt_onset(outimemask & wmask)/logfiletime2secs - startt;
        onset(sessi).gc = log.guilt_onset(outimemask & cmask)/logfiletime2secs - startt;
        onset(sessi).g = log.guilt_onset(outimemask)/logfiletime2secs - startt;
        onset(sessi).goutime = log.guilt_onset(~outimemask)/logfiletime2secs - startt;
        % shock sharing onest, context 1 2 3 * sw/ow, reaction time or button
        % press as regressor
        c1mask = log.comp == 1;
        c1maskp = (log.trial_type <= 4);
        if ~all(c1mask == c1maskp)
            error([subj{1} run{1} 'logfile error:c1mask']);
        end;
        c2mask = log.comp == 2;
        c2maskp = (log.trial_type <= 8 & log.trial_type >= 5);
        if ~all(c2mask == c2maskp)
            error([subj{1} run{1} 'logfile error:c2mask']);
        end;
        c3mask = log.comp == 3;
        c3maskp = (log.trial_type >= 9);
        if ~all(c3mask == c3maskp)
            error([subj{1} run{1} 'logfile error:c3mask']);
        end;
        pmask = log.sharing_amount>medlist(subj,1);
        npmask = log.sharing_amount<medlist(subj,1);
        onset(sessi).shc1sw = log.sharing_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc1ow = log.sharing_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shc2sw = log.sharing_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc2ow = log.sharing_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shc3sw = log.sharing_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc3swp = log.sharing_onset(outimemask & c3mask & swmask & pmask)/logfiletime2secs - startt;
        onset(sessi).shc3swnp = log.sharing_onset(outimemask & c3mask & swmask & npmask)/logfiletime2secs - startt;
        onset(sessi).shc3ow = log.sharing_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt;
        if isempty(onset(sessi).shc3swp)
            onset(sessi).shc3swp = Inf;
        end;
        if isempty(onset(sessi).shc3swnp)
            onset(sessi).shc3swnp = Inf;
        end;
        onset(sessi).sharing = log.sharing_onset(outimemask & wmask)/logfiletime2secs - startt;
        % guilt
        onset(sessi).gc1sw = log.guilt_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt;
        onset(sessi).gc1ow = log.guilt_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt;
        onset(sessi).gc2sw = log.guilt_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt;
        onset(sessi).gc2ow = log.guilt_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt;
        onset(sessi).gc3sw = log.guilt_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt;
        onset(sessi).gc3ow = log.guilt_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt;
        % reaction time
        onset(sessi).shrtc1sw = (log.sharing_confirm_onset(outimemask & c1mask & swmask) - log.sharing_onset(outimemask & c1mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc1ow = (log.sharing_confirm_onset(outimemask & c1mask & owmask) - log.sharing_onset(outimemask & c1mask & owmask))/logfiletime2secs;
        onset(sessi).shrtc2sw = (log.sharing_confirm_onset(outimemask & c2mask & swmask) - log.sharing_onset(outimemask & c2mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc2ow = (log.sharing_confirm_onset(outimemask & c2mask & owmask) - log.sharing_onset(outimemask & c2mask & owmask))/logfiletime2secs;
        onset(sessi).shrtc3sw = (log.sharing_confirm_onset(outimemask & c3mask & swmask) - log.sharing_onset(outimemask & c3mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc3ow = (log.sharing_confirm_onset(outimemask & c3mask & owmask) - log.sharing_onset(outimemask & c3mask & owmask))/logfiletime2secs;
        onset(sessi).shrt = (log.sharing_confirm_onset(outimemask & wmask) - log.sharing_onset(outimemask & wmask))/logfiletime2secs;
        % sharing amount
        onset(sessi).shQc1sw = log.sharing_amount(outimemask & c1mask & swmask);
        onset(sessi).shQc1ow = log.sharing_amount(outimemask & c1mask & owmask);
        onset(sessi).shQc2sw = log.sharing_amount(outimemask & c2mask & swmask);
        onset(sessi).shQc2ow = log.sharing_amount(outimemask & c2mask & owmask);
        onset(sessi).shQc3sw = log.sharing_amount(outimemask & c3mask & swmask);
        onset(sessi).shQc3ow = log.sharing_amount(outimemask & c3mask & owmask);
        onset(sessi).shQ = log.sharing_amount(outimemask & wmask);
        % button press
        onset(sessi).shPc1sw = log.button_press(outimemask & c1mask & swmask);
        onset(sessi).shPc1ow = log.button_press(outimemask & c1mask & owmask);
        onset(sessi).shPc2sw = log.button_press(outimemask & c2mask & swmask);
        onset(sessi).shPc2ow = log.button_press(outimemask & c2mask & owmask);
        onset(sessi).shPc3sw = log.button_press(outimemask & c3mask & swmask);
        onset(sessi).shPc3ow = log.button_press(outimemask & c3mask & owmask);
        onset(sessi).shP = log.button_press(outimemask & wmask);
        % bearing
        onset(sessi).bear1sw = log.bear_head_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt;
        onset(sessi).bear1ow = log.bear_head_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt;
        onset(sessi).bear2sw = log.bear_head_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt;
        onset(sessi).bear2ow = log.bear_head_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt;
        onset(sessi).bear3sw = log.bear_head_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt;
        onset(sessi).bear3ow = log.bear_head_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt;
        onset(sessi).bearing = log.bear_head_onset(outimemask & wmask)/logfiletime2secs - startt;
        onset(sessi).bearQ = log.trigger_times(outimemask & wmask) - startt;
        %% ---------- USUALLY DO NOT CHANGE BELOW ����ͨ�������޸�
        % Visulize deisgn matrix, ��ƾ�����ӻ�
        sessfold = dir(fullfile(imgdir,foldlist_img{subj},SessFold_img{sessi}));
        ImgCount = length(dir(fullfile(imgdir,foldlist_img{subj},sessfold.name,imgheadarwz)));
        sessionduration = ImgCount*TR; % secs
        img = VisualizeDsgnMat(onset,CondList,DursCond,Parametric_under_condition,Nuisance,DursNuisance,Parametric_under_nuisance,sessionduration,TR);
        VDMdir = fullfile(OnsetOutdir,'VisualizeDesgMat');
        if ~exist(VDMdir,'dir')
            mkdir(VDMdir);
        end;
        %         imshow(img);
        imwrite(img,fullfile(VDMdir,sprintf('%ssess%i.tiff',subid{subj},sessi)),'tiff');
    end;
    save(fullfile(OnsetOutdir,[subid{subj} 'onset.mat']),'onset');
    
    %% firstlevel
    % specify
    Microt0 = find(SliceOrder==refSlice); % the microtime t0
    [CntrP,reg] = FIRSTLEVEL(onset,CondList,DursCond,Parametric_under_condition,...
        Nuisance,DursNuisance,Parametric_under_nuisance,derivs,...
        TR,NSlice,Microt0,imgdir,foldlist_img{subj},SessFold_img,imgheadarwz,firstleveldir);
    % contrast
    T1fold = dir(fullfile(imgdir,foldlist_img{subj},strctimgFold));
    T1file = dir(fullfile(imgdir,foldlist_img{subj},T1fold.name,strctimghead));
    T1file = fullfile(imgdir,foldlist_img{subj},T1fold.name,T1file(1).name);
    sessfold = dir(fullfile(imgdir,foldlist_img{subj},SessFold_img{1}));
    meanbold = dir(fullfile(imgdir,foldlist_img{subj},sessfold.name,'mean*.nii'));
    meanbold = fullfile(imgdir,foldlist_img{subj},sessfold.name,meanbold.name);
    CONTRAST(cname,ctype,firstleveldir,foldlist_img{subj},secondleveldir,...
        NormalizeDone(subj),T1file,meanbold,contrastcheckdir);
end;
save(fullfile(firstleveldir,'ModelParameters.mat'));
%%
load(fullfile(firstleveldir,'ModelParameters.mat'));
%% Second Level
close all; spm fmri
blacklist1 = find(isnan(medlist(:,1)))';
blacklist2 = [1 11 14 19 47 55];
blacklist = unique([blacklist1 blacklist2]);
subjlist = foldlist_img;
subjlist(blacklist) = [];
report = 1;
%% One-sample t-test
cnameg1 = {'gsw','gow','shc1sw','shc1ow','shc2sw','shc2ow','shc3swp','shc3swnp','shc3ow',...
    'shc3swp-shc3swnp'};
ctypeg1 = repmat({'T'},1,length(cnameg1)); % only support T contrast at 1st level
OneSampTTestIncludeNaN(cnameg1,ctypeg1,secondleveldir,subjlist,report);

%%
% rmpath(batchdir);
% rmpath(genpath(CANLabdir));
% close all;
