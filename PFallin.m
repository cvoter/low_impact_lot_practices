% function [] = PFallin(locname,soilname,lotname,metyear,starttype,runname)
%PFallin.m
%Carolyn Voter
%October 21, 2016

%REQUIRED INPUTS:
% locname = lot loctaion, e.g. loc01 or loc51
% soilname = soil type code, SiL,SiL2c,SiL10c,LSa,LSa2c,LSa10c
% lotname = lot layout type, e.g. LotB_08, LotB_02
% metyear = time for meteorological forcing, e.g. WY14,SP81,SP14
% starttype = for correct spinup, either wy or sp
% runname = name for model. For paper 2, maybe: strcat(locname,soilname,'B')

%WHAT THIS SCRIPT DOES:
% 1. LOT INFO. Specify information about the lot location, soil type, lot
%    layout, meteorologic forcing, and desired runname
% 2. DEFINE DIRS AND FILENAMES BASED ON INPUTS. Uses info specified in
%    first step to identify location of key files and directories.
% 3. COPY EXISTING STUFF INTO INPUT DIR. Consolidates existing input files
%    about lot layout and meterological forcing.
% 4. EXTEND PARAMETER INFO. Add information about soil type to
%    parameters.txt and domainInfo.mat
% 5. INITIAL PRESSURE. Create *.sa file for initial pressure.

clear all; close all; clc;
set(0,'defaultTextFontSize',12,'defaultTextFontName','Gill Sans MT',...
    'defaultAxesFontSize',12,'defaultAxesFontName','Gill Sans MT')

%% 1. LOT INFO
%Note units specified below. Unless otherwise noted, L[=]m, T[=]hr
locname = 'loc51';
soilname = 'SiL10c';
lotname = 'LotB_08';
metyear = 'WY14';
starttype = 'wy';
runname = strcat(locname,soilname,'B');

%% 2. DEFINE DIRS AND FILENAMES BASED ON INPUTS
inDir = strcat('K:\Parflow\PFinput\ModelIn\',runname); mkdir(inDir);
lotDir = strcat('K:\Parflow\PFinput\LotType\',lotname);
metDir = strcat('K:\Parflow\PFinput\PrecipType\',metyear);
metFile = strcat(metDir,'\',locname,'\nldas.1hr.clm.txt');
soilFile = strcat('K:\Parflow\PFinput\SoilType\',soilname,'.mat');
cd(inDir)

%% 3. COPY EXISTING STUFF INTO INPUT DIR
copyfile(lotDir,inDir);
copyfile(metFile,inDir);
copyfile(strcat(metDir,'\',locname,'\precip.mat'),inDir);
copyfile(strcat(metDir,'\drv_clmin.dat'),inDir);
copyfile(strcat(metDir,'\drv_clmin_restart.dat'),inDir);
copyfile(strcat(metDir,'\drv_vegp.dat'),inDir);

%% 4. EXTEND PARAMETER INFO
%domainInfo includes:
%dx,dy,dz,nx,ny,nz,x,y,z,domainArea,P,Q,R,NaNimp,pervX,pervY
load('domainInfo.mat')

%soilInfo includes:
load(soilFile)
load('K:\Parflow\PFinput\SoilType\imperv.mat')

%resave domainInfo
save('domainInfo.mat','dx','dy','dz','nx','ny','nz','x','y','z','domainArea',...
    'Ks_soil','porosity_soil','VGa_soil','VGn_soil','Sres_soil','Ssat_soil','mn_grass',...
    'Ks_imperv','porosity_imperv','VGa_imperv','VGn_imperv','Sres_imperv','Ssat_imperv','mn_imperv',...
    'P','Q','R','fc','parcelCover','slopeX','slopeY','NaNimp','pervX','pervY','-v7.3');

%add to parameters.txt
%Parameter text file
fid = fopen('parameters.txt','a');
% fprintf(fid,'%.2f\n',xL); %1 0.00
% fprintf(fid,'%.2f\n',yL); %2 0.00
% fprintf(fid,'%.2f\n',zL); %3 0.00
% fprintf(fid,'%.0f\n',nx); %4 integer
% fprintf(fid,'%.0f\n',ny); %5 integer
% fprintf(fid,'%.0f\n',nz); %6 integer
% fprintf(fid,'%.2f\n',dx); %7 0.00
% fprintf(fid,'%.2f\n',dy); %8 0.00
% fprintf(fid,'%.2f\n',dz); %9 0.00
% fprintf(fid,'%.2f\n',xU); %10 0.00
% fprintf(fid,'%.2f\n',yU); %11 0.00
% fprintf(fid,'%.2f\n',zU); %12 0.00
% fprintf(fid,'%.0f\n',P); %13 integer
% fprintf(fid,'%.0f\n',Q); %14 integer
% fprintf(fid,'%.0f\n',R); %15 integer
fprintf(fid,'%.4e\n',Ks_soil); %16 0.0000E0
fprintf(fid,'%.4e\n',mn_grass); %17 0.0000E0
fprintf(fid,'%.2f\n',VGa_soil); %18 0.00
fprintf(fid,'%.2f\n',VGn_soil); %19 0.00
fprintf(fid,'%.2f\n',porosity_soil); %20 0.00
fprintf(fid,'%.2f\n',Ssat_soil); %21 0.00
fprintf(fid,'%.2f\n',Sres_soil); %22 0.00
fprintf(fid,'%.4e\n',Ks_imperv); %23 0.0000E0
fprintf(fid,'%.4e\n',mn_imperv); %24 0.0000E0
fprintf(fid,'%.2f\n',VGa_imperv); %25 0.00
fprintf(fid,'%.2f\n',VGn_imperv); %26 0.00
fprintf(fid,'%.3f\n',porosity_imperv); %27 0.000
fprintf(fid,'%.2f\n',Ssat_imperv); %28 0.00
fprintf(fid,'%.2f\n',Sres_imperv); %29 0.00
fclose(fid);

%% 5. INITIAL PRESSURE
%Spinup mat file includes: recordWY,colWY,maxWY,pWY,sWY,pWY30,sWY30,wyIC (sub SP for WY for spring start)
load(strcat('K:\Parflow\PFinput\SpinupType\',locname,soilname,'_',starttype,'.mat'));
ICp = eval(strcat(starttype,'IC'));
%Create matrix for *.sa file
initialP = zeros(nx*ny*nz,1);
for i = 1:nz
    startI = (i-1)*nx*ny+1;
    endI = i*nx*ny;
    initialP(startI:endI) = ICp(i);   
end
%Save as *.sa file
fid = fopen('ICpressure.sa','a');
fprintf(fid,'%d% 4d% 2d\n',[nx ny nz]);
fprintf(fid,'% 16.7e\n',initialP(:));
fclose(fid);

% end