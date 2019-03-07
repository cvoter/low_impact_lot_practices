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
set(0,'defaultTextFontSize',24,'defaultTextFontName','Segoe UI Semilight',...
    'defaultAxesFontSize',24,'defaultAxesFontName','Segoe UI Semilight')

%% DATA PATHS AND CONSTANTS
% Lowest-impact lot (all 5 interventions) for average and dry (2012) weather
runnames = {'Lot1000_SiL10c_average','Lot0100_SiL10c_average','Lot0010_SiL10c_average',...
    'Lot0001_SiL10c_average','Lot0000_SiL_average'};

% Load colormap for heat maps
load('../../data/colormaps/map_ylgrbu.mat');

% Baseline deep drainage
load(strcat('../../results/','Lot0000_SiL10c_average','/deep_drainage.grid.cum.mat')); 
deep_drainage_baseline = dataS; clear dataS;
%% PLOT
for run = 1:5
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
    ddTOplot = 1000*((deep_drainage-deep_drainage_baseline)/cellArea).*NaNimp(:,:,nz);
    
    %Plot Deep Drainage
    clim = [0,120];
    figure(run)
    hold on
    pcolor(Xy,Yx,ddTOplot)
    shading flat
    rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
        '-','LineWidth',1.5);
    set(gcf,'Colormap',mycmap)
    caxis(clim)
    hcb = colorbar;
    ylabel(hcb,'\DeltaDeep Drainage (mm)','FontSize',24,'FontName','Segoe UI Semibold');
%     xlabel('Distance (m)');
%     ylabel('Distance (m)');
    axis equal
    axis([xL-2 xU+2 yL-2 yU+2])
    hold off
end
set(gcf,'renderer','Painters')