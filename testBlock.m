%testBlock.m
%Carolyn Voter
%May 24, 2017

%This script patches together lots to create pseudo-blocks.

clear all; close all; clc;
set(0,'defaultTextFontSize',12,'defaultTextFontName','Helvetica',...
    'defaultAxesFontSize',12,'defaultAxesFontName','Helvetica')
load('greyImpMap.mat');
addpath('J:\Research\Parflow\inputs\matlab_in');

%% Define base
baselot='Lot1111';
for row = [1,2,4,8,16]
    for depth = [1,2]
        lotname = strcat('Block_',num2str(row),'x',num2str(depth));
        saveDir = strcat('K:\Parflow\PFinput\LotType\',lotname); mkdir(saveDir);
        
        %Get base lot data
        load(strcat('K:\Parflow\PFinput\LotType\',baselot,'\domainInfo.mat'));
        xL = 0; yL = 0; zL = 0;
        P = 2; Q = 3;
        
        %Re-calculate
        nx = row*nx; P = row*P;
        ny = depth*ny; Q = depth*Q;
        
        xU = xL+dx*nx;  x0 = xL+dx/2;   xf = xU-dx/2;
        yU = yL+dy*ny;  y0 = yL+dy/2;   yf = yU-dy/2;
        zU = zL+dz*nz;  z0 = zL+dz/2;   zf = zU-dz/2;
        
        x = x0:dx:xf;
        y = y0:dy:yf;
        z = z0:dz:zf;
        
        [X,Y] = meshgrid(x,y);
        domainArea = dx*dy*nx*ny;
        
        %Mirror - rows first
        track = row;
        while track > 1
            elev = [elev,elev];
            NaNimp = [NaNimp,NaNimp];
            parcelCover = [parcelCover,parcelCover];
            slopeX = [slopeX,slopeX];
            slopeY = [slopeY,slopeY];
            track = track/2;
        end
        
        %Mirror - depth second
        if depth > 1
            elev = [elev;elev];
            NaNimp = [NaNimp;NaNimp];
            parcelCover = [parcelCover;parcelCover];
            slopeX = [slopeX;slopeX];
            slopeY = [slopeY;slopeY];
        end
        
        %Save new slope files
        slopex = matrixTOpfsa(slopeX);
        slopey = matrixTOpfsa(slopeY);
        
        %Copy rest of PFlots lines (create other *.sa files and *.txt file)
        %Allocate arrays
        domTop = zeros([ny,nx]); domTop = zeros([ny,nx]); domMid1= zeros([ny,nx]); domMid2 = zeros([ny,nx]);
        
        %Identify key areas in XY map: turfgrass, impervious surface, garage, and house
        for i = 1:ny
            for j = 1:nx
                if parcelCover(i,j) == 0 %Turfgrass
                    vegetation(i,j) = 10;
                    domTop(i,j) = 1;
                    domMid1(i,j) = 1;
                    domMid2(i,j) = 1;
                elseif (parcelCover(i,j) >= 1) && (parcelCover(i,j) < 7) %Impervious Surface
                    vegetation(i,j) = 18;
                    domTop(i,j) = 2;
                    domMid1(i,j) = 1;
                    domMid2(i,j) = 1;
                elseif (parcelCover(i,j) >= 7) %Garage and House
                    vegetation(i,j) = 18;
                    domTop(i,j) = 2;
                    domMid1(i,j) = 2;
                    if (parcelCover(i,j) == 7) || (parcelCover(i,j) == 8) %Just house
                        domMid2(i,j) = 2;
                    elseif (parcelCover(i,j) == 9) %Just garage
                        domMid2(i,j) = 1;
                    end
                end
            end
        end
        
        %Create drv_vegm.dat using special matrixTOvegm function
        for i = 1:ny
            for j = 1:nx
                vegGrid(j,i) = vegetation(i,j);
            end
        end
        %Save
        matrixTOvegm(saveDir,nx,ny,vegGrid);
        
        %Create indicator file to trigger correct subsurface hydraulic properties
        domainTop = matrixTOpfsa(domTop);
        domainMid1 = matrixTOpfsa(domMid1);
        domainMid2 = matrixTOpfsa(domMid2);
        
        %Sidewalk, front walk, driveway only impervious for first 2 layers.
        %Garage only impervious for top 30cm.
        %House only impervious for top 3m.
        nMid1 = round(0.3/dz);
        nMid2 = round(3.0/dz);
        
        %Allocate arrays
        NaNimp = ones([ny nx nz]);
        subsurfaceFeature = ones([nx*ny*nz],1);
        
        %Top layer
        startI = nx*ny*(nz-1)+1;
        endI = nx*ny*nz;
        subsurfaceFeature(startI:endI) = domainTop;
        NaNimp(:,:,nz) = domTop;
        
        %Second layer
        startI = nx*ny*(nz-2)+1;
        endI = nx*ny*(nz-1);
        subsurfaceFeature(startI:endI) = domainTop;
        NaNimp(:,:,(nz-1)) = domTop;
        
        %Mid layers, garage and house
        for i = 3:nMid2
            startI = (nz-i)*nx*ny+1;
            endI = (nz-i+1)*nx*ny;
            if i <=nMid1
                subsurfaceFeature(startI:endI) = domainMid1;
                NaNimp(:,:,(nz-i+1)) = domMid1;
            else
                subsurfaceFeature(startI:endI) = domainMid2;
                NaNimp(:,:,(nz-i+1)) = domMid2;
            end
        end
        
        %Make NaNimp have NaNs
        for i = 1:ny
            for j = 1:nx
                for k = 1:nz
                    if NaNimp(i,j,k) ~= 1
                        NaNimp(i,j,k) = NaN;
                    end
                end
            end
        end
        [pervY,pervX] = find(NaNimp(:,:,nz)==1,1);
        
        %% 4. SAVE LOT INPUTS
        cd(saveDir)
        
        %Parameter text file
        fid = fopen('parameters.txt','w');
        fprintf(fid,'%.2f\n',xL); %1 0.00
        fprintf(fid,'%.2f\n',yL); %2 0.00
        fprintf(fid,'%.2f\n',zL); %3 0.00
        fprintf(fid,'%.0f\n',nx); %4 integer
        fprintf(fid,'%.0f\n',ny); %5 integer
        fprintf(fid,'%.0f\n',nz); %6 integer
        fprintf(fid,'%.2f\n',dx); %7 0.00
        fprintf(fid,'%.2f\n',dy); %8 0.00
        fprintf(fid,'%.2f\n',dz); %9 0.00
        fprintf(fid,'%.2f\n',xU); %10 0.00
        fprintf(fid,'%.2f\n',yU); %11 0.00
        fprintf(fid,'%.2f\n',zU); %12 0.00
        fprintf(fid,'%.0f\n',P); %13 integer
        fprintf(fid,'%.0f\n',Q); %14 integer
        fprintf(fid,'%.0f\n',R); %15 integer
        fclose(fid);
        
        % Post-processing input
        % If add/remove anything here, be sure to also adjust in PFallin.m
        save('domainInfo.mat','dx','dy','dz','nx','ny','nz','x','y','z','domainArea','P','Q','R',...
            'fc','parcelCover','slopeX','slopeY','NaNimp','pervX','pervY','elev','DScalc','-v7.3');
        
        %Pervious
        fid = fopen('subsurfaceFeature.sa','a');
        fprintf(fid,'%d% 4d% 2d\n',[nx ny nz]);
        fprintf(fid,'% d\n',subsurfaceFeature(:));
        fclose(fid);
        
        %Slope X
        fid = fopen('slopex.sa','a');
        fprintf(fid,'%d% 4d% 2d\n',[nx ny 1]);
        fprintf(fid,'% 16.7e\n',slopex(:));
        fclose(fid);
        
        %Slope Y
        fid = fopen('slopey.sa','a');
        fprintf(fid,'%d% 4d% 2d\n',[nx ny 1]);
        fprintf(fid,'% 16.7e\n',slopey(:));
        fclose(fid);
        
        %% PLOT
        %pcolor does not plot last row or column - have to trick it here so that
        %they are displayed.
        xP = [x,x(nx)+dx];
        yP = [y,y(ny)+dy];
        [XP,YP] = meshgrid(xP,yP);
        CP = [parcelCover,parcelCover(:,nx);parcelCover(ny,:),parcelCover(ny,nx)];
        
        %Slope magnitude
        M = (slopeX.^2+slopeY.^2).^0.5;
        MP = [M,M(:,nx);M(ny,:),M(ny,nx)];
        
        %FIGURE 1: Parcel Cover, grey
        figure(1)
        hold on
        axis equal
        axis([xL-2 xU+2 yL-2 yU+2])
        pcolor(XP-0.25,YP-0.25,CP);
        rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
            '-','LineWidth',1.5);
        set(gcf,'Colormap',mycmap)
        xlabel('Distance (m)')
        ylabel('Distance (m)')
        hold off
        savefig('GreyParcelCover.fig')
        
        %FIGURE 2: Parcel Cover, with slopes
        figure(2)
        hold on
        axis equal
        axis([xL-2 xU+2 yL-2 yU+2])
        pcolor(XP-0.25,YP-0.25,CP);
        colormap(cool);
        rectangle('Position',[xL,yL,(xU-xL),(yU-yL)],'EdgeColor','k','LineStyle',...
            '-','LineWidth',1.5);xlabel('Distance (m)')
        quiver(X,Y,-slopeX./M,-slopeY./M,'AutoScaleFactor',0.6,'Color','k','MaxHeadSize',0.6,'LineWidth',1)
        ylabel('Distance (m)')
        hold off
        savefig('Slopes.fig')
        
        %Clean up for next loop
        close all;
        clearvars -except mycmap baselot row depth
        
    end
end

        
        
        
        