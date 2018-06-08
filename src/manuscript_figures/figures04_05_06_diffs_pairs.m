%figures04_05_06_diffs_pairs.m
%Carolyn Voter
%May 26, 2018

% Generates data behind Figures 4 and 5 from paper on low impact parcel
% features that is in revision at WRR (as of June 2018). Figures 4 and 5
% show differences in growing season fluxes (runoff, deep drainage, et)
% under average and dry weather scenarios as a percent of precipitation and
% as a depth (mm) compared to the baseline scenario. Fig. 4 compares to a
% highly-compacted baseline; Fig. 5 compares to a moderately-compacted
% baseline.

% Also generates Figure 6(a-b), which shows the synergistic effects of combining
% low impact interventions (where present) for both the highly-compacted
% baseline and moderately-compacted baseline. Icons are added to the x-axis
% in Adobe Illustrator (post-matlab script) based on the pair order defined
% in this script.

% Requires:
% 'results/selected_model_outputs/finalWB10c.mat'
%     Contains the total growing season flux (mm depth) for
%     highly-compacted baseline 
%     row numbers indicate model scenario 
%     column 1: precipitation 
%     column 2: surface runoff 
%     column 3: deep drainage
%     column 4: evapotranspiration 
%     column 5: root zone subsurface storage

% 'results/selected_model_outputs/finalWB2c.mat'
%     Same as 'finalWB10c.mat', but for moderately-compacted baseline

% 'results/selected_model_outputs/layoutMatrix.mat'
%     1 = low-impact feature applied, 0 = baseline conditions
%     row numbers indicate model scenario (same as the finalWB matrices)
%     column 1: downspout disconnect
%     column 2: sidewalk disconnect
%     column 3: transverse slope
%     column 4: microtopography
%     column 5: soil uncompacted

close all; clear all; clc;
set(0,'defaultTextFontSize',10,'defaultTextFontName','Segoe UI Semilight',...
    'defaultAxesFontSize',10,'defaultAxesFontName','Segoe UI Semilight')

%% LOOP OVER BASELINE SCENARIOS
finalWBfile = {'finalWB10c.mat','finalWB2c.mat'};
plottitle = {'Highly-Compacted Baseline','Moderately-Compacted Baseline'};

