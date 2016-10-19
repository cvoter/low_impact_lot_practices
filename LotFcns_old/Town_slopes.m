function [slopeX,slopeY] = Town_slopes(x,nx,dx,y,ny,dy,fc,parcelCover,downspout,landSlope,transverseSlope,dsLength)
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
duWidth = (fc(7,2)-fc(7,1))/6;

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
            if (thisY < ymidHouse) && parcelCover(i,j) == 7;
                %Front House
                slopeY(i,j) = roofSlope;
            elseif (thisY >= ymidHouse) && parcelCover(i,j) == 7;
                %Back House
                slopeY(i,j) = -roofSlope;
            end
        elseif downspout == 2
            if parcelCover(i,j) >= 7
                %Downspouts at corners, Y-direction
                if (thisX > (fc(7,1)) && (thisX < fc(7,1)+dx))...
                        || (thisX > (fc(7,1)+duWidth) && thisX < (fc(7,1)+duWidth+dx))...
                        || (thisX > (fc(7,1)+2*duWidth) && thisX < (fc(7,1)+2*duWidth+dx))...
                        || (thisX > (fc(7,1)+3*duWidth) && thisX < (fc(7,1)+3*duWidth+dx))...
                        || (thisX > (fc(7,1)+4*duWidth) && thisX < (fc(7,1)+4*duWidth+dx))...
                        || (thisX > (fc(7,1)+5*duWidth) && thisX < (fc(7,1)+5*duWidth+dx))
                    slopeX(i,j) = -roofSlope; %Column to left of downspouts
                    slopeY(i,j) = 0; 
                elseif (thisX > (fc(7,1)+dx) && (thisX < fc(7,1)+2*dx))...
                        || (thisX > (fc(7,1)+duWidth+dx) && thisX < (fc(7,1)+duWidth+2*dx))...
                        || (thisX > (fc(7,1)+2*duWidth+dx) && thisX < (fc(7,1)+2*duWidth+2*dx))...
                        || (thisX > (fc(7,1)+3*duWidth+dx) && thisX < (fc(7,1)+3*duWidth+2*dx))...
                        || (thisX > (fc(7,1)+4*duWidth+dx) && thisX < (fc(7,1)+4*duWidth+2*dx))...
                        || (thisX > (fc(7,1)+5*duWidth+dx) && thisX < (fc(7,1)+5*duWidth+2*dx))
                    slopeX(i,j) = 0; %Downspout chutes
                    if thisY >= ymidHouse
                        slopeY(i,j)=-roofSlope;
                    else slopeY(i,j)=roofSlope;
                    end
                elseif (thisY < (fc(7,3)+dy) || thisY > (fc(7,4)-dy) ) &&...
                        ( (thisX > (fc(7,1)+2*dx) && (thisX < fc(7,1)+3*dx))...
                        || (thisX > (fc(7,1)+duWidth+2*dx) && thisX < (fc(7,1)+duWidth+3*dx))...
                        || (thisX > (fc(7,1)+2*duWidth+2*dx) && thisX < (fc(7,1)+2*duWidth+3*dx))...
                        || (thisX > (fc(7,1)+3*duWidth+2*dx) && thisX < (fc(7,1)+3*duWidth+3*dx))...
                        || (thisX > (fc(7,1)+4*duWidth+2*dx) && thisX < (fc(7,1)+4*duWidth+3*dx))...
                        || (thisX > (fc(7,1)+5*duWidth+2*dx) && thisX < (fc(7,1)+5*duWidth+3*dx)) )
                    slopeY(i,j) = 0; %Just next to downspout
                    slopeX(i,j) = roofSlope;
                elseif ( thisY > (fc(7,3)+dy) && thisY < (fc(7,3)+2*dy) ) ||...
                        ( thisY < (fc(7,4)-dy) && thisY > (fc(7,4)-2*dy) )
                    slopeY(i,j) = 0; %horizontal chutes
                    slopeX(i,j) = roofSlope;
                elseif thisY < fc(7,3)+dy
                    slopeY(i,j) = -roofSlope; %front edge
                    slopeX(i,j) = roofSlope;
                elseif thisY > fc(7,4)-dy
                    slopeY(i,j) = roofSlope; %rear edge
                    slopeX(i,j) = roofSlope;
                elseif thisY >= ymidHouse
                    slopeX(i,j) = roofSlope;
                    slopeY(i,j) = -roofSlope; %rest of rear house
                else
                    slopeX(i,j) = roofSlope;
                    slopeY(i,j) = roofSlope; %rest of front house
                end
            end
        elseif downspout == 3 && parcelCover(i,j) >= 7
            %Fully connected Y-direction
            if thisY < ymidHouse 
                slopeY(i,j) = -roofSlope; %Front of buildings
            elseif thisY >= (ymidHouse + dy)
                slopeY(i,j) = roofSlope; %Rear of building
            else slopeY(i,j) = 0;
            end
            %Fully connected X-direction
            if thisY > ymidHouse && thisX < (ymidHouse+dy)
                if thisX < xmidHouse
                    slopeX(i,j) = roofSlope; %Left downspout chute
                else slopeX(i,j) = -roofSlope; %Right downspout chute
                end
            elseif thisX < xmidHouse
                slopeX(i,j) = roofSlope;
            else slopeX(i,j) = -roofSlope;
            end
        end
        
        %All configurations, Y-direction
        if thisY < (fc(1,4)-2*dy)
            slopeY(i,j) = -streetSlope; %Lower street
        elseif thisY > (fc(1,4)-dy) && thisY < fc(1,4)
            slopeY(i,j) = streetSlope; %Upper street
        elseif thisY < (fc(3,4)-2*dy) && thisY > fc(3,3)
            slopeY(i,j) = -streetSlope; %Lower Parking Lot
        elseif thisY > (fc(3,4)-dy) && thisY < fc(3,4)
            slopeY(i,j) = streetSlope; %Upper Parking Lot
        elseif thisY < ymidHouse && thisY > fc(3,4) && parcelCover(i,j) < 7
            slopeY(i,j) = landSlope; %Front Yard
        elseif thisY >= ymidHouse && parcelCover(i,j) < 7
            slopeY(i,j) = -landSlope; %Back Yard
            if (downspout == 3) && (thisY >= ymidHouse)...
                    && (thisY <= ymidHouse+dy) &&...
                    ( thisX < fc(7,1) || (thisX > fc(7,2)) )
                slopeY(i,j) = 0;
            end
        end
        
        %All configurations, X-direction
        if thisX < fc(7,1) && thisY > fc(3,4)
            slopeX(i,j) = landSlope; %Left Yard (not Street or Parking Lot)
        elseif thisX > fc(7,2) && thisY > fc(3,4)
            slopeX(i,j) = -landSlope; %Right Yard (not Street or Parking Lot)
        elseif thisY < fc(3,4) && thisX < fc(1,2)/2
            slopeX(i,j) = landSlope; %Left Street and Parking Lot
        elseif thisY < fc(3,4) && thisX >= fc(1,2)/2
            slopeX(i,j) = -landSlope; %Right Street and Parking Lot
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

