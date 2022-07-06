function  [rrfAmpArray, timeAxisHD, binAxisHD] = ...
    loadAndPrepRF(network, station, resolutionFactor, epiDistRange, RFOUTDIR)
%Author: Liam Moser
%This function sets up correct file directories in order to load RF. In
%addition is preps an error array.

%File directories
radRF = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_1_f1.00_.Epic_Rad_Jack.xyz'];
% radRFDevMax = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_2_f2_.Epic_Rad_Jack.devMax.xyz'];
% radRFDevMin = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_2_f2_.Epic_Rad_Jack.devMin.xyz'];
transRF = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_1_f1.00_.Epic_Trans_Jack.xyz'];
% transRFDevMax = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_2_f2_.Epic_Trans_Jack.devMax.xyz'];
% transRFDevMin = [RFOUTDIR '/' network '/' 'RF_t_Dist_' network '_' station '_2_f2_.Epic_Trans_Jack.devMin.xyz'];

%Load jackknifed RFs and stats
[rrfAmpArray, timeAxisHD, binAxisHD] = RFLoad(radRF, resolutionFactor, epiDistRange);
% [rrfAmpArrayDevMax, ~, ~, ~] = RFLoad(radRFDevMax, transRFDevMax, resolutionFactor, epiDistRange);
% [rrfAmpArrayDevMin, ~ , ~, ~] = RFLoad(radRFDevMin, transRFDevMin, resolutionFactor, epiDistRange);

%Prep error RF array
% [rrfAmpArrayDev, ~, ~] = ...
%     RFLoadError(radRFDevMin, radRFDevMax, resolutionFactor, epiDistRange);
