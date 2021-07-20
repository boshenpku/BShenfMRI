function img = VisualizeDsgnMat(onset,CondList,DursCond,Parametric_under_condition,Nuisance,DursNuisance,Parametric_under_nuisance,sessionduration,TR)
clear r tr;
reg = 0;
for condi = 1:length(CondList)
    reg = reg + 1;
    if isnumeric(DursCond{condi})
        duration = DursCond{condi};
    elseif ischar(DursCond{condi})
        duration = eval(['onset.' DursCond{condi}]);
    end;
    [r(:,reg),tr(:,reg)] = fMRICONV(eval(['onset.' CondList{condi}]),duration,1,TR,sessionduration);
    if iscell(Parametric_under_condition{condi})
        for para = 1:length(Parametric_under_condition{condi})
            reg = reg + 1;
            [r(:,reg),tr(:,reg)] = fMRICONV(eval(['onset.' CondList{condi}]),duration,eval(['onset.' Parametric_under_condition{condi}{para}]),TR,sessionduration);
        end;
    elseif isnumeric(Parametric_under_condition{condi})
    end;
end;
for nui = 1:length(Nuisance) % DursCond DursNuisance
    reg = reg + 1;
    if isnumeric(DursNuisance{nui})
        duration = DursNuisance{nui};
    elseif ischar(DursNuisance{nui})
        duration = eval(['onset.' DursNuisance{nui}]);
    end;
    [r(:,reg),tr(:,reg)] = fMRICONV(eval(['onset.' Nuisance{nui}]),duration,1,TR,sessionduration);
    if iscell(Parametric_under_nuisance{nui})
        for para = 1:length(Parametric_under_nuisance{nui})
            reg = reg + 1;
            [r(:,reg),tr(:,reg)] = fMRICONV(eval(['onset.' Nuisance{nui}]),duration,eval(['onset.' Parametric_under_nuisance{nui}{para}]),TR,sessionduration);
        end;
    elseif isnumeric(Parametric_under_nuisance{nui})
    end;
end;
r = (r - min(r(:)))/(max(r(:))-min(r(:)));
width = round(length(r(:,1))/9*3/4);
img = [];
for c = 1:reg
    img = [img repmat(r(:,c),1,width)];
end;