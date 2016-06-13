%analyzeRET.m
%Carolyn Voter
%March 5, 2016

%Calculated FAO Penman-Monteith reference evapotranspiration based on
%hourly meteorological input data. If timestep for input data is anything
%other than 1hr, these equations are not valid - must check all eqns with
%FAO 56 (Allen et al., 2006).

%Current version developed for AWRA 2016 figures.


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
set(0,'defaultTextFontSize',20,'defaultTextFontName','Gill Sans MT',...
    'defaultAxesFontSize',20,'defaultAxesFontName','Gill Sans MT')

%% CONSTANTS
% year = cellstr(char('Y1993','Y2010','Y1985','Y2003','Y1988','Y2012'));
year = cellstr(char('Y2010','Y1993','Y1981','Y1985','Y2012','Y1988'));
name = cellstr(char('2010','1993','1981','1985','2012','1988'));
tstart =  721; %start analysis on this hour of met record; 337 = Apr 15; 721 = May 1
tend = 5160; %end analysis on this hour of met record
Jstart = 91; %Julian date for start of met record in regular years (April 1 = 91). Assume I can use this for leap years too, for these purposes
seasonET0 = cell(length(year),2); %initialize final table
stormStats = cell(length(year),7); %initialize final table

%ET0 parameters (good for Madison, WI)
elev = 265; %[m]
latitude = 43.075; %[degrees]
Lz = 90; %Longitude of the center of the local time zone [degrees west of Greenwich]
Lm = 89.384; %Longitude of the measurement site [degrees west of Greenwich]
albedo = 0.23; %albedo for green grass reference crop (FAO p.43)

%Storm parameters
minP = 1; %[mm], minimum precipitation per hour to count as "rain"
minB = 6; %[hr], minimum dry stretch to consider next rainfall a "new" storm

