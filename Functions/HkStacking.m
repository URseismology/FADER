function [stackArray, Hrange, krange, HBest, kBest] = ...
    HkStacking(R, t, rayP, Vp, Hwin, kwin, resfac, pWAc, wid, sed, tlag, tPbS, opt)
% function [stackArray, Hrange, krange, HBest, kBest] = ...
%    HkStacking(R, t, rayP, Vp, Hwin, kwin, resfac, pWAc, wid, sed, tlag, tPbS, opt)
% Author: Evan Zhang, 5/4/22
%
% Perform simple H-k stacking for receiver functions.
% Set the last three input parameters to account for delay effect of
% sediment.
%
% [Input]
%
% R, t, rayP: self explanatory
% Vp: pre-assume Vp for stacking
% Hwin & kwin: H and k searching window
% resfac: size of H and k range
% pWAc: weighting factors for Ps, Pps, Pss phases. three-element vector.
% wid: width of gaussian window. previously used value: 0.2
% opt: plot option
%
% NOTE: SET THE FOLLOWING THREE PARAMETERS TO ZERO IF NO SEDIMENT
% sed: set to 1 if sediment presents, otherwise set to 0
% tlag: two-way travel time in sediment
% tPbS: arrival time of PbS phase (relative to direct P)
%
% [Output]
%
% stackArray: final stacking amplitude array. row - H, column - k.
% Hrange & krange & HBest & kBest: self explanatory

% drop bad data row with NaN

inew = 1;
for ir = 1:size(R,1)
    if sum(isnan(R(ir,:))) == 0
        Rnew(inew,:) = R(ir,:);
        rayPnew(inew) = rayP(ir);
        inew = inew + 1;
    end  
end

R = Rnew;
rayP = rayPnew;

% define search range

Hrange = linspace(Hwin(1), Hwin(2), resfac);
krange = linspace(kwin(1), kwin(2), resfac);

nP  = length(rayP);
tA = repmat(t, nP,1);

stackArray = zeros(resfac,resfac);

% start search in two for-loops

icount = 1;
for iH = 1:length(Hrange)
    
    for ik = 1:length(krange)
        
        Vs = Vp/krange(ik);
        H = Hrange(iH);
        
        [tPs, tPps, tPss] = travelTimes(Vp, Vs, H, rayP, 1);
        
        if sed % corrections for sediment
            
            tPs = tPs + tPbS;
            tPps = tPps + tlag - tPbS;
            tPss = tPss + tlag;
            
        end
        
        nT = length(t);
        t1 = repmat(tPs,  1, nT);
        t2 = repmat(tPps, 1, nT);
        t3 = repmat(tPss, 1, nT);
        
        weight ...
            = pWAc(1) .*exp(1).^((-(tA-t1).^2)./(2*(wid/3.5)^2)) ...
            + pWAc(2) .*exp(1).^((-(tA-t2).^2)./(2*(wid/3.5)^2)) ...
            + pWAc(3) .*exp(1).^((-(tA-t3).^2)./(2*(wid/3.5)^2));
        
        % Linear stack
        sumRF = sum(weight .* R, 1);
        stackArray(iH,ik) = sum(sumRF); % change to sumRFn
        
        % print progress to command window
        if iH == 1 && ik == 1
            fprintf('H-k Stacking in progress ... Grid point %6d of %6d',...
                icount, resfac*resfac);
        else
            fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%6d of %6d',icount,...
                resfac*resfac);
        end
        
        if icount == resfac*resfac
            fprintf('\n');
        end
        
        icount = icount + 1;
        
    end
end

[maxInCols , rowIndices] = max(stackArray); % locate max row in each col
[~, colI] = max(maxInCols); % find col index of max value
rowI = rowIndices(colI);
HBest = Hrange(rowI); kBest = krange(colI); %Best values

%% plotting
if opt
    
    h = figure(1);
    clf;
    
    [~,h] = contourf(krange, Hrange, stackArray./max(stackArray(:)));
    set(h,'LineColor','none');
    hold on;
    
    colormap('parula'); % parula is a good one
    cb = colorbar;
    set(gca,'FontSize', 10);
    xlabel('Vp/Vs','FontSize', 10);
    ylabel('H (km)','FontSize', 10);
    title({['H = ' num2str(round(HBest, 1))...
        ' km   Vp/Vs = ' num2str(round(kBest, 2))]}, 'FontSize', 10);
    shading Interp
    plot(kBest, HBest, 'ko', 'markerfacecolor', 'r');
    yline(HBest);
    xline(kBest);
    
end

