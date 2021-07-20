function NormaliseChk(todolist)
%% Normalise Check
% orthview for check EPI image preprocessing, comparing with single_sub_T1.nii
% created by Shen Bo
% based on CANLAB SCNcore script
outputfilename = 'NormaliseChk';

%% to do
if ~isempty(todolist)
    [d f e] = fileparts(which('spm'));
    T1file = fullfile(d,'canonical','single_subj_T1.nii');
    mask = todolist{1};
    data = fmri_data(todolist,mask);
    Chkfor = 1;
    if Chkfor == 1
        orthviews(data,'overlay',T1file);
    elseif Chkfor == 0
        orthviews(data);
    end;
    clear matlabbatch;
    matlabbatch{1}.spm.util.print.fname = outputfilename; %% Orthview Graphics Filename for saving
    matlabbatch{1}.spm.util.print.opts.opt = { '-dpsc2';'-append'}';
    matlabbatch{1}.spm.util.print.opts.append = true;
    matlabbatch{1}.spm.util.print.opts.ext = '.ps';
    spm_jobman('run',matlabbatch);
end;