function [microElev,sd,RRcalc,DScalc] = lot_microtopography(sd,landslope,lotname)
%Carolyn Voter
%October 18, 2016

% This script shows how microtopography deviations in elevation were
% randomly generated based on Onstad (1984). A single realization of this
% script (data/layouts/lot_microelev.mat) was used for all scenarios with
% microtopography.

% Usage: [microElev,sd,RRcalc,DScalc] = lot_microtopography(sd,landslope,'LotLayout');
%   sd = standard deviation of elevation (m), aka 'random roughness'
%   landslope = slope of land surface away from house (m/m)
%   'LotLayout' = file that includes ny and nx for this type of lot
% Example: [microElev,sd,RRcalc,DScalc] = lot_microtopography(0.0375,0.02,'Lot00');

% To account for pit-filling later on, do:
%   RR = 3.75cm --> DS = 7.7mm --> DS ~= 5mm after pit filling
% Without pit-filling:
%   RR = 2.85cm  = 5mm depression storage
%   RR = 1.75cm  = 2.5mm depression storage

%% Load lot layout data (for nx and ny)
load(sprintf('../../data/layouts/%s',lotname))

%% Generate random roughness
for i = 1:ny+1
    for j = 1:nx+1
        microElev(i,j) = normrnd(0,sd);
    end
end

%% Calculate actual RR and depression storage
RRinc = 0;
for i = 1:ny+1
    for j = 1:nx+1
        RRinc = RRinc + (microElev(i,j) - mean(mean(microElev)))^2;
    end
end
RRcalc = sqrt((1/(ny*nx-1))*RRinc)*100; %Random roughness [cm]
DScalc = 0.112*RRcalc+0.031*RRcalc^2-0.012*RRcalc*landslope*100; %Depression storage [cm]
end