function [tlag] = tlag_check(tac,ac,dsin,tlaga,cstackt,cstackA,tlagc,tolerance)
% function [tlag] = tlag_check(tac,ac,dsin,tlaga,cstackt,cstackA,tlagc,tolerance)
%
% Author: Evan Zhang
%
% Plot (1) autocorrelation and its best-fit damped sine wave and (2)
% cepstrum stack for user to manually determine the two-way travel time.


figure(2);
set(gcf,'position',[200,500,1000,400]);
clf;
subplot(1,2,1);
plot(tac,ac,'k-','DisplayName','AutoCorrelation');
hold on;
plot(tac,dsin,'r--','DisplayName','Damped Sine');
hold on;
xlabel('Time lag (s)');
legend;

xline(tlaga,'b:','DisplayName','Two-way travel time');
title(sprintf('Autocorrelation, tlag = %3.2f s',tlaga));

subplot(1,2,2);
plot(cstackt,cstackA,'r-');
hold on;
xlabel('Delay Time (s)');
ylabel('Stack Amplitude');

xline(tlagc,'r:');
title(sprintf('Cepstrum Stack, tlag = %3.2f s',tlagc));

fprintf('\nPlease see Figure 2.\n');
fprintf('Two-way travel time obtained from autocorrelation\n');
fprintf('and cepstrum stack are off more than tolerance (%2d %%).\n',tolerance*100);
fprintf('Autocorrelation: %3.2f s;\n',tlaga);
fprintf('Cepstrum stack : %3.2f s.\n',tlagc);

tlag = input('Please manually input two-way travel time:\n');
