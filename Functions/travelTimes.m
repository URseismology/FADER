function [tPs, tPps, tPss] = travelTimes(Vp, Vs, H, rayP, Hi)
% function [tPs, tPps, tPss] = travelTimesAppx(Vp, Vs, H, rayP, Hi)
% Authors: Evan Zhang
%
% Calculate travel times for Ps conversion and its multiples
% using approximation from Shi et al., 2020 JGR
% or using exact solutions from Zhu & Kanamori 2000
%
% Input:
% Vp, Vs, H as vectors (H = 0 for half space)
% rayP as a vector
% Hi is the index of interface of interest (counting from top)
%
%
% ------------------------
% H(1), Vp(1), Vs(1)
% ------------------------ <- [Hi = 1]
% H(2), Vp(2), Vs(2)
% ------------------------ <- [Hi = 2]
% H(3), Vp(3), Vs(3)
%
% Output:
% tPs, tPps, tPss as vectors (length = length(rayP))

% Exact Solutions
for i = 1:length(rayP)
    tPs_all(i,:) = cumsum(H .* (sqrt((1./(Vs.^2) - rayP(i)^2)) - sqrt((1./(Vp.^2) - rayP(i)^2))));
    tPps_all(i,:) = cumsum(H .* (sqrt((1./(Vs.^2) - rayP(i)^2)) + sqrt((1./(Vp.^2) - rayP(i)^2))));
    tPss_all(i,:) = cumsum(2 * H .* (sqrt((1./(Vs.^2) - rayP(i)^2))));
end



tPs = tPs_all(:,Hi);
tPps = tPps_all(:,Hi);
tPss = tPss_all(:,Hi);