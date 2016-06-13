%PFinput.m
%Carolyn Voter
%June 24, 2015

%WHAT THIS SCRIPT DOES
% 1. ENTER INFO. User defines lotname, lot layout, domain, processor
%    configuration, timing, and hydraulic properties.
% 2. CALCULATE OTHER DOMAIN VARIABLES. Script calculates other
%    relevent domain info based on user inputs from "ENTER INFO".
% 3. LAND COVER FEATURES. Script calls appropriate landCover and slope
%    functions based on user inputs from "ENTER INFO", creates indicator
%    file for impervious/pervious areas, then translates 2D matrices into
%    2D pfsa format. Key matrices created include:
%       1. parcelCover
%       2. fc (feature coordinates)
%       3. slopeX
%       4. slopeY
%       5. 2D indicator matrices (pervious, impervious) for
%          subsurface top, mid1, and mid2 locations
% 4. INITIAL PRESSURE. Script creates initial pressure matrix. Assumes
%    field capacity (Pressure Head = -3.3m) for all depths below -3.3m.
%    Assumes hydrostatic conditions (Pressure Head = -Elevation) for all
%    depths above -3.3m.
% 5. SAVE PARAMETER INPUTS. Script saves basics as text file (for Model)
%    and mat files (for Post-Processing). Specifically, saves the following:
%       1. parameters.txt (Model)
%       2. domainInfo.mat (Post-Processing)
% 6. SAVE MATRIX INPUT. Script generates 3D indicator input from 2D
%    patterns, saves all matrices in final pfsa format in HPC PFinput
%    folder. Specifically, saves the following:
%       1. drv_vegm.dat (via matrixTOvegm function)
%       2. ICpressure.sa (initial pressure file)
%       3. subsurfaceFeature.sa (indicator file)
%       4. slopex.sa
%       5. slopey.sa
% 7. PLOT PARCEL COVER. Script can plot 'parcel cover' for visual check.

clear all; close all; clc;
set(0,'defaultTextFontSize',12,'defaultTextFontName','Gill Sans MT',...
    'defaultAxesFontSize',12,'defaultAxesFontName','Gill Sans MT')
load('greyImpMap.mat');

%% 1. ENTER INFO
%Note units specified below. Unless otherwise noted, L[=]m, T[=]hr
%Runname and Lot Layout
lotname = 'LotB_08';
lotType = 2; % 1=LotA, 2=LotB, 3=LotC
undeveloped = 0; % 0=developed; 1=undeveloped
downspout = 1; %0=fully connected; 1=downspouts at corners; 2=no downspouts
sidewalk = 1; %0=connected sidewalk; 1=offset sidewalk
transverse = 1; %0=no transverse slope; 1=transverse slope on driveway & front walk
microType = 1; %0=no microtopography, 1=bumpy, 2=terrace

%COMPACTED
% Ks_soil = 0.11/24/10; %m/d --> m/hr %COMPACTED
% porosity_soil = 0.40; %COMPACTED
%nonCompacted
Ks_soil = 0.11/24; %m/d --> m/hr
porosity_soil = 0.45;

triggers = [undeveloped,downspout,sidewalk,transverse,microType];

landSlope = 0.02; %magnitude of land slope
roofSlope=0.20;streetSlope=landSlope;
transverseSlope = landSlope; %driveway x-slope, frontwalk x-slope
microSlope = 0.03; %additional random microtopography slope (+/-)
dsLength = 1.5; %downspout length [m]. Only used if downspouts=2.
sidewalkOffset = 2; %distance between sidewalk and street, [m]
details = [landSlope,roofSlope,streetSlope,transverseSlope,microSlope,dsLength,sidewalkOffset];

%Time
drun = 120; %duration of each batch (hrs)
nruns = 43; %number of batches (drun*nruns = total modeled hours)

%Hydraulic Properties
mn_grass = 0.24/3600; %s*m^(-1/3) --> hr*m^(-1/3)
VGa_soil = 2.0; %1/m
VGn_soil = 1.41;
Ssat_soil = 1;
Sres_soil = 0.067/porosity_soil; 

