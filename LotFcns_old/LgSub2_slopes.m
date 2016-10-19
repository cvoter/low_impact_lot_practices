function [slopeX,slopeY] = LgSub2_slopes(x,nx,dx,y,ny,dy,fc,parcelCover,downspout,landSlope,transverseSlope,dsLength)
%Created by Carolyn Voter
%May 15, 2014

%Creates 2D slope matrix in x and y direction given feature locations for
%Large Suburban Lot 2, as follows:
%   1. Calculate house & garage roof slopes, based on downspout locations
%   2. Calculate y-slope for remaining locations
%   3. Calculate x-slope for remaining locations
%   4. Add in transverse slopes, if applicable
%   5. Calculate elevations, based on slopes (not quite right, at the
%   moment)

%DOWNSPOUT
% 1 = none
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

%% FUNCTION
%ASSUMED PARAMETERS
% roofSlope = 0.2; %magnitude of roof slope
roofSlope = 0.01; %magnitude of roof slope
% streetSlope = 0.02; %magnitude of street slope
streetSlope = 0.01; %magnitude of street slope

%CALCULATED PARAMETERS
ymidHouse = (fc(7,3)+fc(7,4))/2;    xmidHouse = (fc(7,1)+fc(7,2))/2;
ymidGarage = (fc(9,3)+fc(9,4))/2;   xmidGarage = (fc(9,1)+fc(9,2))/2;

