%copy_model_output.m
%Carolyn Voter
%June 13, 2018

% This script copies WBstep.mat and WBtotal.mat for each model run from
% original storage location to current git repository. All fluxes are saved
% as volumes (m^3) for developed lot models. WBstep contains hourly fluxes;
% WBtotal contains running cumulative fluxes.

clear all; close all; clc;

%% DIRECTORIES AND FILENAMES
inDir = 'K:/Parflow/PFoutput/2017.02_LotLayouts';
saveDir = 'J:/git_research/dissertation/ch01_low_impact_lot_practices/results';

% Generate names of lot models
rcount = 1;
for downspout = 0:1  % 0=fully connected; 1=downspouts at corners
    for sidewalk = 0:1  % 0=connected sidewalk; 1=offset sidewalk
        for transverse = 0:1  % 0=no transverse slope, 1=transverse slope on driveway & front walk
            for microType = 0:1  % 0=no microtopography, 1=microtopography
                for soilname = {'SiL','Sil2c','SiL10c'}
                    for weathername = {'average','dry'} % weather scenario
                        if strcmp(weathername{1},'dry') == 1
                            oldweathername = '_2012';
                        else
                            oldweathername = '';
                        end
                        oldRunnames{rcount} = sprintf('Lot%d%d%d%d_%s%s',...
                            downspout,sidewalk,transverse,microType,...
                            soilname{1},oldweathername);
                        newRunnames{rcount} = sprintf('Lot%d%d%d%d_%s_%s',...
                            downspout,sidewalk,transverse,microType,...
                            soilname{1},weathername{1});
                        rcount = rcount + 1;
                    end
                end
            end
        end
    end
end

%% EXTRACT AND RESAVE HOURLY FLUXES
for i = 1:length(oldRunnames)
    % Define old and new run directories
    oldRunDir = strcat(inDir,'/',oldRunnames{i});
    newRunDir = strcat(saveDir,'/',newRunnames{i});
    mkdir(newRunDir)
    
    % Copy water balance .mat files to new run directory
    copyfile(strcat(oldRunDir,'/WBstep.mat'),newRunDir,'f')
    copyfile(strcat(oldRunDir,'/WBtotal.mat'),newRunDir)
    
    clearvars -except inDir saveDir oldRunnames newRunnames i
end



