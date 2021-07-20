function [commoncharacter, uniquelist] = FindCommonCharacters(filelist)
if size(filelist,1) == 1
    filelist = filelist';
elseif all(size(filelist) > 1)
    error('filelist must be one column or one row');
end;
try
    filemat = cell2mat(filelist);
for char = 1:size(filemat,2)
    characters = unique(filemat(:,char));
    if length(characters) == 1
        commoncharacter(char) = characters;
    elseif length(characters) > 1
        commoncharacter(char) = '*';
    end;
end;
uniquelist = filemat(:,find(commoncharacter=='*'));
catch
    error('length of string differ across the list');
end;