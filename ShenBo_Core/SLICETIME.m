function [imghead] = SLICETIME(filepoolindv,NSlice,TR,SliceOrder,refSlice,lastimghead)
%% Slice Timing
prefix = ['aaa'];
imghead = [prefix lastimghead];
%% check to do task
todolist = {};
for sessi = find(filepoolindv.nbehfile .* filepoolindv.nimgfile > 0)
    [commoncharacter, ~] = FindCommonCharacters(filepoolindv.imgfile{sessi});
    [d f e] = fileparts(commoncharacter);
    f = replaceWildcards(f,'**','*');
    if numel(dir(fullfile(d,[imghead f e]))) < filepoolindv.nimgfile(sessi)
        todolist{end+1} = myfnames(fullfile(d,[lastimghead f e])); %filepoolindv.imgfile{sessi};
    end;
end;
%% to do
if ~isempty(todolist)
    clear matlabbatch;
    %%
    matlabbatch{1}.spm.temporal.st.scans = todolist';
    %%
    matlabbatch{1}.spm.temporal.st.nslices = NSlice;
    matlabbatch{1}.spm.temporal.st.tr = TR;
    matlabbatch{1}.spm.temporal.st.ta = TR*(NSlice-1)/NSlice;
    matlabbatch{1}.spm.temporal.st.so = SliceOrder;
    matlabbatch{1}.spm.temporal.st.refslice = refSlice;
    matlabbatch{1}.spm.temporal.st.prefix = prefix;
    spm_jobman('run',matlabbatch);
end;
