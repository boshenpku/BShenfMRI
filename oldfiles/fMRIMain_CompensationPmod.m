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
behdir = fullfile(ProjectDir,'behvdata','calculated');
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
OnsetOutdir = fullfile(ProjectDir,'Model','onsetCompPmod','model1');
firstleveldir = fullfile(ProjectDir,'Model','FirstLevelCompPmod','model1');
secondleveldir = fullfile(ProjectDir,'Model','SecondLevelCompPmod','model1');
contrastcheckdir = fullfile(ProjectDir,'Model','NormCheckCompPmod','model1');
% Define Scanning Parameters & Design Matrix
NSlice = 40; % number of slices in a volume
SliceOrder = [1:2:NSlice 2:2:NSlice];
refSlice = 39; % reference slice
TR = 2.0;

PRECHECK; % proceeding sublist for behavior and imaging data

%% Define Design Matrix
% regressors of interests
CondList = {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow', 'gsw', 'gow'}; % regressors' name, notice the order
DursCond = {2 2 2 2 2 2 2 2}; % DursCond = {2 2 2 2 2 2 2 2 2 2 2 2 2 2 'cond12durs'};
Parametric_under_condition = {{'shQc1sw'} {'shQc1ow'} {'shQc2sw'} {'shQc2ow'} {'shQc3sw'} {'shQc3ow'} 1 1}; % Parametric_under_condition = {{'cond1para1' 'cond1para2'} 1 1 1 1};
% regressors of non-interest
Nuisance = {'gsc' 'goc' 'grouping'};% regressors' name
DursNuisance = {2 2 2};
Parametric_under_nuisance = {1 1 1};
derivs = [0 0];
% define contrast
cname = {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow',...
    'shQc1sw', 'shQc1ow', 'shQc2sw', 'shQc2ow', 'shQc3sw', 'shQc3ow',...
    'bear1sw-bear1ow','bear2sw-bear2ow','bear3sw-bear3ow',...
    'bear1sw-bear1ow+bear2sw-bear2ow+bear3sw-bear3ow',...
    'bear1sw-bear2sw','bear2sw-bear3sw','bear1sw-bear3sw',...
    'gsw-gow-bear1sw+bear1ow-bear2sw+bear2ow-bear3sw+bear3ow',...
    'shQc1sw-shQc1ow','shQc2sw-shQc2ow','shQc3sw-shQc3ow',...
    'shQc1sw-shQc1ow+shQc2sw-shQc2ow+shQc3sw-shQc3ow',...
    'shQc1sw-shQc2sw','shQc2sw-shQc3sw','shQc1sw-shQc3sw',...
    'gsw', 'gow', 'gsw-gow',...
     {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow'}};
ctype = [repmat({'T'},1,length(cname)-1),{'F'}]; 
% check errors in design
DESIGNCHECK;
%%
for subj = 1:sz
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
        onset(sessi).shc1sw = log.sharing_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc1ow = log.sharing_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shc2sw = log.sharing_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc2ow = log.sharing_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shc3sw = log.sharing_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shc3ow = log.sharing_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt;
        onset(sessi).sharing = log.sharing_onset(outimemask & wmask)/logfiletime2secs - startt;
        onset(sessi).pa1 = log.pa1(outimemask & wmask);
        onset(sessi).pa2 = log.pa2(outimemask & wmask);
        onset(sessi).pa3 = log.pa3(outimemask & wmask);
        onset(sessi).r1 = log.r1(outimemask & wmask);
        onset(sessi).r2 = log.r2(outimemask & wmask);
        onset(sessi).r3 = log.r3(outimemask & wmask);
        onset(sessi).r4 = log.r4(outimemask & wmask);
        onset(sessi).r5 = log.r5(outimemask & wmask);
        onset(sessi).r6 = log.r6(outimemask & wmask);
        onset(sessi).r7 = log.r7(outimemask & wmask);
         %sharing confirm onset 
        onset(sessi).shcfmc1sw = log.sharing_confirm_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shcfmc1ow = log.sharing_confirm_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shcfmc2sw = log.sharing_confirm_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shcfmc2ow = log.sharing_confirm_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt;
        onset(sessi).shcfmc3sw = log.sharing_confirm_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt;
        onset(sessi).shcfmc3ow = log.sharing_confirm_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt;
        onset(sessi).sharingcfm = log.sharing_confirm_onset(outimemask & wmask)/logfiletime2secs - startt;
        % reaction time
        onset(sessi).shrtc1sw = (log.sharing_confirm_onset(outimemask & c1mask & swmask) - log.sharing_onset(outimemask & c1mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc1ow = (log.sharing_confirm_onset(outimemask & c1mask & owmask) - log.sharing_onset(outimemask & c1mask & owmask))/logfiletime2secs;
        onset(sessi).shrtc2sw = (log.sharing_confirm_onset(outimemask & c2mask & swmask) - log.sharing_onset(outimemask & c2mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc2ow = (log.sharing_confirm_onset(outimemask & c2mask & owmask) - log.sharing_onset(outimemask & c2mask & owmask))/logfiletime2secs;
        onset(sessi).shrtc3sw = (log.sharing_confirm_onset(outimemask & c3mask & swmask) - log.sharing_onset(outimemask & c3mask & swmask))/logfiletime2secs;
        onset(sessi).shrtc3ow = (log.sharing_confirm_onset(outimemask & c3mask & owmask) - log.sharing_onset(outimemask & c3mask & owmask))/logfiletime2secs;
        onset(sessi).shrt = (log.sharing_confirm_onset(outimemask & wmask) - log.sharing_onset(outimemask & wmask))/logfiletime2secs;
        %sharing middle onset 
        onset(sessi).shmidc1sw = log.sharing_confirm_onset(outimemask & c1mask & swmask)/logfiletime2secs - startt - onset(sessi).shrtc1sw/2;
        onset(sessi).shmidc1ow = log.sharing_confirm_onset(outimemask & c1mask & owmask)/logfiletime2secs - startt - onset(sessi).shrtc1ow/2;
        onset(sessi).shmidc2sw = log.sharing_confirm_onset(outimemask & c2mask & swmask)/logfiletime2secs - startt - onset(sessi).shrtc2sw/2;
        onset(sessi).shmidc2ow = log.sharing_confirm_onset(outimemask & c2mask & owmask)/logfiletime2secs - startt - onset(sessi).shrtc2ow/2;
        onset(sessi).shmidc3sw = log.sharing_confirm_onset(outimemask & c3mask & swmask)/logfiletime2secs - startt - onset(sessi).shrtc3sw/2;
        onset(sessi).shmidc3ow = log.sharing_confirm_onset(outimemask & c3mask & owmask)/logfiletime2secs - startt - onset(sessi).shrtc3ow/2;
        onset(sessi).sharingmid = log.sharing_confirm_onset(outimemask & wmask)/logfiletime2secs - startt - onset(sessi).shrt/2;
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
        img = VisualizeDsgnMat(onset(sessi),CondList,DursCond,Parametric_under_condition,Nuisance,DursNuisance,Parametric_under_nuisance,sessionduration,TR);
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

%% Second Level
close all; spm fmri
% blacklist = [1 11 14 19 47 55];
subjlist = foldlist_img;
% subjlist(blacklist) = [];
report = 1;
% One-sample t-test
cnameg1 = {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow',...
    'shQc1sw', 'shQc1ow', 'shQc2sw', 'shQc2ow', 'shQc3sw', 'shQc3ow',...
    'bear1sw-bear1ow','bear2sw-bear2ow','bear3sw-bear3ow',...
    'bear1sw-bear1ow+bear2sw-bear2ow+bear3sw-bear3ow',...
    'bear1sw-bear2sw','bear2sw-bear3sw','bear1sw-bear3sw',...
    'gsw-gow-bear1sw+bear1ow-bear2sw+bear2ow-bear3sw+bear3ow',...
    'shQc1sw-shQc1ow','shQc2sw-shQc2ow','shQc3sw-shQc3ow',...
    'shQc1sw-shQc1ow+shQc2sw-shQc2ow+shQc3sw-shQc3ow',...
    'shQc1sw-shQc2sw','shQc2sw-shQc3sw','shQc1sw-shQc3sw',...
    'gsw', 'gow', 'gsw-gow'};
ctypeg1 = repmat({'T'},1,length(cnameg1));
OneSampTTestIncludeNaN(cnameg1,ctypeg1,secondleveldir,subjlist,report);

% %% Flexible Factorial (Mixed model for contrasts)
% factors = {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow'};
% cnameg2 = {'bear1sw+bear2sw+bear3sw-bear1ow-bear2ow-bear3ow',...
%     'bear1sw-bear1ow-bear2sw+bear2ow',...
%     'bear1sw-bear1ow-bear3sw+bear3ow',...
%     'bear2sw-bear2ow-bear3sw+bear3ow',...
%     {'bear1sw-bear1ow-bear2sw+bear2ow','bear1sw-bear1ow-bear3sw+bear3ow','bear2sw-bear2ow-bear3sw+bear3ow'}
%     };
% ctypeg2 = {'T','T','T','T','F'};
% FFMixedCntrstIncludeNaN(factors,cnameg2,ctypeg2,secondleveldir,subjlist,report);
% 
% %% Flexible Factorial (Mixed model for ANOVA)
% conditions = {'bear1sw','bear1ow','bear2sw','bear2ow','bear3sw','bear3ow'};
% design = {'g1,c1','g2,c1','g1,c2','g2,c2','g1,c3','g2,c3'}; % maximum 9 levels for a factor
% maininters = {'c','g','c:g'}; % only 2 factors allowed
% cnameg3 = {'g','g1-g2','c','c1-c2','c1-c3','g:c',...
%     'g1,c1-g2,c1-g1,c2+g2,c2','g1,c1-g2,c1-g1,c3+g2,c3','g1,c2-g2,c2-g1,c3+g2,c3'};
% ctypeg3 = {'F','T','F','T','T','F','T','T','T'};
% FFMixedANOVAIncludeNaN(conditions,design,maininters,cnameg3,ctypeg3,secondleveldir,subjlist,report);

%%
rmpath(batchdir);
rmpath(genpath(CANLabdir));
close all;
