function [tBest, tsrch, AA] = cceps_stack(tt,cc,twin,opt)
% function [tBest, tsrch, AA] = cceps_stack(tt,cc,twin,opt)
% Author: Evan Zhang
%
% [Input]
%
% tt & cc: time axis and complex cepstrum vector
% twin: time window for search
% opt: figure option

tsrch = linspace(twin(1),twin(2),100);
sig = 0.1;

A = zeros(length(tsrch),length(tt));

% mute water - only sediment left to search

Hw = 5.0; vw = 1.5;
tw = 2 * Hw / vw;

Dt = tt(2) - tt(1);
weightw = ones(1,length(cc));
weightw(round((tw-0.05)/Dt):round((tw+0.05)/Dt)) = 0;
weightw(round((2*tw-0.05)/Dt):round((2*tw+0.05)/Dt)) = 0;

% cc = cc .* weightw;


% weighting factor from Stoffa equation
% R = 0.8178;
% w1 = R; w2 = (R/2)^2; w3 = (R/3)^3; w4 = (R/4)^4;
% w1 = w1/(w1+w2+w3+w4); w2 = w2/(w1+w2+w3+w4); w3 = w3/(w1+w2+w3+w4); w4 = w4/(w1+w2+w3+w4);

for it = 1:length(tsrch)
    
    thist = tsrch(it);
%     weight = -(4/7) * gaussmf(tt,[sig thist]) + (2/7) * gaussmf(tt,[sig 2*thist]) - ...
%         (1/7) * gaussmf(tt,[sig 3*thist]);
%     
weight = -(0.25) * gaussmf(tt,[sig thist]) + (0.09) * gaussmf(tt,[sig 2*thist]);

%     weight = -(w1) * gaussmf(tt,[sig thist]) + (w2) * gaussmf(tt,[sig 2*thist]) - ...
%         (w3) * gaussmf(tt,[sig 3*thist]) + (w4) * gaussmf(tt,[sig 4*thist]);

A(it,:) = cc .* weight; % absolute value

end

AA = mean(A,2);
AA = AA ./ max(AA);
% AA(AA<0) = 0;

[AAmax,AAmaxl] = max(AA);
tBest = tsrch(AAmaxl);

if opt
    
    figure(21);
    clf;
    
    plot(tsrch,AA,'r-','linewidth',2);
    hold on;
    
    xlabel('Delay Time (s)');
    ylabel('Stack Amplitude');
    
    plot([tBest tBest],[0 AAmax],'k:');
    text(tBest,0.1*AAmax,sprintf('Est. Delay Time = %4.2f s',tBest));
    
end