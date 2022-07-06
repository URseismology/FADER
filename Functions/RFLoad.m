function [rrfAmpArray, timeAxisHD, binAxisHD] = RFLoad(radRF, resolutionFactor, epiDistRange)
%   Authors: Liam Moser and Trey Brink
%   This function loads a reciever function and genrate a matrix that hold
%   amplitude for the time window under a certain y-bin (epi dist or Baz)
%   Input: RFDIR = base directory, radRF = radial RF file name, transRF
%   = transverse RF file name, resolutionFactor = increase number of values
%   in linspace array. Subdivides unique time values into smaller
%   intervals. epiDistRange = range of values 
%   Output: Matrix
% just testing
%   RADIAL
%   Parsing information from reciever function file...
fid = fopen(radRF);
out = textscan(fid,'%f %f  %f\n','CommentStyle','>'); %parsing into cell array
time = out{1};
stackYValues = out{2};
rfAmp = out{3};
fclose(fid);

%   pulling out unique values
timeAxis = unique(time); %each RF has the same set of time values
binAxis = unique(stackYValues); %each RF has the same range of epicentral distance, ray param, or baz.
binAxis = binAxis((binAxis>epiDistRange(1)) & (binAxis<epiDistRange(2)));
timeAxisHD = linspace(min(timeAxis),max(timeAxis),length(timeAxis)*resolutionFactor); %High res values to improve interpolation
binAxisHD = linspace(min(binAxis),max(binAxis),length(binAxis)*resolutionFactor);

%  Setting up RF plot    
F = scatteredInterpolant(time, stackYValues, rfAmp, 'linear'); %interpolating between discrete time, y-values, and RF amplitudes
clc;
[timeGrid, binGrid] = meshgrid(timeAxisHD, binAxisHD); %fits unique time and y-values together into coherent grid
rrfAmpArray = F(timeGrid, binGrid); %interpolates on the coherent grid

%   TRANSVERSE - Update and add in lateer when needed
%   Parsing information from reciever function file...
% fid = fopen(transRF);
% out = textscan(fid,'%f %f  %f\n','CommentStyle','>'); %parsing into cell array
% time = out{1};
% stackYValues = out{2};
% rfAmp = out{3};
% fclose(fid);
% 
% %   pulling out unique values
% tu = unique(time); %each RF has the same set of time values
% yu = unique(stackYValues); %each RF has the same range of epicentral distance, ray param, or baz.
% yu = yu((yu>epiDistRange(1)) & (yu<epiDistRange(2)));
% tuh = linspace(min(tu),max(tu),length(tu)*resolutionFactor); %High res values to improve interpolation
% yuh = linspace(min(yu),max(yu),length(yu)*resolutionFactor);

%  Setting up RF plot    
% F = scatteredInterpolant(time, stackYValues, rfAmp, 'natural'); %interpolating between discrete time, y-values, and RF amplitudes
% [tgrid, ygrid] = meshgrid(tuh, yuh); %fits unique time and y-values together into coherent grid
%tfu = F(tgrid, ygrid); %interpolates on the coherent grid
% trfAmpArray = 0;