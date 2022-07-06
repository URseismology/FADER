function [tlag,cstackt,cstackA] = ceps_func(RR,tt,twin)
% function [tlag,cstackt,cstackA] = ceps_func(RR,tt,twin)
%
% Author: Evan Zhang
%
% Run cepstrum analysis (compute complex cepstrum and perform linear stack
% for optimal delay time).
%
% [RR] - single/multi trace input data (receiver function);
% [tt] - time vector;
% [twin] - time window to perform linear stack.


% truncate real RF trace to [0 40] seconds
ibgn = find (tt == 0);
iend = find (tt > 40, 1);

tt = tt(ibgn:iend);

if size(RR,1) > 1
    thisRa = sum(RR,1);
    thisR = thisRa(ibgn:iend);
else
    thisR = RR(ibgn:iend);
end

% perform cepstral analysis

cc = cceps_man(tt,thisR);

% stack

[tlag,cstackt,cstackA] = cceps_stack(tt,cc,twin,0);