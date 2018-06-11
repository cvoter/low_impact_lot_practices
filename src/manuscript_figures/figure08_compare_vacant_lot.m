%figure08_compare_vacant_lot.m
%Carolyn Voter
%May 26, 2018

% Generates Figure 8(a-d) from paper on low impact parcel features that is
% in revision at WRR (as of June 2018). Figure 8 depicts the growing season
% 1) runoff, 2) deep drainage, 3) evapotranspiration, and 4) transpiration
% per unit vegetated area for A) the highly-compacted baseline, B) the
% lowest-impact lot, and C) the vacant lot layouts under both average and
% dry growing season conditions.

% Requires:
% 'data/model_inputs/Lot0000_SiL10c_average/domainInfo.mat'
% 'data/model_inputs/Lot0000_SiL10c_dry/domainInfo.mat'
% 'data/model_inputs/Lot1111_SiL_average/domainInfo.mat'
% 'data/model_inputs/Lot1111_SiL_dry/domainInfo.mat'
% 'data/model_inputs/VacantLot_average/domainInfo.mat'
% 'data/model_inputs/VacantLot_dry/domainInfo.mat'
%     Need domain information for the highly-compacted baseline,
%     lowest-impact lot (all 5 interventions applied), and vacant lot for
%     average and dry (2012) weather scenarios.

% 'results/selected_model_outputs/Lot0000_SiL10c/WBtotal.mat'
% 'results/selected_model_outputs/Lot0000_SiL10c_2012/WBtotal.mat'
% 'results/selected_model_outputs/Lot1111_SiL/WBtotal.mat'
% 'results/selected_model_outputs/Lot1111_SiL_2012/WBtotal.mat'
% 'results/selected_model_outputs/VacantLot/WBcum.mat'
% 'results/selected_model_outputs/VacantLot_2012/WBcum.mat'
%     Need cumulative growing season fluxes for all lots. My naming
%     convention changed between when the developed lots and vacant lots
%     were run, so unfortunately these have different filenames.

close all; clear all; clc;
set(0,'defaultTextFontSize',10,'defaultTextFontName','Segoe UI Semilight',...
    'defaultAxesFontSize',10,'defaultAxesFontName','Segoe UI Semilight')

%% DATA PATHS AND CONSTANTS
runnames = {'Lot0000_SiL10c_average','Lot1111_SiL_average','LotVacant_average',...
    'Lot0000_SiL10c_dry','Lot1111_SiL_dry','LotVacant_dry'};

%% 1. BASELINE10C - AVERAGE
for lot = 1:6
    % Run to analyze this loop
    runname = runnames{lot};
    
    % Load domain data
    load(strcat('../../data/model_inputs/',runname,'/domainInfo.mat'));
    
    %Count number of impervious vs. pervious pixels
    nImperv = sum(sum(isnan(NaNimp(:,:,100))));
    nPerv = nx*ny-nImperv;
    
    % Growing season cumulative fluxes
    if lot == 3 || lot == 6
        % Vacant lots have different naming convention. Also saved as
        % depth(mm), not volume (m^3).
        load(strcat('../../results/selected_model_outputs/',runname,'/WBcum.mat'));
        SurfaceRunoff(lot,1) = sr_cum(end);
        DeepDrainage(lot,1) = 1000*dd_cum(end);
        Evapotranspiration(lot,1) = ev_cum(end) + tr_cum(end);
        Transpiration(lot,1) = tr_cum(end);
    else
        % Other lots
        load(strcat('../../results/selected_model_outputs/',runname,'/WBtotal.mat'));
        SurfaceRunoff(lot,1) = 1000*Tsr(end)/domainArea;
        DeepDrainage(lot,1) = 1000*Tdd(end)/domainArea;
        Evapotranspiration(lot,1) = 1000*(Ttr(end)+Tev(end))/domainArea;
        Transpiration(lot,1) = 1000*Ttr(end)/(domainArea*nPerv/(nx*ny));
    end
end

%Clean up
clearvars -except runnames SurfaceRunoff DeepDrainage Evapotranspiration ...
    Transpiration

%% PLOT
% Rearrange flux matrices for bar plots
% Avg = 1-3 entries; Dry = 4-6 entries
fluxes = [SurfaceRunoff(1:3),SurfaceRunoff(4:6),DeepDrainage(1:3),...
    DeepDrainage(4:6),Evapotranspiration(1:3),Evapotranspiration(4:6),...
    Transpiration(1:3),Transpiration(4:6)]';
yaxistitles = {'Surface Runoff (mm)', 'Deep Drainage (mm)', ...
    'Evapotranspiration (mm)', 'Transpiration per unit vegetated area (mm)'};

figure(1)
for i = 1:4
    subplot(2,2,i)
    hold on
    b = bar(fluxes((2*i-1):2*i,:));
    b(1).FaceColor = [255 102 102]/255;
    b(2).FaceColor = [159 168 249]/255;
    b(3).FaceColor = [225 225 225]/255;
    set(gca,'XTick',[1:2])
    set(gca,'XTickLabel',{'Average','Dry'})
    ylabel(yaxistitles{i})
    if i == 1
        legend('Highly-Compacted Baseline','Lowest-Impact','Vacant','Orientation','horizontal')
    end
    hold off
end
set(gcf,'renderer','Painters')