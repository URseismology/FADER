%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 0. Parameters setup %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FADERDir = '/scratch/tolugboj_lab/Prj4_Nomelt/FADER/';
addpath([FADERDir 'Functions/']);

kd_thresh = 2;
man_determine = 1; % mannually check autocorrelation plot
tolerance = 0; % Echo delay time from autocorrelation and homomorphic

saveRF = 1;
saveDir = strcat(FADERDir,'filteredRF/');
savename = 'NE68';
smoothopt = 1; % smooth filtered RF

Hkopt = 1;

Vp = 6.4; % of crust
Hwin = [25 55];
kwin = [1.6 1.9];
resfac = 100;
pWAc = [0.6 0.3 -0.1]; % weighting factors for H-k stacking
wid = 0.1; % width of Gaussian windows in H-k stacking

man_PbS = 1; % mannually confirm PbS arrival for H-k stacking

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1. Load in RF data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modify this part to load in your own data

dataopt = 2;

switch dataopt
    
    case 1 % Telewavesim Synthetics
        
        RFmat = load(strcat(FADERDir,'Data/Synthetics/M1_1.0Hz_syn.mat'));
        R = RFmat.rRF;
        t = RFmat.time; y = RFmat.garc; nY = length(y);
        R1 = R(2,:);
        [epiDist, rayP] = raypToEpiDist(y, 1, 1, localBaseDir);
        
    case 2 % Real Data from MTC RF
        
        network = 'YP';
        station = 'NE68';
        epiDistRange = [30 95];
        resolutionFactor = 1;
        RFOUTDIR  = [FADERDir 'Data/MTCRF/'];
        [rrfAmpArray, timeAxisHD, binAxisHD] = ...
            loadAndPrepRF(network, station, resolutionFactor, epiDistRange, RFOUTDIR);
        R = rrfAmpArray; t = timeAxisHD; y = binAxisHD; nY = length(y);
        R1 = R(1,:);
        [epiDist, rayP] = raypToEpiDist(y, 1, FADERDir);
        
end

% No need to edit the rest of this code %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2. Run Determination test             %
% Step 3. Get tlag & r0 from autocorrelation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[SedPre,tlaga,r0,tac,ac,dsin] = ...
    DeterminationTest_func(R1,t,kd_thresh,man_determine);

if SedPre == 0
    if Hkopt == 0
        fprintf('No reverberation detected. Exiting FADER.\n');
    else
        tlag = 0;
        tPbS = 0;
        fprintf('No reverberation detected. Will run H-k stacking directly.\n');
    end
else
    fprintf('Reverberation detected. Analyzing ...\n');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 4. Run cepstrum analysis to get tlag and compare %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if tlaga < 1
        twin_cstack = [0 2];
    else
        twin_cstack = [tlaga-1 tlaga+1];
    end
    
    [tlagc,cstackt,cstackA] = ceps_func(R1,t,twin_cstack);
    
    if abs(tlagc - tlaga) < tolerance * max(tlagc, tlaga)
        tlag = 0.5 * (tlagc + tlaga);
    else
        if man_determine
            tlag = tlag_check(tac,ac,dsin,tlaga,cstackt,cstackA,tlagc,tolerance);
        else
            tlag = tlaga;
        end
    end
    
    fprintf('tlag = %3.2f s, r0 = %3.2f.\n',tlag,r0);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 5. Filter the RF using determined parameters %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('\nFiltering data ...\n');
    R_flted = filterRF_FADER(R,t,tlag,r0,smoothopt);
    
    if saveRF
        fprintf('Saving filtered RF ...\n');
        nname = strcat(saveDir,savename,'.mat');
        save(nname,'R','R_flted','t','y');
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6. Optional H-k Stacking %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Hkopt
    
    if SedPre == 1
        tPbS = tPbS_Confirm(R, t, y, man_PbS);
        R2stack = R_flted;
    else
        R2stack = R;
    end
    
    [stackArray, Hrange, krange, HBest, kBest] = ...
        HkStacking(R2stack, t, rayP, Vp, Hwin, kwin, resfac, pWAc, wid, ...
        SedPre, tlag, tPbS,1);
    
end

fprintf('\nExiting FADER.\n');