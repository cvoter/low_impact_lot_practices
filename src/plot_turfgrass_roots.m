%plot_turfgrass_roots.m
% Carolyn Voter
% July 21, 2015

% Creates plot of cumulative root fraction and compares to experimental
% data for Kentucky Bluegrass from the literature

clear all; close all; clc;
set(0,'defaultTextFontSize',12,'defaultTextFontName','Gill Sans MT',...
    'defaultAxesFontSize',12,'defaultAxesFontName','Gill Sans MT')

%% Zeng, 2001 equation
a = 10.74;
b = 6.608;
index = 0;
for i=0:0.01:1.00
    index = index+1;
    ZengPlot(index,1) = -i;
    ZengPlot(index,2) = 1-0.5*(exp(-a*i)+exp(-b*i));
end

%% Erusha et al., 2002

%Root Mass (mg) for each of 16 KY Bluegrass Cultivars.
%Presented as [Total, 0cm, 0-15cm, 15-30cm, 30-45cm, 45-60cm, 60-75cm]
ErushaRootMass(1,:) = [1460, 0, 664, 537, 211, 43, 5];
ErushaRootMass(2,:) = [1429, 0, 575, 491, 279, 70, 14];
ErushaRootMass(3,:) = [1413, 0, 610, 525, 221, 49, 8];
ErushaRootMass(4,:) = [1405, 0, 579, 515, 233, 62, 16];
ErushaRootMass(5,:) = [1345, 0, 594, 462, 213, 78, 8];
ErushaRootMass(6,:) = [1331, 0, 583, 498, 204, 36, 10];
ErushaRootMass(7,:) = [1326, 0, 470, 502, 259, 74, 21];
ErushaRootMass(8,:) = [1313, 0, 496, 469, 260, 62, 26];
ErushaRootMass(9,:) = [1267, 0, 496, 435, 225, 80, 31];
ErushaRootMass(10,:) = [1260, 0, 558, 388, 238, 64, 12];
ErushaRootMass(11,:) = [1254, 0, 549, 436, 223, 38, 8];
ErushaRootMass(12,:) = [1233, 0, 462, 435, 225, 80, 31];
ErushaRootMass(13,:) = [1195, 0, 569, 438, 126, 39, 23];
ErushaRootMass(14,:) = [1190, 0, 431, 409, 236, 88, 26];
ErushaRootMass(15,:) = [1122, 0, 574, 346, 139, 48, 15];
ErushaRootMass(16,:) = [1099, 0, 613, 379, 92, 8, 7];

%Convert root mass (mg) to root fraction (-)
for i=1:16
    ErushaRootFraction(i,:) = ErushaRootMass(i,2:7)/ErushaRootMass(i,1);
end

%Create new matrix w/depth, median root fraction, and cumulative root
%fraction
ErushaPlot = [0;-0.15;-0.30;-0.45;-0.60;-0.75];
for i=1:length(ErushaPlot)
    ErushaPlot(i,2) = median(ErushaRootFraction(:,i));
    ErushaPlot(i,3) = min(sum(ErushaPlot(1:i,2)),1);
end

%% Lyons et al., 2011

%Root Mass for bluegrass cultivars (kg/m^2)
%Presented as [Total, 0cm, 0-3cm, 3-12cm, 12-30cm]
LyonsRootMass(1,:) = [0.1314, 0, 0.1006, 0.0251, 0.0059];
LyonsRootMass(2,:) = [0.1170, 0, 0.0922, 0.0206, 0.0042];
LyonsRootMass(3,:) = [0.1458, 0, 0.1204, 0.0212, 0.0046];
LyonsRootMass(4,:) = [0.1072, 0, 0.0849, 0.0191, 0.0045];
LyonsRootMass(5,:) = [0.1127, 0, 0.0915, 0.0172, 0.0040];
LyonsRootMass(6,:) = [0.1170, 0, 0.1038, 0.0025, 0.0025];

for i=1:6
    LyonsRootFraction(i,:) = LyonsRootMass(i,2:5)/LyonsRootMass(i,1);
end

LyonsPlot = [0;-0.03;-0.12;-0.30];
for i=1:length(LyonsPlot)
    LyonsPlot(i,2) = median(LyonsRootFraction(:,i));
    LyonsPlot(i,3) = min(sum(LyonsPlot(1:i,2)),1);
end

%% Su et al., 2008

%Root Length Density [cm/cm^3] for well-watered field plot of KY bluegrass
%Presented as [0-30cm,30-60cm,60-80cm]
SuRootLengthDensity = [0,10.35,1.08,0.19];
SuRootFraction = SuRootLengthDensity/sum(SuRootLengthDensity);
SuPlot = [0;-0.30;-0.60;-0.80];
SuPlot(:,2) = SuRootFraction';
for i=1:length(SuPlot)
    SuPlot(i,3) = sum(SuPlot(1:i,2));
end

%% PLOT

figure(1)
hold on
axis([0 1 -1 0]);
h1 = plot(ZengPlot(:,2),ZengPlot(:,1),'-k','linewidth',1.5);
h2 = plot(ErushaPlot(:,3),ErushaPlot(:,1),'o-.');
h3 = plot(LyonsPlot(:,3),LyonsPlot(:,1),'s-.');
h4 = plot(SuPlot(:,3),SuPlot(:,1),'^-.');
set(h2,'MarkerFaceColor',get(h2,'Color'));
set(h3,'MarkerFaceColor',get(h3,'Color'));
set(h4,'MarkerFaceColor',get(h4,'Color'));
set(gca,'XAxisLocation','top');
box on
xlabel('Cumulative Root Fraction')
ylabel('Depth (m)')
legend('Model','Erusha et al.','Lyons et al.','Su et al.','location','southwest')
hold off



