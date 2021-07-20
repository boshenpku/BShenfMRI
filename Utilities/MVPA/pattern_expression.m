%%Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_ToMloc_GPIfws.nii']);
% pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp =[pexp1,pexp2,pexp3,pexp4];
% 
% r1=corr (new_data1.dat,pattern_mask.dat);
% r2=corr (new_data2.dat,pattern_mask.dat);
% r3=corr (new_data3.dat,pattern_mask.dat);
% r4=corr (new_data4.dat,pattern_mask.dat);


%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);

pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4];


%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_GI_NG2_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);

pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4];


%% Apply pattern expression to new data
clearc
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f2 = filenames('/data1/FengWangshu/CI_fMRI/FirstLevel_flexible_contrast/contrast6_t2d2/*_con_*.img');
f1 = filenames('/data1/FengWangshu/CI_fMRI/FirstLevel_flexible_contrast/contrast5_t2d1/*_con_*.img');
f3 = filenames('/data1/FengWangshu/CI_fMRI/FirstLevel_flexible_contrast/contrast7_t2d3/*_con_*.img');
f4 = filenames('/data1/FengWangshu/CI_fMRI/FirstLevel_flexible_contrast/contrast8_t2d4/*_con_*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4];


%%Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/12_sen_FF/*.img');%fristlevel contrast
f2 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/9_sen_FS/*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp = [];
pexp =[pexp1,pexp2];


%%Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_GI_NG2_GPIfws.nii']);

f1 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/7_sen_AS/*.img');%fristlevel contrast
f2 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/8_sen_MS/*.img');
f3 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/9_sen_FS/*.img');
f4 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/10_sen_AF/*.img');
f5 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/11_sen_MF/*.img');
f6 = filenames('/data1/ZhanJiayu/scalar_implicature_zjy/SecondLevel_fws/12_sen_FF/*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
data5 = fmri_data(f5);
data6 = fmri_data(f6);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp5 = apply_mask(data5,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp6 = apply_mask(data6,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4,pexp5,pexp6];



%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_PINP_withbiTPJMask.nii']);
% pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);

pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2];


%% 

clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/SSI_LanguageRelated_loc/contrast1_sentence/*_con_*.img');
f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/SSI_LanguageRelated_loc/contrast2_nonword/*_con_*.img');
data1 = fmri_data(f1);
data2 = fmri_data(f2);

pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2];


%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'meaning_reverse_pFgA_z_FDR_0.01.nii']);
% pattern_mask = fmri_data([fPath 'semantic_reverse_pFgA_z_FDR_0.01.nii']);
% pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4];


%% Apply NeuroSynth topic (pattern expression) to GPI data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/';

%%%% try to apply Luke's weight map to the four rating images
% pattern_mask = fmri_data([fPath 'v4-topics-400_59_semantic_word_words_pFgA_z_FDR_0.01.nii']);
pattern_mask = fmri_data([fPath 'v4-topics-400_214_comprehension_sentences_language_pFgA_z_FDR_0.01.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1';pexp2';pexp3';pexp4'];

%% Apply NeuroSynth 'semantic' topic50 (pattern expression) to GPI data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/';

%%%% try to apply Luke's weight map to the four rating images
% pattern_mask = fmri_data([fPath 'v4-topics-400_59_semantic_word_words_pFgA_z_FDR_0.01.nii']);
pattern_mask = fmri_data([fPath 'v4-topics-50_44_semantic_words_word_pFgA_z_FDR_0.01.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1';pexp2';pexp3';pexp4'];


c
%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/weight_map/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'SVM_GING_withConjunctionMPFCmask.nii']);
% pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

% f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
% f2 = filcenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
% f3 =
% filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');ccccc
% f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

f5 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_photo/*con*.img');
f6 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_belief/*con*.img');

% data1 = fmri_data(f1);
% data2 = fmri_data(f2);
% data3 = fmri_data(f3);
% data4 = fmri_data(f4);

data5 = fmri_data(f5);
data6 = fmri_data(f6);

% pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
% pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
% pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
% pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp5 = apply_mask(data5,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp6 = apply_mask(data6,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + interceptc

pexp = [];
% pexp =[pexp1,pexp2,pexp3,pexp4];
pexp = [pexp5,pexp6]

c%% Apply pattern expression to new data
clear
fPath = '/data3/FengWangshu/GPI_fMRI/MVPA/';

%%%% try to apply Luke's weight map to the four rating images
pattern_mask = fmri_data([fPath 'tom_pFgA_z_FDR_0.01.nii']);
% pattern_mask = fmri_data([fPath 'SVM_PI_NP_GPIfws.nii']);

f1 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast4_NG2/*con*.img');
f2 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast5_GI/*con*.img');
f3 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast1_NP/*con*.img');
f4 = filenames('/data3/FengWangshu/GPI_fMRI/MVPA/contrast2_PI/*con*.img');

data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

pexp = [];
pexp =[pexp1,pexp2,pexp3,pexp4];

%% Apply pattern expression to new data
clear
fPath = 'E:\ShenBo\GR\Model\MVPA\weight_map';

%%%% try to apply Luke's weight map to the four rating images
% pattern_mask = fmri_data([fPath 'v4-topics-200_33_sentences_language_comprehension_pFgA_z_FDR_0.01.nii']);
pattern_mask = fmri_data([fPath '\SVM_ShC3S_O.nii']);
% pattern_mask = fmri_data([fPath 'semantic_reverse_pFgA_z_FDR_0.01.nii']);
% pattern_mask = fmri_data([fPath 'weight_map/SVM_ToMtask_withConjunctionMPFCmask.nii']);
% pattern_mask = fmri_data([fPath 'weight_map/SVM_ToMloc_GPIfws.nii']);


f1 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc1sw\zr*.img');
f2 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc1ow\zr*.img');
f3 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc2sw\zr*.img');
f4 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc2ow\zr*.img');
f5 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc3sw\zr*.img');
f6 = filenames('E:\ShenBo\GR\Model\SecondLevel\shc3ow\zr*.img');


data1 = fmri_data(f1);
data2 = fmri_data(f2);
data3 = fmri_data(f3);
data4 = fmri_data(f4);
data5 = fmri_data(f5);
data6 = fmri_data(f6);

pexp1 = apply_mask(data1,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp2 = apply_mask(data2,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp3 = apply_mask(data3,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp4 = apply_mask(data4,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp5 = apply_mask(data5,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept
pexp6 = apply_mask(data6,pattern_mask,'pattern_expression','ignore_missing') ; %testing slope + intercept

f1 = pexp1;
f2 = pexp2;
f3 = pexp3;
f4 = pexp4;
f5 = pexp5;
f6 = pexp6;

nsub = length(f5);
label = [ones(nsub,1);-1*ones(nsub,1)];
to_be_test1 = [f2;f1];
to_be_test2 = [f4;f3];
% to_be_test4 = [f5;f6];
to_be_test3 = [f6;f5];

create_figure('ROC'); 
ROC1 = roc_plot(to_be_test1, label > 0, 'color', [1,0.5,0], 'threshold', 0, 'twochoice'); %forced based on other's pattern, get ROC, orange
ROC2 = roc_plot(to_be_test2, label > 0, 'color', [0,0.6,1], 'threshold', 0, 'twochoice'); %blue
ROC3 = roc_plot(to_be_test3, label > 0, 'color', [0.5,0.5,0.5], 'threshold', 0, 'twochoice');
save('E:\ShenBo\GR\Model\MVPA\dat\ShC3S_O_ExpressC1C2C3','ROC1','ROC2','ROC3');
% ROC4 = roc_plot(to_be_test4, label > 0, 'color', [0,0,0], 'threshold', 0, 'twochoice');

