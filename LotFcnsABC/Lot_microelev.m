function [] = Lot_microelev(nx,dx,ny,dy,sd,landslope,lotname)
%LotB_elevation.m
%Carolyn Voter
%October 18, 2016

%Example command:
%Lot_microelev(48,0.5,88,0.5,0.0285,0.02,'LotA');
%Lot_microelev(27,0.5,84,0.5,0.0285,0.02,'LotB');
%Lot_microelev(32,0.5,84,0.5,0.0285,0.02,'LotC');

%% Generate random roughness
for i = 1:ny+1
    for j = 1:nx+1
        elev(i,j) = normrnd(0,sd);
    end
end

%% Calculate actual RR and depression storage
RRinc = 0;
for i = 1:ny+1
    for j = 1:nx+1
        RRinc = RRinc + (elev(i,j) - mean(mean(elev)))^2;
    end
end
RRcalc = sqrt((1/(ny*nx-1))*RRinc)*100; %Random roughness [cm]
DScalc = 0.112*RRcalc+0.031*RRcalc^2-0.012*RRcalc*landslope*100; %Depression storage [cm]

%% Calculate slopes
for i = 1:ny
    for j = 1:nx
        slopeY(i,j) = (elev(i+1,j)-elev(i,j))/dy;
        slopeX(i,j) = (elev(i,j+1)-elev(i,j))/dx;
    end
end
savename=strcat(lotname,'_microelev.mat');
save(savename,'elev','slopeX','slopeY','sd','RRcalc','DScalc');
end