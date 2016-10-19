function [slopeX,slopeY] = LotB_slopes(x,nx,dx,y,ny,dy,fc,parcelCover,triggers,details)
%Created by Carolyn Voter
%February 20, 2015
%Major modifications September 11, 2015

%Creates 2D slope matrix in x and y direction given feature locations for
%Small Urban Lot 1, as follows:
%   1. Calculate house & garage roof slopes, based on downspout locations
%   2. Calculate y-slope for remaining locations
%   3. Calculate x-slope for remaining locations
%   4. Add in transverse slopes, if applicable
%   5. Calculate elevations, based on slopes (not quite right, at the
%   moment)

%DOWNSPOUT
% 1 = none <---NOT REALLY SET UP FOR THIS
% 2 = at corners
% 3 = fully connected

%TRANSVERSE SLOPE
% column 1: driveway x-slope
% column 2: frontwalk x-slope
% column 3: sidewalk y-slope

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
    load('J:\Research\Parflow\inputs\matlab_in\LotFcnsABC\LotB_microelev.mat');
else
    slopeX = zeros([ny nx]);
    slopeY = zeros([ny nx]);
end
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        if downspout == 0
            %FULLY CONNECTED
            %Y-direction
            if ( (parcelCover(i,j) == 9) && (thisY < (fc(9,3)+2*dy)) ) ||...
                    ( (parcelCover(i,j) == 7) && (thisY < (fc(7,4)-3*dy)) )
                %Front of garage & house
                slopeY(i,j) = -roofSlope;
            elseif (parcelCover(i,j) == 9) && (thisY >= (fc(9,3)+3*dy)) ||...
                    ( (parcelCover(i,j) == 7) && (thisY > (fc(7,4)-2*dy)) )
                %Back of garage & house
                slopeY(i,j) = roofSlope;
            end
            %X-direction
            if ( (parcelCover(i,j) == 7) && thisX <= fc(7,1)+dx && (thisY < (fc(7,4)-4*dy)) )
                slopeX(i,j) = -roofSlope; %Left house roof
            elseif ( (parcelCover(i,j) == 9) && thisX >= fc(9,2)-dx && (thisY > (fc(9,3)+4*dy)) )
                slopeX(i,j) = roofSlope; %Right garage roof
            elseif ( thisX < fc(7,1)+2*dx && thisY < fc(7,4)-3*dy && (parcelCover(i,j) == 7) ) ||...
                    ( thisX < fc(7,1)+2*dx && thisY > fc(7,4)-2*dy && (parcelCover(i,j) == 7) ) ||...
                    ( thisX > fc(9,2)-2*dx && thisY > fc(9,3)+3*dy && (parcelCover(i,j) == 9) ) ||...
                    ( thisX > fc(9,2)-2*dx && thisY < fc(9,3)+2*dy && (parcelCover(i,j) == 9) )
                slopeX(i,j) = 0;
            elseif (parcelCover(i,j) == 7)
                slopeX(i,j) = roofSlope; %Elsewhere on house
            elseif (parcelCover(i,j) == 9)
                slopeX(i,j) = -roofSlope; %Elsewhere on garage
            end
        elseif downspout == 1
            %DOWNSPOUT AT CORNERS
            %Y-direction
            if parcelCover(i,j) == 9
                %Garage
                if (thisY < ymidGarage && thisY >= fc(9,3)+dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,2)-dx && (thisX >= fc(9,2)-2*dx))...
                        || (thisY >= (fc(9,4)-dy))
                    slopeY(i,j) = roofSlope;
                elseif (thisY >= ymidGarage && thisY <= fc(9,4)-2*dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,2)-3*dx)
                    slopeY(i,j) = -roofSlope;
                end
            elseif thisX >= (fc(7,1)+dx) && thisX <= (fc(7,2)-dx) && parcelCover(i,j) == 7
                %House
                if ( thisY < ymidHouse && thisY >= fc(7,3)+dy )...
                        || ( thisY < ymidHouse && thisX <=(fc(7,1)+2*dx) )...
                        || ( thisY < ymidHouse && thisX >=(fc(7,2)-2*dx) )...
                        || ( thisY > fc(7,4)-dy && thisX >(fc(7,1)+3*dx) && thisX < xmidHouse )...
                        || ( thisY > fc(7,4)-dy && thisX <(fc(7,2)-3*dx) && thisX >= xmidHouse)
                    slopeY(i,j) = roofSlope;
                elseif ( thisY > ymidHouse && thisY <= fc(7,4)-dy )...
                        || ( thisY >= ymidHouse && thisX <=(fc(7,1)+2*dx) )...
                        || ( thisY >= ymidHouse && thisX >=(fc(7,2)-2*dx) )...
                        || ( thisY < fc(7,3)+dy && thisX >(fc(7,1)+3*dx) && thisX < xmidHouse )...
                        || ( thisY < fc(7,3)+dy && thisX <(fc(7,2)-3*dx) && thisX >= xmidHouse)
                    slopeY(i,j) = -roofSlope;
                end
            end
            %X-direction
            if parcelCover(i,j) == 9
                %Garage
                if (thisY < ymidGarage && thisX >= fc(9,2)-dx) ||...
                        (thisY >= ymidGarage && thisX >= fc(9,1)+dx) ||...
                        (thisY > (fc(9,4)-2*dy) && thisY < (fc(9,4)-dy))
                    slopeX(i,j) = roofSlope;
                elseif (thisY < ymidGarage && thisX <= fc(9,2)-2*dx) ||...
                        (thisY >= ymidGarage && thisY <= fc(9,4)-3*dy)
                    slopeX(i,j) = -roofSlope;
                end
            elseif parcelCover(i,j) == 7
                %House
                if (thisX < xmidHouse && thisX > fc(7,1)+2*dx)...
                        || (thisX > xmidHouse && thisX > fc(7,2)-dx)
                    slopeX(i,j) = roofSlope;
                elseif (thisX >= xmidHouse && thisX < fc(7,2)-2*dx)...
                        || (thisX < xmidHouse && thisX < fc(7,1)+dx)
                    slopeX(i,j) = -roofSlope;
                end
            end
        end
        
        %EVERYWHERE ELSE, Y-direction
        if (downspout == 1) && thisY < fc(9,3) && (thisY >= (fc(9,3)-dsLength))...
                && (thisX > (fc(9,2)-2*dx)) && (thisX < (fc(9,2)-dx))
            %Downspout = 1, Back Garage
            slopeY(i,j) = landSlope;
        elseif (downspout == 1) && (thisY < (fc(9,4)-dy)) && (thisY > (fc(9,4)-2*dy))...
                && (thisX > (fc(9,1)-dsLength)) && (thisX < fc(9,1))
            %Downspout = 1, Side Garage
            slopeY(i,j) = 0;
        elseif thisY < (fc(1,4)-2*dy) || parcelCover(i,j) == 5 ||...
                ( (thisY > fc(2,3)) && (thisY < (fc(2,3)+dy)) )
            %Street & Alley & Driveway
            slopeY(i,j) = -streetSlope;
        elseif ( thisY > (fc(1,4)-dy) && thisY < fc(1,4) ) ||...
                (thisY > (fc(2,3)+2*dy))
            %Street & Alley
            slopeY(i,j) = streetSlope;
        elseif (thisY > (fc(2,3)+dy)) && (thisY < (fc(2,3)+2*dy))
            slopeY(i,j) = 0;
        elseif thisY < ymidHouse && thisY > fc(1,4) && parcelCover(i,j) < 7
            %Front Yard
            slopeY(i,j) = landSlope;
        elseif (thisY >= (fc(9,3)-dy)) && (thisY < fc(9,3)) &&...
                (thisX >= (fc(9,1)-dx)) && (thisX < fc(9,2))
            %Back of Garage
            slopeY(i,j) = landSlope;
        elseif thisY >= ymidHouse && parcelCover(i,j) < 7
            %Back Yard
            slopeY(i,j) = -landSlope;
            if (downspout == 0) && (thisY >= fc(7,4)-3*dy) && (thisY <= fc(7,4)-2*dy) && thisX < fc(7,1)
                slopeY(i,j) = 0;
            elseif (downspout == 0) && (thisY <= fc(9,3)+3*dy) && (thisY >= fc(9,3)+2*dy) && thisX > fc(9,2)
                slopeY(i,j) = 0;
            end
        end
        
        %EVERYWHERE ELSE, X-direction
        if (downspout == 1) && thisY < fc(9,3) && (thisY >= (fc(9,3)-dsLength))...
                && (thisX > (fc(9,2)-2*dx)) && (thisX < (fc(9,2)-dx))
            %Downspout = 1, Back Garage
            slopeX(i,j) = 0;
        elseif (downspout == 1) && (thisY < (fc(9,4)-dy)) && (thisY > (fc(9,4)-2*dy))...
                && (thisX > (fc(9,1)-dsLength)) && (thisX < fc(9,1))
            %Downspout = 1, Side Garage
            slopeX(i,j) = landSlope;
        elseif thisX < fc(7,1) && thisY > fc(1,4) &&...
                parcelCover(i,j) ~= 1 && parcelCover(i,j) ~= 2 &&...
                parcelCover(i,j) ~= 5 && parcelCover(i,j) ~= 9
            %Left Yard (not Street or Alley or Driveway)
            slopeX(i,j) = landSlope;
        elseif thisX > fc(7,2) && thisY > fc(1,4) &&...
                parcelCover(i,j) ~= 1 && parcelCover(i,j) ~= 2 &&...
                parcelCover(i,j) ~= 5 && parcelCover(i,j) ~= 9
            %Right Yard (not Street or Alley or Driveway)
            slopeX(i,j) = -landSlope;
        elseif (thisY > (fc(9,3))) && thisY < fc(9,4) &&...
                thisX < fc(9,1) && (thisX > fc(9,1)-dx)
            %Left of Garage
            slopeX(i,j) = landSlope;
        elseif (thisY >= (fc(9,3)-2*dy)) && (thisY < fc(9,3)) &&...
                (thisX >= (fc(9,1)-dx)) && (thisX < fc(9,2))
            %Below Garage
            slopeX(i,j) = -landSlope;
        elseif (thisY < fc(1,4) || thisY > fc(2,3)) && thisX < (fc(1,2)/2)
            %Street & Alley
            slopeX(i,j) = landSlope;
        elseif (thisY < fc(1,4) || thisY > fc(2,3)) && thisX >= (fc(1,2)/2)
            %Street & Alley & Driveway
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

