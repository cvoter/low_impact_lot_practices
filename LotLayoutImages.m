%LotLayoutImages.m

clear all; close all; clc;
set(0,'defaultTextFontSize',16,'defaultTextFontName','Gill Sans MT',...
    'defaultAxesFontSize',16,'defaultAxesFontName','Gill Sans MT')
load('greyImpMap.mat');

%Lot Basics
runname = '';
lotType = 1; % 1=LotA, 2=LotB, 3=LotC
undeveloped = 0; % 0=developed; 1=undeveloped
downspout = 1; %0=fully connected; 1=downspouts at corners; 2=no downspouts
sidewalk = 0; %0=connected sidewalk; 1=offset sidewalk
transverse = 0; %0=no transverse slope; 1=transverse slope on driveway & front walk
microType = 1; %0=no microtopography, 1=bumpy, 2=terrace
triggers = [undeveloped,downspout,sidewalk,transverse,microType];

landSlope = 0.01; %magnitude of land slope
roofSlope=landSlope;streetSlope=landSlope;
transverseSlope = 0.01; %driveway x-slope, frontwalk x-slope
microSlope = 0.015; %additional random microtopography slope (+/-)
dsLength = 1.5; %downspout length [m]. Only used if downspouts=2.
sidewalkOffset = 2; %distance between sidewalk and street, [m]
details = [landSlope,roofSlope,streetSlope,transverseSlope,microSlope,dsLength,sidewalkOffset];

%Domain
if lotType == 1 %LotA (L gSub)
    xL = 0; dx = 0.5; nx = 49;
    yL = 0; dy =0.5; ny = 88;
    P = 7; Q = 8;
elseif lotType == 2 %LotB (SmUrb)
    xL = 0; dx = 0.5; nx = 27;
    yL = 0; dy =0.5; ny = 84;
    P = 3; Q = 12;
elseif lotType == 3 %LotC (SmUrb)
    xL = 0; dx = 0.5; nx = 32;
    yL = 0; dy =0.5; ny = 84;
    P = 4; Q = 12;
end

xU = xL+dx*nx;  x0 = xL+dx/2;   xf = xU-dx/2;
yU = yL+dy*ny;  y0 = yL+dy/2;   yf = yU-dy/2;

x = x0:dx:xf;
y = y0:dy:yf;

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

%% PLOT
% %xL, xU, yL, yU for LgSub1 lot
% xL = 0;  xU = 24.5; yL = 0; yU = 44;

%Plot
figure(1)
hold on
axis equal
axis([xL-2 xU+2 yL-2 yU+2])
% for k = used
%     rectangle('Position',[fc(k,1),fc(k,3),fc(k,2)-fc(k,1),fc(k,4)-fc(k,3)],...
%         'EdgeColor','k','LineStyle','-','LineWidth',1.5,'FaceColor','k');
% end
contourf(X,Y,parcelCover,'LineColor','none')
set(gcf,'Colormap',mycmap)
rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
    '-','LineWidth',1.5);
% plot(x(6),y(41),'*','MarkerSize',12,'MarkerFaceColor',[0,0.4470,0.7410],'MarkerEdgeColor',[0,0.4470,0.7410])
% plot(x(14),y(54),'*k','MarkerSize',12)
xlabel('Distance (m)')
ylabel('Distance (m)')
title(runname)
hold off

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
% caxis([0 0.02])
xlabel('Distance (m)')
ylabel('Distance (m)')
% title('Flowlines & Slope Magnitude')
hold off
% cd(inputDir);
% savefig('Slopes.fig')