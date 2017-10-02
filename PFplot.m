%PFplot.m
%Carolyn Voter
%March 6, 2017

clear all; close all; clc;
set(0,'defaultTextFontSize',24,'defaultTextFontName','Segoe UI Semilight',...
    'defaultAxesFontSize',18,'defaultAxesFontName','Segoe UI Semilight')
%COLORMAP: ALL GREY
% load('J:\Research\Subprojects\ResidentialLayouts\Madison\scripts\simpleColormap.mat'); %3 tone
load('twoToneGrey.mat'); %2 tone
% load('greyImpMap.mat'); %1 tone

%COLORMAP: RED HIGHLIGHT
% load('RedSidewalk.mat');
% load('RedFrontwalk.mat');
% load('RedDriveway.mat');
% load('RedGarage.mat');
% load('RedHouse.mat');

%% DEFINE MODELS
modelDir = 'K:\Parflow\PFinput\LotType';
% 
% prefix = 'AWRA';
% TIA = 15:5:50;
% rcount = 1;
% for i = 1:length(TIA)
%     allRunnames{rcount} = sprintf('%s_%dS',prefix,TIA(i));
%     allTitlenames{rcount} = sprintf('%dS',TIA(i));
%     rcount = rcount + 1;
%     allRunnames{rcount} = sprintf('%s_%dL',prefix,TIA(i));
%     allTitlenames{rcount} = sprintf('%dL',TIA(i));
%     rcount = rcount + 1;
% end

%% IMPORT DATA
% for r = 6;%1:length(allRunnames)
    runname = 'Lot1111'; %allRunnames{r};
    load(strcat(modelDir,'\',runname,'\domainInfo.mat'))
    xL = 0; xU = xL+dx*nx; 
    yL = 0; yU = yL+dy*ny;
    
    %Remove downspouts from impervious cover
    for i = 1:ny
        if (y(i) > fc(4,4)) && (y(i) < (fc(8,4)+4*dy))
            for j = 1:nx
                if parcelCover(i,j) == 4
                    parcelCover(i,j) = 0;
                end
            end
        end
    end
    
    %% PLOT
    %pcolor does not plot last row or column - have to trick it here so that
    %they are displayed.
    xP = [x,x(nx)+dx];
    yP = [y,y(ny)+dy];
    [XP,YP] = meshgrid(xP,yP);
    CP = [parcelCover,parcelCover(:,nx);parcelCover(ny,:),parcelCover(ny,nx)];
    elevNaN = elev.*NaNimp(:,:,100);
    EP = [elevNaN,elevNaN(:,nx);elevNaN(ny,:),elevNaN(ny,nx)];
    
    %Slope magnitude
    M = (slopeX.^2+slopeY.^2).^0.5;
    MP = [M,M(:,nx);M(ny,:),M(ny,nx)];
    
    %FIGURE 1: Parcel Cover, grey
    figure(1)
    ax1 = subplot(1,2,1);
    hold on
    axis equal
%     axis([-2 26.5 -2 52])
    axis([xL-2 xU+2 yL-2 yU+2])
    pcolor(XP-0.25,YP-0.25,CP);
    shading flat
    rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
        '-','LineWidth',1.5);
    colormap(ax1,mycmap)
%     set(ax1,'Colormap',mycmap)
    xlabel('Distance (m)')
    ylabel('Distance (m)')
    hold off
    
    ax2 = subplot(1,2,2);
    hold on
    axis equal
%     axis([-2 26.5 -2 52])
    axis([xL-2 xU+2 yL-2 yU+2])
    pcolor(XP-0.25,YP-0.25,EP);
    shading flat
    rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
        '-','LineWidth',1.5);
    colormap(ax2,jet)
    c = colorbar; ylabel(c,'Elevation (m)');
    xlabel('Distance (m)')
    ylabel('Distance (m)')
    hold off
% end