%SLOPES & ELEVATIONS
slopeX = zeros([ny nx]);
slopeY = zeros([ny nx]);
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        %House & Garage Slopes (changes w/downspout config)
        if downspout == 1
            %No downspouts
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
        elseif downspout == 2
            %Downspouts at corners, Y-direction
            if parcelCover(i,j) >= 7
                if (thisX > fc(9,1) && thisX < fc(9,1)+dx)
                    slopeY(i,j)=0; %Left edge of building
                elseif (thisX < fc(7,2) && thisX > fc(7,2)-dx)
                    slopeY(i,j)=0; %Right edge of building
                elseif thisY >= (fc(7,4)-7) && ((thisX < fc(9,1)+2*dx) ||...
                        (thisX > fc(7,2)-2*dx) || (thisX > fc(7,1)+dx &&...
                        thisX < fc(7,1)+2*dx))
                    slopeY(i,j)=-roofSlope; %Rear downspout chutes
                elseif thisY < (fc(7,4)-7) && ((thisX < fc(9,1)+2*dx) ||...
                        (thisX > fc(7,2)-2*dx) || (thisX > fc(7,1)+dx &&...
                        thisX < fc(7,1)+2*dx))
                    slopeY(i,j)=roofSlope; %Front downspout chutes
                elseif (thisY >= fc(7,4)-2*dy) && (thisY < fc(7,4)-dy)
                    slopeY(i,j)=0; %Chutes to rear downspout chutes
                elseif (thisY < fc(7,3)+2*dy) && (thisY > fc(7,3)+dy)
                    slopeY(i,j)=0; %Chutes to front house downspout chutes
                elseif parcelCover(i,j) == 9 && (thisY < fc(9,3)+2*dy) &&...
                        (thisY > fc(9,3)+dy)
                    slopeY(i,j)=0; %Chutes to front garage downspout chutes
                elseif (thisX > fc(7,2)-3*dx) && (thisY < (fc(7,3)+dy) ||...
                        thisY > (fc(7,4)-dy))
                    slopeY(i,j)=0; %near right downspouts
                elseif parcelCover(i,j) == 7 && (thisX < fc(7,1)+3*dx) &&...
                        (thisY < (fc(7,3)+dy) || thisY > (fc(7,4)-dy))
                    slopeY(i,j)=0; %near mid downspouts
                elseif (thisX < fc(9,1)+3*dx) && (thisY < (fc(9,3)+dy) ||...
                        thisY > (fc(8,4)-dy))
                    slopeY(i,j)=0; %near left downspouts
                elseif thisY >= (fc(7,4)-7)
                    slopeY(i,j)=-roofSlope; %Rear half
                    if (thisY >= fc(7,4)-dy)
                        slopeY(i,j)=roofSlope; %opposite slope if along edges
                    end
                else slopeY(i,j)=roofSlope; %Front half
                    if thisY <= fc(7,3)+dy || (thisY <= (fc(9,3)+dy) && parcelCover(i,j) == 9)
                        slopeY(i,j) = -roofSlope; %opposite slope if along edges
                    end
                end
                %Downspouts at corners, X-direction
                if ( ( (thisX <= (fc(9,1)+2*dx)) && (thisX > (fc(9,1)+dx)) ) ||...
                        ( (thisX <= (fc(7,1)+2*dx)) && (thisX > (fc(7,1)+dx)) ) ||...
                        ( (thisX >= (fc(7,2)-2*dx)) && (thisX < (fc(7,2)-dx)) ) )
                    slopeX(i,j) = 0; %Chutes to downspouts
                elseif (thisX <=fc(9,1)+dx)
                    slopeX(i,j) = -roofSlope; %Left side of building
                elseif (thisX >=fc(7,2)-dx)
                    slopeX(i,j) = roofSlope; %Right side of building
                elseif (thisX <= (fc(9,1)+4.5))
                    slopeX(i,j) = roofSlope; %Left 3rd of building
                elseif (thisX >= (fc(7,2)-4.5))
                    slopeX(i,j) = -roofSlope; %Right 3rd of building
                elseif thisX >= (fc(7,1)+2*dx)
                    slopeX(i,j) = roofSlope; %Middle 3rd, right part
                else slopeX(i,j) = -roofSlope; %Middle 3rd, left part                    
                end
            end
        elseif downspout == 3 && parcelCover(i,j) >= 7
            %Fully connected Y-direction
            if thisY < (fc(9,4)-3*dy) 
                slopeY(i,j) = -roofSlope; %Front of buildings
            elseif thisY >= (fc(9,4)-2*dy)
                slopeY(i,j) = roofSlope; %Rear of building
            end
            if ( thisY <= fc(9,3) && thisX <= fc(9,2)+dx ) ||...
                    ( thisX <= fc(9,1)+dx && (thisY < fc(9,4)-3*dy ||...
                    thisY > (fc(9,4)-2*dy)) )
                slopeX(i,j) = -roofSlope; %Left house roof below garage, parts of left garage roof
            elseif ( thisY <= fc(9,3) && thisX <= fc(9,2)+2*dx ) ||...
                    ( thisX <= fc(9,1)+2*dx && thisY < fc(9,4)-3*dy ) ||...
                    ( thisX <= fc(9,1)+2*dx && thisY > fc(9,4)-2*dy )
                slopeX(i,j) = 0;
            else slopeX(i,j) = roofSlope; %Elsewhere on buildings
            end
        end
        
        %All configurations, Y-direction
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
            if (downspout == 3) && (thisY >= fc(9,4)-3*dy) && (thisY <= fc(9,4)-2*dy) && thisX < fc(9,1)
                slopeY(i,j) = 0;
            end
        end
        
        %All configurations, X-direction
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

%TRANSVERSE SLOPES
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        %Driveway x-slope
        if transverseSlope(1) ~= 0
            if parcelCover(i,j) == 5
                slopeX(i,j) = transverseSlope(1);
            end
        end
        %Frontwalk x-slope
        if transverseSlope(2) ~= 0
            if parcelCover(i,j) == 6
                slopeX(i,j) = transverseSlope(2);
            end
        end
        %Sidewalk y-slope
        if transverseSlope(3) ~= 0
            if parcelCover(i,j) == 4
                slopeY(i,j) = transverseSlope(3);
            end
        end
    end
end

end