Ks_imperv = 1e-10*3600/100; %cm/s --> m/hr
mn_imperv  = 0.012/3600; %s*m^(-1/3) --> hr*m^(-1/3)
VGa_imperv = 2.00; %1/m
VGn_imperv = 3.00;
porosity_imperv = 0.01;
Ssat_imperv = 1.0;
Sres_imperv = 0.01;

%Domain & Processors
if lotType == 1 %LotA (LgSub)
    xL = 0; dx = 0.5; nx = 49;
    yL = 0; dy =0.5; ny = 88;
    P = 7; Q = 4;
elseif lotType == 2 %LotB (SmUrb)
    xL = 0; dx = 0.5; nx = 27;
    yL = 0; dy =0.5; ny = 84;
    P = 3; Q = 4;
elseif lotType == 3 %LotC (SmUrb)
    xL = 0; dx = 0.5; nx = 32;
    yL = 0; dy =0.5; ny = 84;
    P = 4; Q = 4;
end
zL = 0; dz = 0.1; nz = 100;
R = 1;  %No. Z processors

%% 2. CALCULATE OTHER DOMAIN & TIMING VARIABLES
%Domain
xU = xL+dx*nx;  x0 = xL+dx/2;   xf = xU-dx/2;
yU = yL+dy*ny;  y0 = yL+dy/2;   yf = yU-dy/2;
zU = zL+dz*nz;  z0 = zL+dz/2;   zf = zU-dz/2;

x = x0:dx:xf;
y = y0:dy:yf;
z = z0:dz:zf;

domainArea = dx*dy*nx*ny;

%% 3. LAND COVER FEATURES
cd('K:\Parflow\Matlab\preprocessing\LotFcnsABC')
%Lot Layout
lotFcn = {@LotA,@LotB,@LotC};
slopeFcn = {@LotA_slopes,@LotB_slopes,@LotC_slopes};

%Land Cover
[X,Y,fc,parcelCover,used] = lotFcn{lotType}(dx,dy,nx,ny,triggers,details);
%   Output Key:
%     0=turfgrass, 1=street, 2=alley, 3=parking lot, 4=sidewalk, 5=driveway
%     6=frontwalk, 7=house, 8=house2 (only neede for LgSub2), 9=garage

%Slopes
[slopeX,slopeY] = slopeFcn{lotType}(x,nx,dx,y,ny,dy,fc,parcelCover,triggers,details);
cd('K:\Parflow\Matlab\preprocessing')

%Indicator files for impervious/pervious areas
%1 = pervious, 2 = impervious
domTop = zeros([ny,nx]); domTop = zeros([ny,nx]); domMid1= zeros([ny,nx]); domMid2 = zeros([ny,nx]);
for i = 1:ny
    for j = 1:nx
        if parcelCover(i,j) == 0 %Turfgrass
            vegetation(i,j) = 10;
            domTop(i,j) = 1;
            domMid1(i,j) = 1;
            domMid2(i,j) = 1;
        elseif (parcelCover(i,j) >= 1) && (parcelCover(i,j) < 7); %Impervious Surface
            vegetation(i,j) = 18;
            domTop(i,j) = 2;
            domMid1(i,j) = 1;
            domMid2(i,j) = 1;
        elseif (parcelCover(i,j) >= 7); %Garage and House
            vegetation(i,j) = 18;
            domTop(i,j) = 2;
            domMid1(i,j) = 2;
            if (parcelCover(i,j) == 7) || (parcelCover(i,j) == 8) %Just house
                domMid2(i,j) = 2;
            elseif (parcelCover(i,j) == 9) %Just garage
                domMid2(i,j) = 1;
            end
        end
    end
end

%Turn 2D Matrices into 2D pfsa format
%Slopes
slopex = matrixTOpfsa(slopeX);
slopey = matrixTOpfsa(slopeY);
%Indicator File
domainTop = matrixTOpfsa(domTop);
domainMid1 = matrixTOpfsa(domMid1);
domainMid2 = matrixTOpfsa(domMid2);

