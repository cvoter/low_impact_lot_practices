function [slopeX,slopeY] = LotA_slopes(x,nx,dx,y,ny,dy,fc,parcelCover,triggers,details)
%Created by Carolyn Voter
%May 15, 2014
%Major modifications September 11, 2015

%Creates 2D slope matrix in x and y direction given feature locations for
%Large Suburban Lot 1, as follows:
%   1. Calculate house & garage roof slopes, based on downspout locations
%   2. Calculate y-slope for remaining locations
%   3. Calculate x-slope for remaining locations
%   4. Add in transverse slopes, if applicable
%   5. Calculate elevations, based on slopes (not quite right, at the
%   moment)

%PARCEL COVER - ROWS
% 0 = turfgrass
% 1 = street
% 2 = alley
% 3 = parking lot
% 4 = sidewalk
% 5 = driveway
% 6 = frontwalk
% 7 = house
% 8 = house2 (only neede for LgSub2)
% 9 = garage

%PARCEL COVER - COLUMNS
% 1=left X   2=right X    3=lower Y    4=upper Y

%OTHER NOTES:
%Positive Slope points uphill   --> high coordinate = highest elev
%Negative Slope points downhill --> low coordinate = highest elev

%% INPUTS
developed = triggers(1);
downspout = triggers(2);
sidewalk = triggers(3);
transverse = triggers(4);
microType = triggers(5);

landSlope = details(1);
roofSlope = details(2);
streetSlope = details(3);
transverseSlope = details(4);
dsLength = details(5);
sidewalkOffset = details(6)*sidewalk;

%% FUNCTION

%CALCULATED PARAMETERS
ymidHouse = (fc(7,3)+fc(7,4))/2;    xmidHouse = (fc(7,1)+fc(7,2))/2;
ymidGarage = (fc(9,3)+fc(9,4))/2;   xmidGarage = (fc(9,1)+fc(9,2))/2;

%% DEVELOPED SLOPES
if microType == 1
    load('J:\Research\Parflow\inputs\matlab_in\LotFcnsABC\LotA_microelev.mat');
else
    slopeX = zeros([ny nx]);
    slopeY = zeros([ny nx]);
