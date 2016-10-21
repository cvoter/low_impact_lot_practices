%metTOprecip.m
%Carolyn Voter
%April 22,2014
%Major modifications October 21, 2016

%Takes CLM met forcing file and extracts precipitation column for water
%balance calculations. Necessary step, given my fortran/tcl script skills.

%In CLM met forcing file, precip is in kg/m^2/s
%Change precip to m/hr to match ParFlow units

%ASSUMES:
%CLM met forcing file arranged as follows:
% met = load('nldas.1hr.clm.txt');
% DSWR = met(:,1); %W/m^2
% DLWR = met(:,2); %W/m^2
% APCP = met(:,3); %mm/s
% Temp = met(:,4); %K
% UGRD = met(:,5); %m/s
% VGRD = met(:,6); %m/s
% Press = met(:,7); %pa
% SPFH = met(:,8); %kg/kg

clear all; close all; clc;

%% GET PRECIP.MAT
for i=1:51
    loc = sprintf('loc%02d',i);
    dir = strcat('K:\Parflow\PFinput\PrecipType\SP81\',loc);
    cd(dir)
    met = load('nldas.1hr.clm.txt'); %initial units [mm/s]
    precip(:,1) = met(:,3)/1000; %convert to [m/s]
    precip = precip*3600;   %multiply by 3600s/hr, convert to [m/hr]
    save('precip','precip')
end