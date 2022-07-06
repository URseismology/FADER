function [hh] = RFWigglePlot_any(R, t, y)

% Authors: Tolulope Olugboji, Liam Moser, Evan Zhang
% Plotting RF as traces, assist in visualizing data quality and selected
% arrival times.

%% Prepping values to be plotted from RF

SED = 0;

tWin = [0 25];
epiDistRange = [30 95];

% RF variables
nY = length(y);

tStart = tWin(1); tEnd = tWin(2);

%Time window to smooth over where location conversion and reverberation
it = find(t>tStart, 1); %Removing negative time
endt = find(t>tEnd, 1);

% Summary stack
for iY = 1:nY
    R(iY,:) = detrend(R(iY,:));
end
RR = R(:,it:endt);
sumR = sum(RR,  1);

%% Plot pure RF traces with out weighting

hh = figure(20);
clf;

set(gcf,'position',[50,50,800,800]);

subplot(5,3,1:15);
hold on;

tshft = 0;
mm = max(abs(R(:,it:endt)), [] ,'all');

for iY = 1:nY
    
    Rn = R(iY,it:endt) ./ mm;
    Rn = Rn - mean(Rn);
    Tn = t(it:endt); sizeT = length(Tn);
    
    yLev = (nY-iY);
    yVec = repmat(yLev, 1, sizeT);
    
    jbfill(Tn, max(Rn+yLev, yLev), yVec, [0 0 1],'k', 1, 1.0);
    jbfill(Tn, min(Rn+yLev, yLev), yVec, [1 0 0],'k', 1, 1.0);
    
end


% Plotting axis
yticks([0:5:nY]);
set(gca,'yticklabel', floor(linspace(epiDistRange(1),epiDistRange(2),(nY/5)+1)))
% set(gca,'xticklabel', '')
xlim([0 tEnd])
ylim([-1 nY+1])
%xlabel('Time (s)','FontSize', 24)
ylabel('Epicentral distance (deg)','FontSize', 20)

grid on
