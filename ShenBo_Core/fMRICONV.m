function [response, timepoint] = fMRICONV(onset,duration,pmod,TR,sessionduration)
%%
% ## created by Bo Shen, Peking University, 12/10/2016 ##
% -- INPUT
% onset: onset time of event (in seconds), is a 1xN vector
% duration: duration of event (in seconds), one number or 1xN vector
% pmod: parametric modulator, 1 or 1xN vector
% TR: repetition time, in seconds
% sessionduration: length of a session(in seconds)
% -- OUTPUT
% response: simulation BOLD response to a event
% timepoint: timepoint in secs, for plotting purposes
resolution = 0.25;
t = 0:resolution:sessionduration;
hrf_25 = spm_hrf(resolution);
response = zeros(1,length(t));  %I'm assuming time resoultion of .25 s, so this corresponds to 200 2s TRs
if length(duration) == 1
    duration = repmat(duration,1,length(onset));
elseif length(duration) > 1 && length(duration) ~= length(onset)
    error('duration length is different from onset length');
end;
if length(pmod) == 1
    pmod = repmat(1,1,length(onset));
elseif length(pmod) > 1 && length(pmod) ~= length(onset)
    error('pmod length is different from onset length');
elseif length(pmod) == length(onset)
    pmod = (pmod - mean(pmod))/std(pmod);
end;
for i = 1:length(onset)
    response(onset(i)<=t & t<=(onset(i)+duration(i)))=pmod(i);  %add duration for a trial
end;
response = conv(hrf_25,response);
response = response(1:TR/resolution:length(t)); % discrete BOLD repsonse in TR
timepoint = t(1:TR/resolution:length(t));  %this is time in seconds (for plotting purposes)