for basetype = 1:2
    % Load data
    load(strcat('../../results/selected_model_outputs/',finalWBfile{basetype}))
    load('../../results/selected_model_outputs/layoutMatrix.mat');
    
    %% CHANGE IN GROWING SEASON FLUXES COMPARED TO BASELINE (Figs. 4 and 5)
    % Loop through lot layouts, calculate difference relative to baseline
    nruns = length(layoutMatrix);
    for i = 1:nruns
        %Average weather (listed first in finalWB), difference as depth (mm)
        depth1981(i,1) = finalWB(i,2)-finalWB(1,2); % col 1: runoff
        depth1981(i,2) = finalWB(i,3)-finalWB(1,3); % col 2: deep drainage
        depth1981(i,3) = finalWB(i,4)-finalWB(1,4); % col 3: et
        %Dry weather (listed second in finalWB), difference as depth (mm)
        depth2012(i,1) = finalWB(i+nruns,2)-finalWB(1+nruns,2); % col 1: runoff
        depth2012(i,2) = finalWB(i+nruns,3)-finalWB(1+nruns,3); % col 2: deep drainage
        depth2012(i,3) = finalWB(i+nruns,4)-finalWB(1+nruns,4); % col 3: et
    end
    %Differences as percent of total precip (%)
    prct1981 = 100*depth1981./finalWB(1,1);
    prct2012 = 100*depth2012./finalWB(1+nruns,1);
    
    % Sort model scenarios. At same time, merge weather scenarios
    [~,order] = sort(abs(prct1981(:,1)),'ascend'); % sort by change in runoff, avg year
    layoutOrdered = layoutMatrix(order,:);
    prctOrdered = [prct1981(order,:),prct2012(order,:)]; % col 1-3: avg, col 4-6: dry
    depthOrdered = [depth1981(order,:),depth2012(order,:)]; % col 1-3: avg, col 4-6: dry
    
    % Organize data for master figureMatrix (figures 4 and 5)
    for i = 1:nruns
        % figureMatrix columns 1-5: indicate layout scenario
        for j = 1:5
            figureMatrix{i,j,basetype} = layoutOrdered(i,j);
        end
        % figureMatrix columns 6-11: string w/ change in flux as both a % and depth (mm)
        %    6: runoff, average
        %    7: deep drainge, average
        %    8: et, average
        %    9: runoff, dry
        %    10: deep drainage, dry
        %    11: et, dry
        for j = 1:6
            figureMatrix{i,j+5,basetype} = sprintf('%d%%(%0.1fmm)',round(prctOrdered(i,j)),depthOrdered(i,j));
        end
    end
    
    %% COMPARE PAIRS OF INTERVENTIONS (Fig. 6)
    % layoutMatrix individual inventions:
    %   row 2: disconnected downspout
    %   row 3: disconnected sidewalk
    %   row 4: transverse slope
    %   row 5: microtopography
    %   row 6: uncompacted soil
    % layoutMatrix pairs:
    %   rows 7 through 16
    
    % Pick flux to compare
    flux = 1; % 1=runoff, 2=deep drainage, 3=et
    
    % Loop through pairs
    for row = 7:16
        % Get state of low-impact features
        d = layoutMatrix(row,1); % state of disconnected downspout
        s = layoutMatrix(row,2); % state of disconnected sidewalk
        t = layoutMatrix(row,3); % state of transverse slope
        m = layoutMatrix(row,4); % state of microtopography
        st = layoutMatrix(row,5); % state of uncompacted soil
        
        % Actual change observed in pair
        pairs1981(row-6,1) = depth1981(row,flux);
        pairs2012(row-6,1) = depth2012(row,flux);

        % Sum of individual changes
        % Columns of sumYYYY represent interventions (1=yes,0=no)
        %   col 1: uncompacted soil
        %   col 2: disconnected downspout
        %   col 3: disconnected sidewalk
        %   col 4: transverse slope
        %   col 5: microtopography
        sum1981(row-6,:) = [st*depth1981(6,flux),d*depth1981(2,flux),s*depth1981(3,flux),t*depth1981(4,flux),...
            m*depth1981(5,flux)];
        sum2012(row-6,:) = [st*depth2012(6,flux),d*depth2012(2,flux),s*depth2012(3,flux),t*depth2012(4,flux),...
            m*depth2012(5,flux)];
    end
    % Calculate synergistic effect
    % aka, the difference between actual change and sum of indiv. changes
    diff1981 = pairs1981-sum(sum1981,2); 
    diff2012 = pairs2012-sum(sum2012,2);
    
    % For bar plot purposes, remove "positive" reductions in runoff 
    diff1981(diff1981>0) = 0;
    diff2012(diff2012>0) = 0;
    
    %% PLOT
    % Plot pairs on x-axis from largest change (left) to smallest (right) 
    [~,barorder] = sort(abs(pairs1981(:,1)),'descend');
    
    % Add column of "synergistic effect" to sumYYYY matrices
    plot1981 = [sum1981,diff1981];
    plot2012 = [sum2012,diff2012];
    
    figure(basetype)
    b = bar(-plot1981(barorder,:),'stacked','EdgeColor','None');
    hold on
    axis([0 11 0 110]);
    b(1).FaceColor = [255 255 157]/255; % uncompacted soil
    b(2).FaceColor = [190 235 159]/255; % disconnected downspout
    b(3).FaceColor = [121 189 143]/255; % disconnected sidewalk
    b(4).FaceColor = [0 163 136]/255; % transverse slope
    b(5).FaceColor = [0 105 136]/255; % microtopography
    b(6).FaceColor = [255 97 56]/255; % synergistic effect
    set(gca,'YTick',0:20:100)
    set(gca,'YTickLabel',{'0','-20','-40','-60','-80','-100'})
    legend(fliplr(b),{'Synergistic Effect','Microtopography','Transverse Slope','Disconnected Sidewalk','Disconnected Downspout','Uncompacted Soil'})
    ylabel('\Delta Surface Runoff (mm)')
    title(plottitle{basetype})
    hold off
    set(gcf,'renderer','Painters')
end