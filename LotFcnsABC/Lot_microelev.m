function [] = Lot_microelev(nx,ny,sd,landslope,lotname)
%LotB_elevation.m
%Carolyn Voter
%October 18, 2016

%RR = 2.85cm  = 5mm depression storage
%RR = 1.75cm  = 2.5mm depression storage

%Example command:
%Lot_microelev(48,88,0.0285,0.02,'LotA');
%Lot_microelev(27,84,0.0285,0.02,'LotB');
%Lot_microelev(32,84,0.0285,0.02,'LotC');

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

savename=strcat(lotname,'_microelev.mat');
save(savename,'microElev','sd','RRcalc','DScalc');
end