%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 0. Parameters setup %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FADERDir = '/scratch/tolugboj_lab/Prj4_Nomelt/FADER/';
addpath([FADERDir 'Functions/']);

kd_thresh = 2;
man_determine = 0; % mannually check autocorrelation plot

saveDir = strcat(FADERDir, 'Array/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1. Load in RF data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

network = 'TA';
stalist = {'S38A','S39A','S40A','S41A','S42A','S43A','S44A','S45A',...
    'T39A','T40A','T41A','T42A','T43A','T44A','T45A',...
    'U39A','U40A','U41A','U42A','U43A','U44A','U45A','U46A',...
    'V39A','V40A','V41A','V42A','V43A','V44A','V45A','V46A',...
    'W39A','W40A','W41A','W42A','W43A','W44A','W45A','W46A'};


for ista = 1:length(stalist)
    
    station = char(stalist(ista));
    
    fprintf('Analyzing station %s\n',station);
    
    epiDistRange = [30 95];
    resolutionFactor = 1;
    RFOUTDIR  = [FADERDir 'Data/MTCRF/'];
    [rrfAmpArray, timeAxisHD, binAxisHD] = ...
        loadAndPrepRF(network, station, resolutionFactor, epiDistRange, RFOUTDIR);
    R = rrfAmpArray; t = timeAxisHD; y = binAxisHD; nY = length(y);
    
    % use the first available (non-nan) trace
    jr = 1;
    for ir = 1:size(R,1)
        if sum(isnan(R(ir,:))) < 1 && sum(abs(R(ir,:)) < 1e-3)
            R1 = R(ir,:);
            break;
        end
        jr = jr + 1;
    end
    
    if jr > size(R,1)
        continue;
    end
    
    [epiDist, rayP] = raypToEpiDist(y, 1, FADERDir);
    hh = RFWigglePlot_any(R, t, y);
    title([station ' 1st Available Trace: ' num2str(jr)]);
    
    if ~exist([FADERDir 'Array/' network '/RF/'],'dir')
        mkdir([FADERDir 'Array/' network '/RF/']);
    end
    
    saveas(hh,[FADERDir 'Array/' network '/RF/' station '_RF.pdf']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Step 2. Run Determination test %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [SedPre,tlaga,r0,tac,ac,dsin,Qe,kd] = ...
        DeterminationTest_func(R1,t,kd_thresh,man_determine);
    
    f1 = figure(1);
    clf;
    p1 = plot(tac,ac,'k-','DisplayName','Observed AutoCorrelation','linewidth',2);
    hold on;
    p2 = plot(tac,dsin,'r-','DisplayName','Fitted AutoCorrelation','linewidth',2);
    xlabel('Time lag (s)');
    legend([p1 p2]);

    title(sprintf('Station %s, kd = %4.2f, Qe = %1d',station, kd, Qe));

    if ~exist([FADERDir 'Array/' network '/ac/'],'dir')
        mkdir([FADERDir 'Array/' network '/ac/']);
    end

    saveas(f1,[FADERDir 'Array/' network '/ac/' station '_ac.pdf']);
    
    % write Le & Qe into text files
    if ista == 1
    fid = fopen([saveDir network '.txvt'],'a+');
    fprintf(fid,'%6s %2s %2s %4s %4s\n',"Station","Qe","kd","r0","tlag");
    end
    
    fprintf(fid,'%6s %2d %4.2f %4.2f %4.2f\n',char(station),Qe,kd,r0,tlaga);
    
end

fclose(fid);

fprintf('\nExiting FADER.\n');