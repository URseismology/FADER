function [sed_pre,tlag,r0,tac,ac,sigr,Qe,kd] = ...
    DeterminationTest_func(Rarray, timeAxisHD, kd_thresh, man)
% function [sed_pre,tlag,r0,tac,ac,sigr,Qe,kd] = ...
%    DeterminationTest_func(Rarray, timeAxisHD, kd_thresh, man)
%
% Author: Evan Zhang
%
% This function determines if reverberation presents in the input RFs. If
% so, it also outputs the two-way travel time (tlag) and reverberation
% strength (r0) derived from autocorrelation + best fit damped sine wave
% analysis.
%
% kd_thresh: threshold for kd. If kd is larger than this kd_thresh then
% the input RF is considered to have reverberation in it.
%
% man: option for manually check the autocorrelation and best fit damped
% sine wave to determine the presence of reverberation.


% frequency setup
Dt = timeAxisHD(2) - timeAxisHD(1);
N = length(timeAxisHD);

fmax = 1/(2.0*Dt);
df = fmax/(N/2);
f = df*[0:N/2,-N/2+1:-1]';
Nf = N/2+1;
dw = 2.0*pi*df;
w = dw*[0:N/2,-N/2+1:-1]';

t_end = 40; % in seconds - time range to calculate ac
t0 = find(timeAxisHD > 0, 1);
tend = find(timeAxisHD > t_end, 1);
tac = timeAxisHD(t0:tend);

if size(Rarray,1) > 1
    thisR = sum(Rarray,1);
else
    thisR = Rarray;
end

D = thisR(t0:tend); % use the sum
Nac = length(D);
D = D';
D = D - mean(D);
D = detrend(D);

ac = xcorr(D);
ac = ac./max(ac);
ac = ac(Nac:2*Nac-1);

% fit a decaying sinusoid - from Cunningham et al. (2019)
[sigr,resr] = fit_damped_sinewave(ac);
tlag = (pi / resr(3)) * Dt;
r0 = - sigr(round(pi / resr(3)));

% echo quality factor (Qe)
kthru = kd_thresh;
kd = abs(resr(3)/resr(2)); 

if kd > kthru
    Qe = 1;
else
    Qe = 0;
end

% determine if reverberation presents

if man == 1
    
    f1 = figure(1);
    clf;
    p1 = plot(tac,ac,'k-','DisplayName','Observed AutoCorrelation','linewidth',2);
    hold on;
    p2 = plot(tac,sigr,'r-','DisplayName','Fitted AutoCorrelation','linewidth',2);
    xline(10*tlag,'r-');
    xlabel('Time lag (s)');
    legend([p1 p2]);
    
    fprintf('Please see Figure 1.\n');
    fprintf('kd = %4.2f, Echo Quality Factor: %d  ', kd, Qe);
    if Qe == 1
        fprintf('(Indicates echo)\n');
    else
        fprintf('(Indicates no echo)\n');
    end
    fprintf('Echo Likelihood Factor: %4.1f\n',Le);
    fprintf('Manually determine if reverberation presents.\n');
    sed_pre = input('1 = Yes, 0 = No:\n');

    close(f1);
    
elseif kd < kd_thresh
    
    sed_pre = 0;
    
else
    
    sed_pre = 1;
    
end

end

