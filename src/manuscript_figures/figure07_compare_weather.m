%figure07_compare_weather.m
%Carolyn Voter
%May 26, 2018

% Generates Figure 7(a-d) from paper on low impact parcel features that is in
% revision at WRR (as of June 2018). Maps total growing season deep
% drainage and evapotranspiration spatially on the parcel for both average
% and dry weather scenarios.

% Requires:
% 'data/model_inputs/Lot1111_SiL_average/domainInfo'
% 'data/model_inputs/Lot1111_SiL_dry/domainInfo'
%     Need domain information for the lowest-impact lot (all 5
%     interventions applied) for average and dry (2012) weather scenarios.

% 'results/Lot1111_SiL_average'
% 'results/Lot1111_SiL_dry'
%     Need cumulative spatial deep drainage, evaporation, and transpiration
%     data for the lowest-impact lot (all 5 interventions applied) for
%     average and dry (2012) weather scenarios

% 'data/colormaps/map_ylgrbu.mat'
%      colorblind-friendly colormap for heatmaps.

close all; clear all; clc;
set(0,'defaultTextFontSize',20,'defaultTextFontName','Segoe UI Semilight',...
    'defaultAxesFontSize',20,'defaultAxesFontName','Segoe UI Semilight')

%% DATA PATHS AND CONSTANTS
% Lowest-impact lot (all 5 interventions) for average and dry (2012) weather
runnames = {'Lot1111_SiL_average','Lot1111_SiL_dry'};

% Load colormap for heat maps
load('../../data/colormaps/map_ylgrbu.mat');

%% PLOT
figure(1)
for run = 1:2
    % Run to analyze this loop
    runname = runnames{run};
    
    % Domain Info (all lengths in meters)
    load(strcat('../../data/model_inputs/',runname,'/domainInfo.mat'));
    cellArea = dx*dy;
    [Xy,Yx] = meshgrid(x,y);
    xL = x(1); xU = x(length(x));
    yL = y(1); yU =y(length(y));
    
    % Deep Drainage for plotting
    % mask imperv. surfaces (with NaNs); convert volume (m^3) to depth (mm)
    load(strcat('../../results/',runname,'/deep_drainage.grid.cum.mat')); deep_drainage = dataS; clear dataS;
    ddTOplot = 1000*(deep_drainage/cellArea).*NaNimp(:,:,nz);
    
    % Evapotranspiration for plotting
    % mask imperv. surfaces (with NaNs); convert volume (m^3) to depth (mm)
    load(strcat('../../results/',runname,'/evaporation.grid.cum.mat')); evaporation = dataS; clear dataS;
    load(strcat('../../results/',runname,'/transpiration.grid.cum.mat')); transpiration = dataS; clear dataS;
    etTOplot = 1000*((evaporation+transpiration)/cellArea).*NaNimp(:,:,nz);
        
    %Plot Deep Drainage
    clim = [0,1600];
    subplot(2,2,run)
    hold on
    pcolor(Xy,Yx,ddTOplot)
    shading flat
    rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
        '-','LineWidth',1.5);
    set(gcf,'Colormap',mycmap)
    caxis(clim)
    if run == 2 % only place color bar on right-most plots
        hcb = colorbar;
        ylabel(hcb,'Deep Drainage (mm)','FontSize',11);
    end
    xlabel('Distance (m)'); 
    ylabel('Distance (m)');
    axis equal
    axis([xL-2 xU+2 yL-2 yU+2])
    hold off
    
    %Plot Evapotranspiration
    clim = [450,650];
    subplot(2,2,run+2)
    hold on
    pcolor(Xy,Yx,etTOplot)
    shading flat
    rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
        '-','LineWidth',1.5);
    set(gcf,'Colormap',mycmap)
    caxis(clim)
    if run == 2 % only place color bar on right-most plots
        hcb = colorbar;
        ylabel(hcb,'Evapotranspiration (mm)','FontSize',11);
    end
    xlabel('Distance (m)'); ylabel('Distance (m)');
    axis equal
    axis([xL-2 xU+2 yL-2 yU+2])
    hold off
end
set(gcf,'renderer','Painters')