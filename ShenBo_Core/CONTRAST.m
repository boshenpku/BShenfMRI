function CONTRAST(cntrstname,cntrsttype,subjname,firstleveldir,secondleveldir,report)
%% Contrast sepcify
if ~exist('report','var')
    report = 0;
end; 
datadir = fullfile(firstleveldir,subjname);
load(fullfile(datadir,'CntrP.mat'));

SPMest=load(fullfile(datadir,'SPM.mat'));
SPMest=SPMest.SPM;
SPMest.xCon = [];
regr = size(SPMest.Sess,2) + SPMest.Sess(end).col(end);
for c= 1:length(cntrstname)
    if cntrsttype{c} == 'T'
        cons = zeros(1,regr);
        if (cntrstname{c}(1) ~= '-' && cntrstname{c}(1) ~= '+')
            cnametmp = ['+' cntrstname{c}];
        end;
        tp = find(cnametmp=='+'|cnametmp=='-');
        for cal = 1:length(tp)
            if cal < length(tp)
                r = cnametmp((tp(cal)+1):(tp(cal+1)-1));
            elseif cal == length(tp)
                r = cnametmp((tp(cal)+1):end);
            end;
            eval(['cons(CntrP.' r ')=' cnametmp(tp(cal)) '1']);
        end;
        contrast(c).cname = char(cntrstname(c));
        contrast(c).ctype = char(cntrsttype(c));
        contrast(c).cons = cons';
    elseif cntrsttype{c} ==  'F'
        cons = zeros(length(cntrstname{c}),regr);
        for f = 1:length(cntrstname{c})
            if (cntrstname{c}{f}(1) ~= '-' && cntrstname{c}{f}(1) ~= '+')
                cnametmp = ['+' cntrstname{c}{f}];
            end;
            tp = find(cnametmp=='+'|cnametmp=='-');
            for cal = 1:length(tp)
                if cal < length(tp)
                    r = cnametmp((tp(cal)+1):(tp(cal+1)-1));
                elseif cal == length(tp)
                    r = cnametmp((tp(cal)+1):end);
                end;
                eval(['cons(f,CntrP.' r ')=' cnametmp(tp(cal)) '1']);
            end;
        end;
        contrast(c).cname = [num2str(f) 'F' cntrstname{c}{1} '...' cntrstname{c}{f}];
        contrast(c).ctype = cntrsttype{c};
        contrast(c).cons = cons';
    end;
    
    if isempty(SPMest.xCon)
        SPMest.xCon = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
    else
        SPMest.xCon (end+1) = spm_FcUtil('Set',contrast(c).cname, contrast(c).ctype,'c',contrast(c).cons,SPMest.xX.xKXs);
    end;
end;
spm_contrasts(SPMest);

%% report results
if report == 1
    %% report contrast results
    first_result_report.threshdesc = {'none'};
    first_result_report.thresh = [1];
    first_result_report.extent = [0];
    % result report spm
    for c = 1:1%length(cntrstname)
        for i = 1:length(first_result_report.threshdesc)
            clear matlabbatch;
            con_name = contrast(c).cname;
            matlabbatch{1}.spm.stats.results.spmmat = {fullfile(datadir,'SPM.mat')};
            matlabbatch{1}.spm.stats.results.conspec.titlestr = con_name;
            matlabbatch{1}.spm.stats.results.conspec.contrasts = c;
            matlabbatch{1}.spm.stats.results.conspec.threshdesc = char(first_result_report.threshdesc{i});
            matlabbatch{1}.spm.stats.results.conspec.thresh = first_result_report.thresh(i);
            matlabbatch{1}.spm.stats.results.conspec.extent = first_result_report.extent(i);
            matlabbatch{1}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.print = true;
            spm_jobman('run',matlabbatch);
        end;
    end;
end;
%% copy contrast files
for c = 1:length(cntrstname)
    contrast_dir = fullfile(secondleveldir,'Contrasts',contrast(c).cname);
    if ~exist(contrast_dir)
        mkdir(contrast_dir);
    end;
    if cntrsttype{c} == 'T'
        sourcefile = sprintf('con_%04i',c);
    elseif cntrsttype{c} == 'F'
        sourcefile = sprintf('ess_%04i',c);
    end;
    if ~isempty(dir(fullfile(datadir,[sourcefile,'.nii'])))
        if ispc || ismac
            copyfile(fullfile(datadir,[sourcefile,'.nii']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.nii']));
        elseif isunix
            copyfile(fullfile(datadir,[sourcefile,'.nii']),fullfile('~/',[subjname,'_',contrast(c).cname,'.nii']));
            movefile(fullfile('~/',[subjname,'_',contrast(c).cname,'.nii']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.nii']));
        end;
    else
        if ispc || ismac
            copyfile(fullfile(datadir,[sourcefile,'.img']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.img']));
            copyfile(fullfile(datadir,[sourcefile,'.hdr']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.hdr']));
        elseif isunix
            copyfile(fullfile(datadir,[sourcefile,'.img']),fullfile('~/',[subjname,'_',contrast(c).cname,'.img']));
            movefile(fullfile('~/',[subjname,'_',contrast(c).cname,'.img']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.img']));
            copyfile(fullfile(datadir,[sourcefile,'.hdr']),fullfile('~/',[subjname,'_',contrast(c).cname,'.hdr']));
            movefile(fullfile('~/',[subjname,'_',contrast(c).cname,'.hdr']),fullfile(contrast_dir,[subjname,'_',contrast(c).cname,'.hdr']));
        end;
    end;
end;