%metTOprecip.m
%Carolyn Voter
%April 22,2014

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
% Load CLM met forcing file and extract precip (m/hr)
% dir = 'K:\Parflow\PFinput\PrecipType\Y1985';
% dir = 'K:\Parflow\PFinput\PrecipType\Y1988';
% dir = 'K:\Parflow\PFinput\PrecipType\Y1993';
% dir = 'K:\Parflow\PFinput\PrecipType\Y2000';
% dir = 'K:\Parflow\PFinput\PrecipType\Y2001';
% dir = 'K:\Parflow\PFinput\PrecipType\Y2003';
% dir = 'K:\Parflow\PFinput\PrecipType\Y2010';
dir = 'K:\Parflow\PFinput\PrecipType\Y2012';
cd(dir)
met = load('nldas.1hr.clm.txt'); %initial units [mm/s]
precip(:,1) = met(:,3)/1000; %convert to [m/s]
precip = precip*3600;   %multiply by 3600s/hr, convert to [m/hr]
save('precip','precip')

%Plot precip (m/hr)
% figure(1)
% plot(precip)

% figure(2)
% hold on
% plot(DSWR,':r')
% plot(DLWR,'-r')
% plot(APCP,'-b')
% plot(Temp,'-m')
% plot(UGRD,'-c')
% plot(VGRD,':c')
% plot(Press,'-g')
% plot(SPFH,'-k')
% xlabel('Hour')
% ylabel('Value')
% legend('Srad','Lrad','Precip','Temp','WindU','WindV','Press','Humidity')
% hold off

%% GET DRUN.TXT
% %Flag all hours with precip above threshold
% for i=1:length(precip)
%     if precip(i)>0.005
%         dflag(i,1)=1;
%     else dflag(i,1)=0;
%     end
% end
% 
% %Translate flags into durations of rain/no rain
% duration = 1;
% count=1;
% for i=1:length(dflag)-1
%     if dflag(i+1) == dflag(i)
%         duration=duration+1;
%     else drun(count,1)=duration;
%         duration=1;
%         count=count+1;
%     end
% end
% 
% %Write to text file
% for i=1:length(drun)
%     fid = fopen('drun.txt','a');
%     fprintf(fid,'%.0f\n',drun(i));
% end
% fclose(fid);