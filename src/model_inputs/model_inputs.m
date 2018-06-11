%model_inputs.m
%Carolyn Voter
%October 21, 2016

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
%% 1. LOT INFO
for downspout = 0:1  % 0=fully connected; 1=downspouts at corners
    for sidewalk = 0:1  % 0=connected sidewalk; 1=offset sidewalk
        for transverse = 0:1  % 0=no transverse slope, 1=transverse slope on driveway & front walk
            for microType = 0:1  % 0=no microtopography, 1=microtopography
                for soilname = {'SiL','Sil2c','SiL10c'}
                    for weathername = {'average','dry'} % weather scenario
                        lotname = sprintf('Lot%d%d%d%d',downspout,sidewalk,...
                            transverse,microType); %used to load outputs from PFlots (slopes, subsurfaceFeature, domainInfo, drv_vegm)
                        runname = sprintf('Lot%d%d%d%d_%s_%s',downspout,sidewalk,...
                            transverse,microType,soilname{1},weathername{1});
                        %% 2. DEFINE DIRS AND FILENAMES BASED ON INPUTS
                        inDir = strcat('../../data/model_inputs/',runname); 
                        mkdir(inDir);
                        lotDir = strcat('../../data/layouts/',lotname);
                        weatherDir = strcat('../../data/weather/',weathername{1});
                        soilFile = strcat('../../data/soil/',soilname{1},'.mat');
                        ICpressFile = strcat('../../data/initial_pressure/initial_pressure_',soilname{1},'.mat');
                        
                        %% 3. COPY EXISTING STUFF INTO INPUT DIR
                        copyfile(lotDir,inDir);
                        copyfile(weatherDir,inDir);
                        
                        %% 4. EXTEND PARAMETER INFO
                        %domainInfo includes:
                        %dx,dy,dz,nx,ny,nz,x,y,z,domainArea,P,Q,R,NaNimp,pervX,pervY
                        load(strcat(inDir,'/domainInfo.mat'))
                        
                        %soilInfo includes:
                        load(soilFile)
                        load('../../data/soil/imperv.mat')
                        
                        %resave domainInfo
                        save(strcat(inDir,'/domainInfo.mat'),'dx','dy',...
                            'dz','nx','ny','nz','x','y','z','domainArea',...
                            'Ks_soil','porosity_soil','VGa_soil',...
                            'VGn_soil','Sres_soil','Ssat_soil','mn_grass',...
                            'Ks_imperv','porosity_imperv','VGa_imperv',...
                            'VGn_imperv','Sres_imperv','Ssat_imperv',...
                            'mn_imperv','P','Q','R','fc','parcelCover',...
                            'slopeX','slopeY','NaNimp','pervX','pervY',...
                            'elev','DScalc','-v7.3');
                        
                        %add to parameters.txt
                        %Parameter text file
                        fid = fopen(strcat(inDir,'/parameters.txt'),'a');
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
                        load(ICpressFile);
                        ICp = spIC;
                        %Create matrix for *.sa file
                        initialP = zeros(nx*ny*nz,1);
                        for i = 1:nz
                            startI = (i-1)*nx*ny+1;
                            endI = i*nx*ny;
                            initialP(startI:endI) = ICp(i);
                        end
                        %Save as *.sa file
                        fid = fopen(strcat(inDir,'/ICpressure.sa'),'a');
                        fprintf(fid,'%d% 4d% 2d\n',[nx ny nz]);
                        fprintf(fid,'% 16.7e\n',initialP(:));
                        fclose(fid);
                    end
                end
            end
        end
    end
end