%3D Hydraulic Properties. Assumes sidewalk, front walk, driveway only
%impervious for first 2 layers. Garage is impervious for top 30cm. House is
%impervious for top 3m.
NaNimp = ones([ny nx nz]);
nMid1 = round(0.3/dz);
nMid2 = round(3.0/dz);
subsurfaceFeature = ones([nx*ny*nz],1);
%Top layer
startI = nx*ny*(nz-1)+1;
endI = nx*ny*nz;
subsurfaceFeature(startI:endI) = domainTop;
NaNimp(:,:,nz) = domTop;
%Second layer
startI = nx*ny*(nz-2)+1;
endI = nx*ny*(nz-1);
subsurfaceFeature(startI:endI) = domainTop;
NaNimp(:,:,(nz-1)) = domTop;
%Mid layers, garage and house
for i = 3:nMid2
    startI = (nz-i)*nx*ny+1;
    endI = (nz-i+1)*nx*ny;
    if i <=nMid1
        subsurfaceFeature(startI:endI) = domainMid1;
        NaNimp(:,:,(nz-i+1)) = domMid1;
    else
        subsurfaceFeature(startI:endI) = domainMid2;
        NaNimp(:,:,(nz-i+1)) = domMid2;
    end
end

%Make NaNimp have NaNs
for i = 1:ny
    for j = 1:nx
        for k = 1:nz
            if NaNimp(i,j,k) ~= 1
                NaNimp(i,j,k) = NaN;
            end
        end
    end
end
[pervY,pervX] = find(NaNimp(:,:,nz)==1,1);

%% 4. INITIAL PRESSURE
%Verified correct implementation, z-dir orientation w/ICpressure.pfb from
%test model run.
load('K:\Parflow\PFoutput\Spinup\ICsat.mat'); %Mean Sat on April 1 for 1981 - 2013 
A = VGa_soil; N = VGn_soil; M = 1-1/N;
ICp = (-1/A).*((1./(ICsat.^(1/M))-1).^(1/N)); %Convert initial sat column to initial pressure head
initialP = zeros([nx*ny*nz],1);
for i = 1:nz
    startI = (i-1)*nx*ny+1;
    endI = i*nx*ny;
    initialP(startI:endI) = ICp(i);   
end

