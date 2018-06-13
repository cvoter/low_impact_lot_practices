%assess_model_errors.m
%Carolyn Voter
%June 13, 2018

% This script loads running cumulative fluxes (m^3) for each lot model and
% extracts the final cumulative absolute error (mm) and relative error (-).

% "Error" here is the difference between model forcing (precipitation) and
% all other fluxes (outflows + change in storage). Relative error is
% calculcated relative to model forcing (precipitation).

clear all; close all; clc;

%% DEFINE RUNNAMES
% Generate names of lot models
rcount = 1;
for downspout = 0:1  % 0=fully connected; 1=downspouts at corners
    for sidewalk = 0:1  % 0=connected sidewalk; 1=offset sidewalk
        for transverse = 0:1  % 0=no transverse slope, 1=transverse slope on driveway & front walk
            for microType = 0:1  % 0=no microtopography, 1=microtopography
                for soilname = {'SiL','Sil2c','SiL10c'}
                    for weathername = {'average','dry'} % weather scenario
                        runnames{rcount} = sprintf('Lot%d%d%d%d_%s_%s',...
                            downspout,sidewalk,transverse,microType,...
                            soilname{1},weathername{1});
                        rcount = rcount + 1;
                    end
                end
            end
        end
    end
end

%% EXTRACT MODEL ERRORS
% Load cumulative fluxes for each developed model, extract final errors
for i = 1:length(runnames)
    load(sprintf('../../results/%s/WBtotal.mat',runnames{i}))
    finalModelErrors{i,1} = runnames{i}; % col 1: runname
    finalModelErrors{i,2} = 1000*TabsErrO(end)/domainArea; % col 2: final abs err (mm)
    finalModelErrors{i,3} = 1000*TrelErrO(end)/domainArea; % col 3: final rel err (-)
end

% Load cumulative fluxes for each vacant lot model, extract final errors
% These models were run later, with different naming conventions, and with
% fluxes saved as depths (mm) rather than volumes (m^3)
for weathername = {'average','dry'}
    runname = sprintf('LotVacant_%s',weathername{1});
    load(sprintf('../../results/%s/WBcum.mat',runname))
    finalModelErrors{end+1,1} = runname; % col 1: runname
    finalModelErrors{end,2} = absErr_cum(end); % col 2: final abs err (mm)
    finalModelErrors{end,3} = relErr_cum(end); % col 3: final rel err (-)
end

%% PLOT MODEL ERRORS
figure(1)
for i = 1:length(finalModelErrors)
    loglog(abs(finalModelErrors{i,3}),abs(finalModelErrors{i,2}),'ok',...
        'MarkerSize',10,'MarkerFaceColor',[242, 27, 60]/255,...
        'MarkerEdgeColor','none')
    hold on
end
plot([1e-5,1e-1],[1,1],':k')
txt1='Abs Err = 1mm \downarrow';
text(1.3e-4,1.3,txt1)
plot([1e-2,1e-2],[1e-3,1e1],':k')
txt2='\leftarrow Rel Err = 1%';
text(1e-2,6e-1,txt2)
xlabel('Relative Error (-)')
ylabel('Absolute Error (mm)')
title('Cumulative error at last time step')
hold off