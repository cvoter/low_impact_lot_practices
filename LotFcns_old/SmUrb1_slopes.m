function [slopeX,slopeY] = SmUrb1_slopes(x,nx,dx,y,ny,dy,fc,parcelCover,downspout,landSlope,transverseSlope,dsLength)
%Created by Carolyn Voter
%February 20, 2015

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

%% FUNCTION
%ASSUMED PARAMETERS
roofSlope = 0.2; %magnitude of roof slope
% roofSlope = 0.01; %magnitude of roof slope
streetSlope = 0.02; %magnitude of street slope
% streetSlope = 0.01; %magnitude of street slope

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
        %         if downspout == 1
        %             %No downspouts
        %             if (thisY < ymidGarage) && parcelCover(i,j) == 9;
        %                 %Front Garage
        %                 slopeY(i,j) = roofSlope;
        %             elseif (thisY >= ymidGarage) && parcelCover(i,j) == 9;
        %                 %Back Garage
        %                 slopeY(i,j) = -roofSlope;
        %             elseif (thisY < ymidHouse) && parcelCover(i,j) == 7;
        %                 %Front House
        %                 slopeY(i,j) = roofSlope;
        %             elseif (thisY >= ymidHouse) && parcelCover(i,j) == 7;
        %                 %Back House
        %                 slopeY(i,j) = -roofSlope;
        %             end
        if downspout == 2
            %Downspouts at corners, Y-direction
            if parcelCover(i,j) == 9
                %Garage Y-direction
                if (thisY < ymidGarage && thisY >= fc(9,3)+dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,2)-dx && (thisX >= fc(9,2)-2*dx))...
                        || (thisY >= (fc(9,4)-dy))
                    slopeY(i,j) = roofSlope;
                elseif (thisY >= ymidGarage && thisY <= fc(9,4)-2*dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,2)-3*dx)
                    slopeY(i,j) = -roofSlope;
                end
            elseif thisX >= (fc(7,1)+dx) && thisX <= (fc(7,2)-dx) && parcelCover(i,j) == 7
                %House Y-direction
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
            %Downspouts at corners, X-direction
            if parcelCover(i,j) == 9
                %Garage X-direction
                if (thisY < ymidGarage && thisX >= fc(9,2)-dx) ||...
                        (thisY >= ymidGarage && thisX >= fc(9,1)+dx) ||...
                        (thisY > (fc(9,4)-2*dy) && thisY < (fc(9,4)-dy))
                    slopeX(i,j) = roofSlope;
                elseif (thisY < ymidGarage && thisX <= fc(9,2)-2*dx) ||...
                        (thisY >= ymidGarage && thisY <= fc(9,4)-3*dy)
                    slopeX(i,j) = -roofSlope;
                end
            elseif parcelCover(i,j) == 7
                %House X-direction
                if (thisX < xmidHouse && thisX > fc(7,1)+2*dx)...
                        || (thisX > xmidHouse && thisX > fc(7,2)-dx)
                    slopeX(i,j) = roofSlope;
                elseif (thisX >= xmidHouse && thisX < fc(7,2)-2*dx)...
                        || (thisX < xmidHouse && thisX < fc(7,1)+dx)
                    slopeX(i,j) = -roofSlope;
                end
            end
        elseif downspout == 3
            %Fully connected Y-direction
            if ( (parcelCover(i,j) == 9) && (thisY < (fc(9,3)+2*dy)) ) ||...
                    ( (parcelCover(i,j) == 7) && (thisY < (fc(7,4)-3*dy)) )
                %Front of garage & house
                slopeY(i,j) = -roofSlope;
            elseif (parcelCover(i,j) == 9) && (thisY >= (fc(9,3)+3*dy)) ||...
                    ( (parcelCover(i,j) == 7) && (thisY > (fc(7,4)-2*dy)) )
                %Back of garage & house
                slopeY(i,j) = roofSlope;
            end
            %Fully connected X-direction
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
        end
        
        %All configurations, Y-direction
        if (downspout == 2) && thisY < fc(9,3) && (thisY >= (fc(9,3)-dsLength))...
                && (thisX > (fc(9,2)-2*dx)) && (thisX < (fc(9,2)-dx))
            %Downspout = 2, Back Garage
            slopeY(i,j) = landSlope;
        elseif (downspout == 2) && (thisY < (fc(9,4)-dy)) && (thisY > (fc(9,4)-2*dy))...
                && (thisX > (fc(9,1)-dsLength)) && (thisX < fc(9,1))
            %Downspout = 2, Side Garage
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
            if (downspout == 3) && (thisY >= fc(7,4)-3*dy) && (thisY <= fc(7,4)-2*dy) && thisX < fc(7,1)
                slopeY(i,j) = 0;
            elseif (downspout == 3) && (thisY <= fc(9,3)+3*dy) && (thisY >= fc(9,3)+2*dy) && thisX > fc(9,2)
                slopeY(i,j) = 0;
            end
        end
        
        %All configurations, X-direction
        if (downspout == 2) && thisY < fc(9,3) && (thisY >= (fc(9,3)-dsLength))...
                && (thisX > (fc(9,2)-2*dx)) && (thisX < (fc(9,2)-dx))
            %Downspout = 2, Back Garage
            slopeX(i,j) = 0;
        elseif (downspout == 2) && (thisY < (fc(9,4)-dy)) && (thisY > (fc(9,4)-2*dy))...
                && (thisX > (fc(9,1)-dsLength)) && (thisX < fc(9,1))
            %Downspout = 2, Side Garage
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