end
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        %HOUSE & GARAGE (depends on downspouts)
        if downspout == 0 && parcelCover(i,j) >= 7 
            %FULLY CONNECTED
            %Y-direction
            if thisY < (fc(9,4)-3*dy)
                %Front of buildings
                slopeY(i,j) = -roofSlope;
            elseif thisY >= (fc(9,4)-2*dy)
                slopeY(i,j) = roofSlope;
            end
            %X-direction
            if ( thisY <= fc(9,3) && thisX <= fc(9,2)+dx ) ||...
                    ( thisX <= fc(9,1)+dx && thisY < fc(9,4)-4*dy )
                slopeX(i,j) = -roofSlope; %Left house roof below garage, parts of left garage roof
            elseif ( thisY <= fc(9,3) && thisX <= fc(9,2)+2*dx ) ||...
                    ( thisX <= fc(9,1)+2*dx && thisY < fc(9,4)-3*dy ) ||...
                    ( thisX <= fc(9,1)+2*dx && thisY > fc(9,4)-2*dy )
                slopeX(i,j) = 0;
            else slopeX(i,j) = roofSlope; %Elsewhere on buildings
            end
        elseif downspout == 1
            %DOWNSPOUT AT CORNERS
            %Y-direction
            if thisX >= fc(9,1)+dx && parcelCover(i,j) == 9
                %Garage
                if (thisY < ymidGarage && thisY >= fc(9,3)+dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,1)+2*dx)...
                        || (thisY >= (fc(9,4)-dy) && thisX > (fc(9,1)+3*dx))
                    slopeY(i,j) = roofSlope;
                elseif (thisY > ymidGarage && thisY <= fc(9,4)-dy)...
                        || (thisY > ymidGarage && thisX <= fc(9,1)+2*dx)...
                        || (thisY <= (fc(9,3)+dy) && thisX > (fc(9,1)+3*dx))
                    slopeY(i,j) = -roofSlope;
                end
            elseif thisX >= (fc(7,1)+dx) && thisX <= (fc(7,2)-dx) && parcelCover(i,j) == 7
                %House
                if ( thisY < ymidHouse && thisY >= fc(7,3)+dy )...
                        || ( thisY < ymidHouse && thisX <=(fc(7,1)+2*dx) )...
                        || ( thisY < ymidHouse && thisX >=(fc(7,2)-2*dx) )...
                        || ( thisY > fc(7,4)-dy && thisX >(fc(7,1)+3*dx) && thisX < xmidHouse )...
                        || ( thisY > fc(7,4)-dy && thisX <(fc(7,2)-3*dx) && thisX > xmidHouse)
                    slopeY(i,j) = roofSlope;
                elseif ( thisY > ymidHouse && thisY <= fc(7,4)-dy )...
                        || ( thisY > ymidHouse && thisX <=(fc(7,1)+2*dx) )...
                        || ( thisY > ymidHouse && thisX >=(fc(7,2)-2*dx) )...
                        || ( thisY < fc(7,3)+dy && thisX >(fc(7,1)+3*dx) && thisX < xmidHouse )...
                        || ( thisY < fc(7,3)+dy && thisX <(fc(7,2)-3*dx) && thisX > xmidHouse)
                    slopeY(i,j) = -roofSlope;
                end
            end
            %X-direction
            if parcelCover(i,j) == 9 
                %Garage
                if thisX > fc(9,1)+2*dx
                    slopeX(i,j) = roofSlope;
                elseif thisX <= fc(9,1)+dx
                    slopeX(i,j) = -roofSlope;
                end
            elseif parcelCover(i,j) == 7 
                %House
                if (thisX < xmidHouse && thisX > fc(7,1)+2*dx)...
                        || (thisX > xmidHouse && thisX > fc(7,2)-dx)
                    slopeX(i,j) = roofSlope;
                elseif (thisX > xmidHouse && thisX < fc(7,2)-2*dx)...
                        || (thisX < xmidHouse && thisX < fc(7,1)+dx)
                    slopeX(i,j) = -roofSlope;
                end
            end
        elseif downspout == 2
            %NO DOWNSPOUTS
            if (thisY < ymidGarage) && parcelCover(i,j) == 9;
                %Front Garage
                slopeY(i,j) = roofSlope;
            elseif (thisY >= ymidGarage) && parcelCover(i,j) == 9;
                %Back Garage
                slopeY(i,j) = -roofSlope;
            elseif (thisY < ymidHouse) && parcelCover(i,j) == 7;
                %Front House
                slopeY(i,j) = roofSlope;
            elseif (thisY >= ymidHouse) && parcelCover(i,j) == 7;
                %Back House
                slopeY(i,j) = -roofSlope;
            end
        end
        
        %EVERYWHERE ELSE, Y-direction
        if thisY < (fc(1,4)-2*dy)
            %Street
            slopeY(i,j) = -streetSlope;
        elseif thisY > (fc(1,4)-dy) && thisY < fc(1,4)
            slopeY(i,j) = streetSlope;
        elseif thisY < ymidHouse && thisY > fc(1,4) && parcelCover(i,j) < 7
            %Front Yard
            slopeY(i,j) = landSlope;
        elseif thisY >= ymidHouse && parcelCover(i,j) < 7
            %Back Yard
            slopeY(i,j) = -landSlope;
            if (downspout == 0) && (thisY >= fc(9,4)-3*dy) && (thisY <= fc(9,4)-2*dy) && thisX < fc(9,1)
                slopeY(i,j) = 0;
            end
        end
        
        %EVERYWHERE ELSE, X-direction
        if thisX < fc(9,1) && thisY > fc(1,4)
            %Left Yard (not Street)
            slopeX(i,j) = landSlope;
        elseif thisX > fc(7,2) && thisY > fc(1,4)
            %Right Yard (not Street)
            slopeX(i,j) = -landSlope;
        elseif thisY < fc(1,4) && thisX < fc(1,2)/2
            %Street
            slopeX(i,j) = landSlope;
        elseif thisY < fc(1,4) && thisX >= fc(1,2)/2
            %Street
            slopeX(i,j) = -landSlope;
        end
    end
end

%% TRANSVERSE SLOPES
if transverse == 1
    for i = 1:ny
        thisY = y(i);
        for j = 1:nx
            thisX = x(j);
            %Driveway x-slope
            if parcelCover(i,j) == 5
                slopeX(i,j) = transverseSlope;
            end
            %Frontwalk x-slope
            if parcelCover(i,j) == 6
                slopeX(i,j) = transverseSlope;
            end
        end
    end
end
%% UNDEVELOPED
if developed == 0
    slopeX = zeros([ny nx]);
    slopeY = zeros([ny nx]);
    for i = 1:ny
        thisY = y(i);
        for j = 1:nx
            thisX = x(j);
            if (thisY < y(ny/2))
                slopeY(i,j) = landSlope;
            elseif (thisY >= y(ny/2))
                slopeY(i,j) = -landSlope;
            end
            if (thisX < 1.5)
                slopeX(i,j) = landSlope;
            elseif (thisX >= (x(nx) - 1.5))
                slopeX(i,j) = -landSlope;
            end
        end
    end
end
end

