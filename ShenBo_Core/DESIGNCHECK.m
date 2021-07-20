% Check ERRORS in the Design Settings
clear DsgMat;
if exist('SingleTrialList','var')
    if length(SingleTrialList) ~= length(DursSingleTrial)
        error('Please Check SingleTrialList and DursSingleTrial');
    end;
    if length(SingleTrialList) ~= length(SingleTrialCond)
        error('Please Check SingleTrialList and SingleTrialCond');
    end;
    DsgMat.SingleTrialList = SingleTrialList;
    DsgMat.SingleTrialCond = SingleTrialCond;
    DsgMat.DursSingleTrial = DursSingleTrial;
end;

if length(CondList) ~= length(Parametric_under_condition)
    error('Please Check CondList and Parametric_under_condition');
end;
if length(CondList) ~= length(DursCond)
    error('Please Check CondList and DursCond');
end;
DsgMat.CondList = CondList;
DsgMat.DursCond = DursCond;
DsgMat.Parametric_under_condition = Parametric_under_condition;
save(fullfile(paramsdir,'DesignMatrix.mat'),'DsgMat');