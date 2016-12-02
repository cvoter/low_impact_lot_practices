%PFlots.m
%Carolyn Voter
%October 19, 2016

%WHAT THIS SCRIPT DOES:
% 1. LOT INFO. User defines lotname and lot layout options
% 2. DOMAIN AND PROCESSOR INFO. Based on lot type specified in "LOT INFO",
%    calculates domain and processor information. 
% 3. CALL LAND COVER AND SLOPE FUNCITONS. Script calls appropriate
%    landCover and slope functions based on user inputs from "LOT INFO".
%    Yields:
%       1. parcelCover
%       2. fc (feature coordinates)
%       3. slopeX (also converted to slopex)
%       4. slopeY (also converted to slopey)
% 4. INDICATOR FILE. Takes information about 2D parcel cover and rearranges
%    into pfsa format. Makes assumptions about depth of impervious
%    surfaces, garage, and house. Yields:
%       1. subsurfaceFeature mask, becomes indicator file
%       2. vegetation mask for drv_vegm.dat
%       3. NaNimp, pervX, pervY (masks used when post-processing)
% 5. SAVE LOT INPUTS. Saves basics for input. Specifically:
%       1. parameters.txt (Model)
%       2. domainInfo.mat (Post-Processing)
%       3. drv_vegm.dat (via matrixTOvegm function)
%       4. subsurfaceFeature.sa (indicator file)
%       5. slopex.sa
%       6. slopey.sa
% 6. PLOT. Plots and savs:
%       1. Grey map of impervious area
%       2. Colorful map of impervious features and slopes.

clear all; close all; clc;
set(0,'defaultTextFontSize',12,'defaultTextFontName','Helvetica',...
    'defaultAxesFontSize',12,'defaultAxesFontName','Helvetica')
load('greyImpMap.mat');
addpath('J:\Research\Parflow\inputs\matlab_in');