%% GET MET DATA
for y = 1:length(year)
    % Load met forcing data and extract relevent variables
    dir = strcat('K:\Parflow\PFinput\PrecipType\',year{y});
    cd(dir)
    met = load('nldas.1hr.clm.txt');
    P = met(:,7)/1000; %pressure Pa to kPa
    uz = (met(:,5).^2+met(:,6).^2).^0.5;%wind speed [m/s]
    wz = 10; %distance above ground at which wind speed was measured [m]
    TK = met(:,4); %tempreature [K] - need temp in both C and K
    TC = TK-273.15; %tempreature [C] - need temp in both C and K
    Rs = met(:,1)*(60*60/1e6); %incoming solar radiaton W/m^2 --> MJ/hr*m^2
    q = met(:,8); %specific humidity [kg/kg]
    %% REFERNCE ET
    i = 1;
    for t = tstart:tend
        %Time & Location Variables
        latRad = toRadians('degrees',latitude); %[radians]
        J = Jstart + floor(t/24); %Current Julian day
        dr = 1+0.033*cos(2*pi/365*J); %inverse relative distance Earth-Sun
        b = 2*pi*(J - 81)/364; %constant used in eqn for Sc
        Sc = 0.1645*sin(2*b)-0.1255*cos(b)-0.025*sin(b); %seasonal correction for solar time 
        omega = (pi/12)*(((mod(t,24)+0.5)+0.06667*(Lz-Lm)+Sc)-12); %solar time angle at midpoint of period
        omega1 = omega - pi*1/24; %solar time angle at beginning of period
        omega2 = omega + pi*1/24; %solar time angle at end of period
        sdec = 0.409*sin(2*pi*J/365-1.39); %solar declination
        omegaS = acos(-tan(latRad)*tan(sdec)); %sunset solar angle
        if omega > -omegaS && omega < omegaS
            day = 1; night = 0;
        else day = 0; night = 1;
        end
        %Air Humidity Parameters
        atmP = 101.3*((293-0.0065*elev)/293)^5.26; %atmospheric pressure [kPa]
        gamma = (0.665e-3)*atmP; %Psychrometric constant [kPa/degC]
        e0 = 0.6108*exp(17.27*TC(t)/(TC(t)+237.3)); %Saturation vapor pressure [kPa]
        delta = 4098*e0/((TC(t)+237.3)^2); %Slope of saturation vapor pressure curve [kPa/degC]
        ea = P(t)*q(t)/(0.622+q(t)); %Actual vapor pressure (from Bolton, 1980), assume sp. hum. = mixing ratio. ea has same units as P [kPa]
        %Radiation
        Ra = 12*60/pi*0.0820*dr*((omega2-omega1)*sin(latRad)*sin(sdec)+cos(latRad)*cos(sdec)*(sin(omega2)-sin(omega1))); %extraterrestrial radiation [MJ/m^2*hr]
        Rso = 0.75+(2*10^-5)*elev*Ra; %clear-sky radiation [MJ/m^2*hr]
        SBconst = (4.903e-9)/24; %Stefan-Boltzman constant [MJ/K^4*m^2*d] --> [MJ/K^4*m^2*hr]
        Rnl = SBconst*TK(t)^4*(0.34-0.14*sqrt(ea))*(1.35*Rs(t)/Rso-0.35); %net longwave radiation. Thr should be [K] here.
        Rns = (1-albedo)*Rs(t); %net shortwave radiation [MJ/m^2*hr]
        Rn = Rns - Rnl; %net radiation
        %Ground Heat
        G = 0.1*Rn*day+0.5*Rn*night;
        %Wind Speed
        u2(t,1) = uz(t)*4.87/(log(67.8*wz-5.42)); %Wind speed at 2m off ground
        %Penman-Monteith reference ET
        ET0(i,1)=(0.408*delta*(Rn-G) + gamma*(37/TK(t))*u2(t)*(e0-ea))/(delta + gamma*(1+0.34*u2(t)));
        i = i + 1;
    end
    ndays = floor(length(ET0)/24);
    dailyET0.(year{y}) = zeros([ndays,1]);
    for i = 1:length(ET0)
        d = ceil(i/24);
        dailyET0.(year{y})(d) = dailyET0.(year{y})(d) + ET0(i);
    end
    total = sum(dailyET0.(year{y}));
    seasonET0{y,1} = year(y);
    seasonET0{y,2} = total;
    clearvars -except year tstart tend Jstart elev latitude Lz Lm albedo...
        minP minB y dailyET0 seasonET0 storms stormStats met name
    
    %% STORM TYPES
    %Extract precip from met forcing file
    precip = met(:,3)*60*60; %precip [mm/s] --> [mm/hr]
    %Initialize counts
    stormCount = 0;
    durCount = 0;
    dryCount = minB;
    storms.(year{y}) = zeros([1,6]);
    for t = tstart:tend
        if precip(t) < minP %No storm
            dryCount = dryCount + 1;
        elseif dryCount >= minB %New storm
            stormCount = stormCount+1;
            durCount = 1;
            SS(stormCount,:) = [t,dryCount,durCount,precip(t),precip(t),precip(t)];
            dryCount = 0;
        elseif dryCount < minB %Same storm
            durCount = durCount + 1;
            dryCount = 0;
            SS(stormCount,3) = durCount; %storm duration [hr]
            SS(stormCount,4) = SS(stormCount,4)+precip(t); %total storm precip [mm]
            SS(stormCount,5) = SS(stormCount,4)/SS(stormCount,3); %ave. storm intensity [mm/hr]
            SS(stormCount,6) = max(SS(stormCount,6),precip(t)); %max 1hr intensity
        end
    end
    storms.(year{y}) = SS;
    stormStats{y,1} = year(y); %Year
    stormStats{y,2} = sum(precip(tstart:tend)); %total precip [mm]
    stormStats{y,3} = sum(storms.(year{y})(:,4)); %total precip counted in "storms" [mm]
    stormStats{y,4} = mean(storms.(year{y})(:,5)); %mean ave. storm intensity [mm/h]
    stormStats{y,5} = mean(storms.(year{y})(:,6)); %mean peak storm intensity [mm/h]
    stormStats{y,6} = mean(storms.(year{y})(:,3)); %mean storm duration [h]
    stormStats{y,7} = mean(storms.(year{y})(:,2)); %mean between storm duration [h]
    clearvars -except year tstart tend Jstart elev latitude Lz Lm albedo...
        minP minB y dailyET0 seasonET0 storms stormStats name
end

save('K:\Parflow\PFinput\PrecipType\precipStats.mat','stormStats','storms','seasonET0','dailyET0','year')
addpath('K:\Parflow\Matlab\postprocessing\figureFcns');
blue = [0.3569 0.6078 0.8353];
purple = [0.6667 0.5490 0.7725];
green = [0.5216 0.7333 0.3961];
yellow = [1.0000  0.7529 0];
red = [0.6471 0 0.1294];
orange = [0.9294 0.4902 0.1922];
for i = 1:length(year)
    totalP(i,1) = stormStats{i,3};
end
%% PLOT ALL
%Precip
fig = figure('Position',[300 300 1280 580]);
hold on
axis([0 7 0 800])
for i = 1:length(year)
    H = totalP(i,1);
    h = bar(i,H);
    if i == 1;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',purple)
    elseif i == 2;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',blue)
    elseif i == 3;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',green)
    elseif i == 4;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',yellow)
    elseif i == 5;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',orange)
    elseif i == 6;
        set(h,'lineWidth',1.5,'barWidth',0.5,'FaceColor',red)
    end
end
set(gca,'XTick',[1:1:6],'XTickLabel',name)
ylabel('Total Precipitation (mm)')
hold off

%Precip vs. ET0
fig = figure('Position',[300 300 1280 580]);
hold on
axis('equal')
axis([100 800 100 800])
plot(seasonET0{1,2},stormStats{1,3},'MarkerFaceColor',purple,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(seasonET0{2,2},stormStats{2,3},'MarkerFaceColor',blue,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(seasonET0{4,2},stormStats{4,3},'MarkerFaceColor',yellow,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(seasonET0{3,2},stormStats{3,3},'MarkerFaceColor',green,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(seasonET0{5,2},stormStats{5,3},'MarkerFaceColor',orange,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(seasonET0{6,2},stormStats{6,3},'MarkerFaceColor',red,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot([200,1000],[200,1000],'--k')
ylabel('Total Precipitation (mm)')
xlabel('Total Reference ET (mm)')
hold off

%Precip vs. intensity
fig = figure('Position',[300 300 1280 580]);
subplot(1,3,1)
hold on
axis([100 800 2 4])
axis square
plot(stormStats{1,3},stormStats{1,4},'MarkerFaceColor',purple,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{2,3},stormStats{2,4},'MarkerFaceColor',blue,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{3,3},stormStats{3,4},'MarkerFaceColor',green,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{4,3},stormStats{4,4},'MarkerFaceColor',yellow,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{5,3},stormStats{5,4},'MarkerFaceColor',orange,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{6,3},stormStats{6,4},'MarkerFaceColor',red,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
ylabel('Intensity (mm/hr)')
hold off
%Precip vs. storm duration
% fig = figure('Position',[300 300 1280 580]);
subplot(1,3,2)
hold on
axis([100 800 1 5])
axis square
plot(stormStats{1,3},stormStats{1,6},'MarkerFaceColor',purple,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{2,3},stormStats{2,6},'MarkerFaceColor',blue,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{3,3},stormStats{3,6},'MarkerFaceColor',green,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{4,3},stormStats{4,6},'MarkerFaceColor',yellow,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{5,3},stormStats{5,6},'MarkerFaceColor',orange,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{6,3},stormStats{6,6},'MarkerFaceColor',red,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
xlabel('Total Precipitation (mm)')
ylabel('Duration (hr)')
set(gca,'YTick',[1:1:5])
hold off
%Precip vs. interstorm duration
% fig = figure('Position',[300 300 1280 580]);
subplot(1,3,3)
hold on
axis square
axis([100 800 2 7])
plot(stormStats{1,3},stormStats{1,7}/24,'MarkerFaceColor',purple,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{2,3},stormStats{2,7}/24,'MarkerFaceColor',blue,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{3,3},stormStats{3,7}/24,'MarkerFaceColor',green,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{4,3},stormStats{4,7}/24,'MarkerFaceColor',yellow,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{5,3},stormStats{5,7}/24,'MarkerFaceColor',orange,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
plot(stormStats{6,3},stormStats{6,7}/24,'MarkerFaceColor',red,'Marker','o','MarkerSize',14,'MarkerEdgeColor','none','MarkerEdgeColor','k','LineWidth',1.5)
ylabel('Interstorm Duration (days)')
hold off