function ROIExtract(ROIname,center,conditions,design,maininters,cname,ctype,secondleveldir,subjlist,report)
%% ROI extract
if (length(conditions) ~= length(design))
    error('Number of conditions and design miss match');
end;
if (length(cname) ~= length(ctype))
    error('Number of cname and ctype miss match');
end;
Design_dir = fullfile(secondleveldir,'FFMixedANOVA');
if ~exist(Design_dir,'dir')
    mkdir(Design_dir);
end;
cd(Design_dir);
% ROIname = 'PCC-6_-58_28';
filename = [ROIname '.txt'];
% center = [-6 -58 28];
fpointer = fopen(filename,'w');
fprintf(fpointer,'%s\t%s\t%s\t%s\t%s\n','subid','condname','agent','context','beta');


for c = 1:length(conditions)
    tp = find(design{c}==',');
    nfact = length(tp)+1;
    for f = 1:(length(tp)+1)
        if f == 1
            condmat{f}{c} = design{c}(1:(tp(f)-1));
        elseif f > 1 && f < (length(tp)+1)
            condmat{f}{c} = design{c}((tp(f-1)+1):(tp(f)-1));
        elseif f == length(tp)+1
            condmat{f}{c} = design{c}((tp(f-1)+1):end);
        end;
    end;
end;
for f = 1:nfact
    factlevel{f} = unique(condmat{f});
    nlevel(f) = length(factlevel{f});
    factname{f} =  factlevel{f}{1}(1:end-1);
end;
%%
sz = length(subjlist);
i = 0;
Cond_mat = [];
for c = 1:length(conditions)
    tmp = [];
    for f = 1:nfact
        tmp = [tmp,str2double(condmat{f}{c}(end))];
    end;
    for subj = 1:sz
        i = i + 1;
        filelist{i} = fullfile(secondleveldir,conditions{c},['zr' subjlist{subj},'_',conditions{c},'.img']);
        filename = filelist{i};
        V = spm_vol(filename);
        samplenum = 0;
        beta_value = 0;
        for x = 1:3
            for y = 1:3
                for z = 1:3
                    coord = [center(1)+3*(x-2) center(2)+3*(y-2) center(3)+3*(z-2)];
                    MNI=coord;
                    coord = V(1).mat\[MNI';ones(1,size(MNI',2))];
                    beta_value = beta_value + spm_sample_vol(V(1),coord(1),coord(2),coord(3),0);
                    samplenum = samplenum + 1;
                end;
            end;
        end;
        beta_value = beta_value/samplenum;
        fprintf(fpointer,'%s\t%s\t%i\t%i\t%f\n',subjlist{subj},conditions{c},tmp(1),tmp(2),beta_value);
    end;
end;
fclose(fpointer);
fprintf('Done %s\n',ROIname)