%% 5. SAVE PARAMETER INPUTS
%Model input
inputDir = strcat('K:\Parflow\PFinput\LotType\',lotname);
mkdir(inputDir); cd(inputDir);
fid = fopen('parameters.txt','w');
fprintf(fid,'%.2f\n',xL); %1 0.00
fprintf(fid,'%.2f\n',yL); %2 0.00
fprintf(fid,'%.2f\n',zL); %3 0.00
fprintf(fid,'%.0f\n',nx); %4 integer
fprintf(fid,'%.0f\n',ny); %5 integer
fprintf(fid,'%.0f\n',nz); %6 integer
fprintf(fid,'%.2f\n',dx); %7 0.00
fprintf(fid,'%.2f\n',dy); %8 0.00
fprintf(fid,'%.2f\n',dz); %9 0.00
fprintf(fid,'%.2f\n',xU); %10 0.00
fprintf(fid,'%.2f\n',yU); %11 0.00
fprintf(fid,'%.2f\n',zU); %12 0.00
fprintf(fid,'%.0f\n',P); %13 integer
fprintf(fid,'%.0f\n',Q); %14 integer
fprintf(fid,'%.0f\n',R); %15 integer
fprintf(fid,'%.0f\n',drun); %16 integer
fprintf(fid,'%.0f\n',nruns); %17 integer
fprintf(fid,'%.4e\n',Ks_soil); %18 0.0000E0
fprintf(fid,'%.4e\n',mn_grass); %19 0.0000E0
fprintf(fid,'%.2f\n',VGa_soil); %20 0.00
fprintf(fid,'%.2f\n',VGn_soil); %21 0.00
fprintf(fid,'%.2f\n',porosity_soil); %22 0.00
fprintf(fid,'%.2f\n',Ssat_soil); %23 0.00
fprintf(fid,'%.2f\n',Sres_soil); %24 0.00
fprintf(fid,'%.4e\n',Ks_imperv); %25 0.0000E0
fprintf(fid,'%.4e\n',mn_imperv); %26 0.0000E0
fprintf(fid,'%.2f\n',VGa_imperv); %27 0.00
fprintf(fid,'%.2f\n',VGn_imperv); %28 0.00
fprintf(fid,'%.3f\n',porosity_imperv); %29 0.000
fprintf(fid,'%.2f\n',Ssat_imperv); %30 0.00
fprintf(fid,'%.2f\n',Sres_imperv); %31 0.00
fclose(fid);

% Post-processing input
% save(strcat(inputDir,'\domainInfo.mat'),'dx','dy','dz','nx','ny','nz','x',...
%     'y','z','domainArea','Ks_soil','VGa_soil','VGn_soil','Ks_imperv',...
%     'VGa_imperv','VGn_imperv','NaNimp','pervX','pervY','-v7.3');

%% 6. SAVE MATRIX INPUT
%Vegetation is different due to structure of landuse_soil.f90 file
%(reflected in matrixTOvegm function) involved in creation of drv_vegm.dat
cd('K:\Parflow\Matlab\preprocessing')
for i = 1:ny
    for j = 1:nx
        vegGrid(j,i) = vegetation(i,j); 
    end
end
%Save
matrixTOvegm(lotname,nx,ny,vegGrid);
cd(inputDir);

%Initial Pressure
fid = fopen('ICpressure.sa','a');
fprintf(fid,'%d% 4d% 2d\n',[nx ny nz]);
fprintf(fid,'% 16.7e\n',initialP(:));
fclose(fid);

%Pervious
fid = fopen('subsurfaceFeature.sa','a');
fprintf(fid,'%d% 4d% 2d\n',[nx ny nz]);
fprintf(fid,'% d\n',subsurfaceFeature(:));
fclose(fid);

%Slope X
fid = fopen('slopex.sa','a');
fprintf(fid,'%d% 4d% 2d\n',[nx ny 1]);
fprintf(fid,'% 16.7e\n',slopex(:));
fclose(fid);

%Slope Y
fid = fopen('slopey.sa','a');
fprintf(fid,'%d% 4d% 2d\n',[nx ny 1]);
fprintf(fid,'% 16.7e\n',slopey(:));
fclose(fid);

%% 7. PLOT PARCEL COVER
%Parcel Cover
figure(1)
hold on
axis equal
axis([xL-2 xU+2 yL-2 yU+2])
contourf(X,Y,parcelCover,'LineColor','none')
rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
    '-','LineWidth',1.5);
% for k = [1 2 5] %k = used
%     rectangle('Position',[fc(k,1),fc(k,3),fc(k,2)-fc(k,1),fc(k,4)-fc(k,3)],...
%         'EdgeColor','k','LineStyle','-','LineWidth',0.5);
% end
set(gcf,'Colormap',mycmap)
xlabel('Distance (m)')
ylabel('Distance (m)')
hold off
cd(inputDir);
savefig('ParcelCover.fig')
 
%Arrow Slope
cd('K:\Parflow\Matlab\preprocessing')
dp = 1; %plot every "dp" point (reduces density of arrows)
k = 0; l = 0;
for i = 1:dp:ny
    k = k + 1;
    l=0;
    for j = 1:dp:nx
        l = l + 1;
        Xa(k,l) = X(i,j);
        Ya(k,l) = Y(i,j);
        slopeXa(k,l) = slopeX(i,j);
        slopeYa(k,l) = slopeY(i,j);
        Ma(k,l) = sqrt(slopeXa(k,l)^2+slopeYa(k,l)^2);
    end
end
M = (slopeX.^2+slopeY.^2).^0.5;
figure(2)
hold on
axis equal
axis([xL-2 xU+2 yL-2 yU+2])
contourf(X,Y,M,'LineColor','none');
for k = used
    rectangle('Position',[fc(k,1),fc(k,3),fc(k,2)-fc(k,1),fc(k,4)-fc(k,3)],...
        'EdgeColor','k','LineStyle','-','LineWidth',1.5);
end
rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
    '-','LineWidth',1.5);
quiver(Xa,Ya,-slopeXa./Ma,-slopeYa./Ma,'AutoScaleFactor',0.6,'Color','k','MaxHeadSize',0.6,'LineWidth',1)
colorbar
caxis([0 0.05])
xlabel('Distance (m)')
ylabel('Distance (m)')
hold off
cd(inputDir);
savefig('Slopes.fig')