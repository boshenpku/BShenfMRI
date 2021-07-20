% PreDeleteData
logdir = 'E:\ShenBo\GR\behvdata';
imgdir = 'E:\ShenBo\GR\niftispm12';
TR = 2;
record = [];
for subj = 201:262
    for run = 1:3
        logpath = fullfile(logdir,['run' num2str(run)],'log');
        logfile = dir(fullfile(logpath,['sub' num2str(subj) '*.log']));
        behvdata = importdata(fullfile(logpath,logfile.name));
        behvdata = behvdata.data;
        dummy = unique(behvdata(:,8));
        last = max(behvdata(:,23));
        if  sum(ismember([202 203 204],subj))
            gap = 12;
        else
            gap = 10;
        end;
        duration = (last - dummy)/1000 - gap + 16;
        subjpath = dir(fullfile(imgdir,[num2str(subj) '*']));
        runpath = dir(fullfile(imgdir,subjpath.name,['*RUN' num2str(run) '*']));
        filepath = fullfile(imgdir,subjpath.name,runpath.name);
        aaafile = dir(fullfile(filepath,'aaa*.nii'));
        rrrfile = dir(fullfile(filepath,'rrr*.nii'));
        meanfile = dir(fullfile(filepath,'mean*.nii'));
        rpfile = dir(fullfile(filepath,'rp*.txt'));
        wwwfile = dir(fullfile(filepath,'www*.nii'));
        zzzfile = dir(fullfile(filepath,'zzz*.nii'));
        sssfile = dir(fullfile(filepath,'sss*.nii'));
        nnnfile = dir(fullfile(filepath,'nnn*.nii'));
        matfile = dir(fullfile(filepath,'*.mat'));
        cd(filepath);
        if ~isempty(aaafile)
            delete(aaafile.name);
        end;
        if ~isempty(rrrfile)
            delete(rrrfile.name);
        end;
        if ~isempty(meanfile)
            delete(meanfile.name);
        end;
        if ~isempty(rpfile)
            delete(rpfile.name);
        end;
        if ~isempty(wwwfile)
            delete(wwwfile.name);
        end;
        if ~isempty(zzzfile)
            delete(zzzfile.name);
        end;
        if ~isempty(sssfile)
            delete(sssfile.name);
        end;
        if ~isempty(nnnfile)
            delete(nnnfile.name);
        end;
        if ~isempty(matfile)
            delete(matfile.name);
        end;
        % pause(0.5);
%         niifile = dir(fullfile(filepath,'*.nii'));
%         scans = length(niifile);
%         if scans > ceil(duration/TR)
%             delete(niifile(ceil(duration/TR)+1:end).name);
%         end;
%         niifile = dir(fullfile(filepath,'*.nii'));
%         scans = length(niifile);
%         record = [record; subj run scans];
    end;
end;
cd(imgdir);
% save('record');