%% 1. LOT INFO
%Note units specified below. Unless otherwise noted, L[=]m, T[=]hr
lotname = 'LotB_07';
saveDir = strcat('K:\Parflow\PFinput\LotType\',lotname); mkdir(saveDir);

%Layout triggers
lotType = 2; % 1=LotA, 2=LotB, 3=LotC
developed = 1; % 0=undeveloped; 1=developed
downspout = 0; %0=fully connected; 1=downspouts at corners; 2=no downspouts
sidewalk = 0; %0=connected sidewalk; 1=offset sidewalk
transverse = 0; %0=no transverse slope; 1=transverse slope on driveway & front walk
microType = 1; %0=no microtopography, 1=microtopography
triggers = [developed,downspout,sidewalk,transverse,microType];

%Layout slopes and distances
landSlope = 0.02; %magnitude of land slope
roofSlope=0.20;streetSlope=landSlope;
transverseSlope = landSlope; %driveway x-slope, frontwalk x-slope
dsLength = 1.5; %downspout length [m]. Only used if downspouts=2.
sidewalkOffset = 2; %distance between sidewalk and street, [m]
details = [landSlope,roofSlope,streetSlope,transverseSlope,dsLength,sidewalkOffset];

%% 2. DOMAIN AND PROCESSOR INFO
%Unique to each lot type
if lotType == 1 %LotA (LgSub)
    xL = 0; dx = 0.5; nx = 48;
    yL = 0; dy =0.5; ny = 88;
    P = 2; Q = 4;
elseif lotType == 2 %LotB (SmUrb)
    xL = 0; dx = 0.5; nx = 27;
    yL = 0; dy =0.5; ny = 84;
    P = 1; Q = 4;
elseif lotType == 3 %LotC (SmUrb)
    xL = 0; dx = 0.5; nx = 32;
    yL = 0; dy =0.5; ny = 84;
    P = 1; Q = 4;
end
zL = 0; dz = 0.1; nz = 100;
R = 1;  %No. Z processors

%Common to all lot types
xU = xL+dx*nx;  x0 = xL+dx/2;   xf = xU-dx/2;
yU = yL+dy*ny;  y0 = yL+dy/2;   yf = yU-dy/2;
zU = zL+dz*nz;  z0 = zL+dz/2;   zf = zU-dz/2;

x = x0:dx:xf;
y = y0:dy:yf;
z = z0:dz:zf;

[X,Y] = meshgrid(x,y);
domainArea = dx*dy*nx*ny;

%% 3. CALL LAND COVER AND SLOPE FUNCTIONS
cd('J:\Research\Parflow\inputs\matlab_in\LotFcnsABC')
%Lot Layout
lotFcn = {@LotA,@LotB,@LotC};
slopeFcn = {@LotA_slopes,@LotB_slopes,@LotC_slopes};

%Land Cover
[fc,parcelCover,used] = lotFcn{lotType}(dx,dy,nx,ny,x,y,triggers,details);
%   Output Key:
%     0=turfgrass, 1=street, 2=alley, 3=parking lot, 4=sidewalk, 5=driveway
%     6=frontwalk, 7=house, 8=house2 (only neede for LgSub2), 9=garage

%Slopes
[slopeX,slopeY,elev,DScalc,sumflag] = slopeFcn{lotType}(x,nx,dx,xL,xU,y,ny,dy,yL,yU,X,Y,fc,parcelCover,triggers,details);
cd('J:\Research\Parflow\inputs\matlab_in')
% %Change Slopes
% pairs = [74,5;... %1. change sign on slopeY
%     77,6;... %2. swap slopeX and slopeY
%     76,8;... %3. change sign on slopeY
%     64,12;... %4. swap slopeX and slopeY; change sign on both
%     65,12;... %5. swap slopeX and slopeY; change sign on both
%     59,25;... %6. swap slopeX and slopeY;
%     60,25;... %7. swap slopeX and slopeY;
%     63,26;... %X-NAY 8. change sign on slopeX
%     11,11;... %9. swap slopeX and slopeY
%     11,15]; %10. swap slopeX and slopeY
% for i = 1:length(pairs)
%     %Swap slopeX and slopeY
%     if i == 2 || i == 4 || i == 5 || i == 6 || i == 7 || i == 9 || i == 10
%         tempX = slopeX(pairs(i,1),pairs(i,2));
%         tempY = slopeY(pairs(i,1),pairs(i,2));
%         slopeX(pairs(i,1),pairs(i,2)) = tempY;
%         slopeY(pairs(i,1),pairs(i,2)) = tempX;
%     end
%     if i == 1 || i == 3 || i == 4 || i == 5
%         tempY = slopeY(pairs(i,1),pairs(i,2));
%         slopeY(pairs(i,1),pairs(i,2)) = -tempY;
%     end
%     if i == 4 || i == 5
%         tempX = slopeX(pairs(i,1),pairs(i,2));
%         slopeX(pairs(i,1),pairs(i,2)) = -tempX;
%     end
% end
slopex = matrixTOpfsa(slopeX);
slopey = matrixTOpfsa(slopeY);
%% 4. INDICATOR FILES: 1 = pervious, 2 = impervious
%Allocate arrays
domTop = zeros([ny,nx]); domTop = zeros([ny,nx]); domMid1= zeros([ny,nx]); domMid2 = zeros([ny,nx]);

%Identify key areas in XY map: turfgrass, impervious surface, garage, and house 
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

%Create drv_vegm.dat using special matrixTOvegm function
for i = 1:ny
    for j = 1:nx
        vegGrid(j,i) = vegetation(i,j); 
    end
end
%Save
matrixTOvegm(saveDir,nx,ny,vegGrid);

%Create indicator file to trigger correct subsurface hydraulic properties
domainTop = matrixTOpfsa(domTop);
domainMid1 = matrixTOpfsa(domMid1);
domainMid2 = matrixTOpfsa(domMid2);

%Sidewalk, front walk, driveway only impervious for first 2 layers.
%Garage only impervious for top 30cm.
%House only impervious for top 3m.
nMid1 = round(0.3/dz);
nMid2 = round(3.0/dz);

%Allocate arrays
NaNimp = ones([ny nx nz]);
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

%% 4. SAVE LOT INPUTS
cd(saveDir)

%Parameter text file
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
fclose(fid);

% Post-processing input
% If add/remove anything here, be sure to also adjust in PFallin.m
save('domainInfo.mat','dx','dy','dz','nx','ny','nz','x','y','z','domainArea','P','Q','R',...
    'fc','parcelCover','slopeX','slopeY','NaNimp','pervX','pervY','elev','DScalc','-v7.3');

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

%% PLOT
%pcolor does not plot last row or column - have to trick it here so that
%they are displayed.
xP = [x,x(nx)+dx];
yP = [y,y(ny)+dy];
[XP,YP] = meshgrid(xP,yP);
CP = [parcelCover,parcelCover(:,nx);parcelCover(ny,:),parcelCover(ny,nx)];

%Slope magnitude
M = (slopeX.^2+slopeY.^2).^0.5;
MP = [M,M(:,nx);M(ny,:),M(ny,nx)];

%FIGURE 1: Parcel Cover, grey
figure(1)
hold on
axis equal
axis([xL-2 xU+2 yL-2 yU+2])
pcolor(XP-0.25,YP-0.25,CP);
rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
    '-','LineWidth',1.5);
set(gcf,'Colormap',mycmap)
xlabel('Distance (m)')
ylabel('Distance (m)')
hold off
savefig('GreyParcelCover.fig')

%FIGURE 2: Parcel Cover, with slopes
figure(2)
hold on
axis equal
axis([xL-2 xU+2 yL-2 yU+2])
pcolor(XP-0.25,YP-0.25,CP);
colormap(cool);
rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
    '-','LineWidth',1.5);xlabel('Distance (m)')
quiver(X,Y,-slopeX./M,-slopeY./M,'AutoScaleFactor',0.6,'Color','k','MaxHeadSize',0.6,'LineWidth',1)
ylabel('Distance (m)')
hold off
savefig('Slopes.fig')

rmpath('J:\Research\Parflow\inputs\matlab_in');