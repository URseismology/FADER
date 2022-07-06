function tPbS = tPbS_Confirm(R, t, y, man)
% function tPbS = tPbS_Confirm(R, t, y, man)
% Author: Evan Zhang
%
% Plot receiver function traces and the auto-detected PbS arrival for user
% to manually confirm.

twin = [0.2 5];

Dt = t(2) - t(1);
it = find(t>(twin(1)-Dt/3) & t<(twin(1)+Dt/3));
endt = find(t>(twin(2)-Dt/3) & t<(twin(2)+Dt/3));

jr = findfirsttrace(R);
Rsrch = R(jr,it:endt);

[~,locs] = findpeaks(Rsrch);

tPbS = (locs(1) - 1) * Dt + twin(1);

if man
    
    tStart = 0;
    tEnd = 20;
    
    it = find(t>tStart, 1); %Removing negative time
    endt = find(t>tEnd, 1);
    
    nY = length(y);
    
    f3 = figure(3);
    clf;
    
    set(gcf,'position',[50,50,1000,1000]);
    
    subplot(5,3,1:15);
    hold on;
    
    mm = max(abs(R(:,it:endt)), [] ,'all');
    
    for iY = 1:nY
        
        Rn = R(iY,it:endt) ./ mm;
        Tn = t(it:endt); sizeT = length(Tn);
        
        yLev = (nY-iY);
        yVec = repmat(yLev, 1, sizeT);
        
        jbfill(Tn, max(Rn+yLev, yLev), yVec, [0 0 1],'k', 1, 1.0);
        jbfill(Tn, min(Rn+yLev, yLev), yVec, [1 0 0],'k', 1, 1.0);
        
    end
    
    hold on;
    xline(tPbS,'k--','linewidth',2);
    
    xlim([0 tEnd]);
    ylim([-1 nY+1]);
    xlabel('Time (s)','FontSize', 24);
    
    title(strcat('Detected PbS arrival: ',num2str(tPbS),' s'));
    
    fprintf('\nPlease see Figure 3.\n');
    fprintf('Detected PbS arrival: %3.2f s\n', tPbS);
    fprintf('Press Enter if agree,\n');
    tPbS_in = input('Otherwise please manually input PbS arrival time:\n'); 
    if ~isempty(tPbS_in)
        tPbS = tPbS_in;
    end
    
    close(f3);
    
end
