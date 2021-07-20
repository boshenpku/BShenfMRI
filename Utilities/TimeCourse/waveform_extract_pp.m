function epoch = waveform_extract_pp(ons,data,interval,samp)
idx=1;
for j=1:length(ons)
    t=interval(1):1/samp:interval(2);
    t_pre_idx=find(t<=0);
    if round(ons(j)+interval(1))>0 && samp*round(ons(j)+interval(2))<=length(data)
        temp=data(:,samp*(round(ons(j)+interval(1))):samp*(round(ons(j)+interval(2))));
        % epoch(idx,:,:)=(temp-mean(temp(t_pre_idx),2))/mean(temp(t_pre_idx),2);
        epoch(idx,:,:)=(temp-mean(data,2))/mean(data,2);
        % temp;%-repmat(mean(temp(:,:,:,t_pre_idx),4), [1, 1, 1, size(temp, 4)]);
        idx=idx+1; 
    end
end
