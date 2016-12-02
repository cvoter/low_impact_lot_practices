function [slopeX,slopeY,elev,DScalc,sumflag] = LotB_slopes(x,nx,dx,xL,xU,y,ny,dy,yL,yU,X,Y,fc,parcelCover,triggers,details)
%Created by Carolyn Voter
%February 20, 2015
%Major modifications September 11, 2015

%Creates 2D slope matrix in x and y direction given feature locations for
%Small Urban Lot 1, as follows:
%   1. INPUTS: interprets triggers and details about slopes, calculates
%   other key locations in lot.
%   2. DEVELOPED ELEVATIONS: calculates elevation for basic developed lot.
%   3. ADD MICROTOPOGRAPHY: loads microtopography elevations for LotB and
%   adds them to developed elevations, if triggered.
%   4. CALCULATE INITIAL SLOPES: Calculates slope using elevations of cell
%   above and below given cell. Based on initial elevations.
%   5. CHECK FOR PITS, WHEN MICROTOPGRAPHY EXISTS: If microtopography was
%   added, this pitfilling algorithm looks for problem cells and adds a
%   small amount to elevation of problem cells each loop. Iterates a fixed
%   number of times.
%   6. CHECK DEPRESSION STORAGE: Calculate actual depression storage, after
%   adjustments from pitfilling. If start with DS = 7.5mm, end up close to
%   5mm.
%   7. ADD MASK OF IMPERVIOUS SLOPES: Can't manipulate elevations to
%   represent impervious slopes, so replace with desired slopes here. Also
%   fix known problem areas near downspouts or sides of buildings.
%   8. UNDO ALL FOR UNDEVELOPED: If undeveloped, scrap everything just done
%   and create very simple slopes.

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

%% 1. INPUTS
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

%CALCULATED PARAMETERS
ymidHouse = (fc(7,3)+fc(7,4))/2;    xmidHouse = (fc(7,1)+fc(7,2))/2;
ymidGarage = (fc(9,3)+fc(9,4))/2;   xmidGarage = (fc(9,1)+fc(9,2))/2;

%% 2. DEVELOPED ELEVATIONS
%format = x,y,elev
ySt1 = fc(1,4)-dy;%fc(1,4)-1.5*dy;
sTOs = fc(1,4)-fc(1,3)-1.5*dy;
stElev = [xL,yL,0;... %1. left edge base
    xU/2-dx/2,yL,(xU/2-dx/2)*landSlope;... %2. midpoint base (high point)
    xU,yL,0;... %3. right edge base
    xL,ySt1,-sTOs*landSlope;... %4. left edge middle
    xU/2-dx/2,ySt1,(xU/2-dx/2-sTOs)*landSlope;... %5. midpoint middle
    xU,ySt1,-sTOs*landSlope;... %6. right edge middle
    xL,fc(1,4),(-sTOs+1.5*dy)*landSlope;... %7. left edge top
    xU/2-dx/2,fc(1,4),(xU/2-dx/2-sTOs+1.5*dy)*landSlope;... %8. midpoint top
    xU,fc(1,4),(-sTOs+1.5*dy)*landSlope]; %9. right edge top

stTOh = fc(7,3)-fc(1,4); %distance between street and house
fElev = [xL,fc(7,3),(stTOh-fc(7,1))*landSlope+stElev(8,3);... %1. left edge
    fc(7,1),fc(7,3),stTOh*landSlope+stElev(8,3);...%2. left edge of house
    xU/2,fc(7,3),stTOh*landSlope+stElev(8,3);... %3. midpoint
    fc(7,2),fc(7,3),stTOh*landSlope+stElev(8,3);...%4. right edge of house
    xU,fc(7,3),(stTOh-xU+fc(7,2))*landSlope+stElev(8,3)]; %5. right edge

sElev = [xL,fc(7,4),fElev(1,3);... %1. left edge
    fc(7,1),fc(7,4),fElev(2,3);...%2. left edge of house
    fc(7,2),fc(7,4),fElev(4,3);... %3. right edge of house
    xU,fc(7,4),fElev(5,3)]; %4. right edge

hTOg = fc(9,3)-fc(7,4); %distance between house and garage
heTOge = fc(9,2)-fc(7,2); %distance between edge of house and edge of garage
rElev = [xL,fc(9,3),sElev(1,3)-hTOg*landSlope;... %1. left edge
    fc(7,1),fc(9,3),sElev(2,3)-hTOg*landSlope;... %2. left edge of house
    fc(9,1),fc(9,3),sElev(2,3)-hTOg*landSlope;... %3. left edge of garage
    xU,fc(9,3),sElev(4,3)-hTOg*landSlope]; %4. right edge

rElev2 = [fc(9,2),fc(9,3),rElev(4,3)+(fc(9,2)-xU)*(rElev(3,3)-rElev(4,3))/(fc(9,1)-xU)]; %1. right edge of garage

fgTOrg = fc(9,4)-fc(9,3); %distance between front and rear garage
rgElev = [xL,fc(9,4),rElev(1,3)-fgTOrg*landSlope;... %1.  left edge
    fc(7,1),fc(9,4),rElev(2,3)-fgTOrg*landSlope;... %2. left edge of house
    fc(9,1),fc(9,4),rElev(3,3)-fgTOrg*landSlope;... %3. left edge of garage
    fc(9,2),fc(9,4),rElev2(1,3)-fgTOrg*landSlope;... %4. right edge of garage
    xU,fc(9,4),rElev(4,3)-fgTOrg*landSlope]; %5. right edge

rfTOa = fc(2,3)-fc(9,4); %distance between rear garage and alleyway
dElev = [xL,fc(2,3),rgElev(1,3)-rfTOa*landSlope;... %1.  left edge
    fc(7,1),fc(2,3),rgElev(2,3)-rfTOa*landSlope;... %2. left edge of house
    fc(9,1),fc(2,3),rgElev(3,3)-rfTOa*landSlope;... %3. left edge of garage
    fc(9,2),fc(2,3),rgElev(4,3)-rfTOa*landSlope;... %4. right edge of garage
    xU,fc(2,3),rgElev(5,3)-rfTOa*landSlope]; %5. right edge

yA1 = fc(2,3)+1.5*dy;
aTOa = fc(2,4)-fc(2,3)-1.5*dy;
aElev = [xL,yA1,dElev(2,3)-(1.5*dy+xU/2)*landSlope;... %1. left edge
    fc(7,1),yA1,dElev(2,3)-(1.5*dy+xU/2-fc(7,1))*landSlope;... %2. left edge house
    xU/2,yA1,dElev(2,3)-1.5*dy*landSlope;... %3. midpoint
    fc(9,1),yA1,dElev(2,3)+(xU/2-fc(9,1)-1.5)*landSlope;... %4. left edge garage
    fc(9,2),yA1,dElev(2,3)+(xU/2-fc(9,2)-1.5)*landSlope;... %5. right edge garage
    xU,yA1,dElev(2,3)-(1.5*dy+xU/2)*landSlope;... %6. right edge
    xL,fc(2,4),dElev(2,3)+(aTOa-1.5*dy-xU/2)*landSlope;... %7. left edge
    xU/2,fc(2,4),dElev(2,3)+(aTOa-1.5*dy)*landSlope;... %8. midpoint
    xU,fc(2,4),dElev(2,3)+(aTOa-1.5*dy-xU/2)*landSlope]; %9. right edge

allElev = [stElev;fElev;sElev;rElev;rElev2;rgElev;dElev;aElev];
elev = griddata(allElev(:,1),allElev(:,2),allElev(:,3),X,Y);
elevSlopes = elev;

%% 3. ADD MICROTOPOGRAPHY
if microType == 1
    load('J:\Research\Parflow\inputs\matlab_in\LotFcnsABC\LotB_microelev.mat');
    for i = 1:ny
        for j = 1:nx
            if parcelCover(i,j) == 0
                elev(i,j) = elev(i,j)+microElev(i,j);
            end
        end
    end
end

minElev = abs(min(min(elev)));
elev = elev+minElev;
elevSlopes = elevSlopes+minElev;

%% 4. CALCULATE INITIAL SLOPES
for i = 1:ny
    for j = 1:nx
        %SlopeY
        if i == 1
            slopeY(i,j) = (elev(i+1,j)-elev(i,j))/dy;
        elseif i == ny
            slopeY(i,j) = (elev(i,j)-elev(i-1,j))/dy;
        else
            if elev(i+1,j) > elev(i,j) && elev(i-1,j) > elev(i,j)
                slopeY(i,j) = 0;
            else slopeY(i,j) = (elev(i+1,j)-elev(i-1,j))/(2*dy);
            end
        end
        %SlopeY
        if j == 1
            slopeX(i,j) = (elev(i,j+1)-elev(i,j))/dx;
        elseif j == nx
            slopeX(i,j) = (elev(i,j)-elev(i,j-1))/dx;
        else
            if elev(i,j+1) > elev(i,j) && elev(i,j-1) > elev(i,j)
                slopeX(i,j) = 0;
            else slopeX(i,j) = (elev(i,j+1)-elev(i,j-1))/(2*dx);
            end
        end
    end
end
M = (slopeX.^2+slopeY.^2).^0.5;
%% 5. CHECK FOR PITS, WHEN MICROTOPGRAPHY EXISTS
if microType == 1
    for iter = 1:500
        for i = 1:ny
            for j = 1:nx
                if parcelCover(i,j) == 0 && M(i,j) == 0
                    elev(i,j) = elev(i,j) + 0.002;
                    flag(i,j,iter) = 1;
                end
            end
        end
        
        for i = 1:ny
            for j = 1:nx
                %SlopeY
                if i == 1
                    slopeY(i,j) = (elev(i+1,j)-elev(i,j))/dy;
                elseif i == ny
                    slopeY(i,j) = (elev(i,j)-elev(i-1,j))/dy;
                else
                    if elev(i+1,j) > elev(i,j) && elev(i-1,j) > elev(i,j)
                        slopeY(i,j) = 0;
                    else slopeY(i,j) = (elev(i+1,j)-elev(i-1,j))/(2*dy);
                    end
                end
                %SlopeY
                if j == 1
                    slopeX(i,j) = (elev(i,j+1)-elev(i,j))/dx;
                elseif j == nx
                    slopeX(i,j) = (elev(i,j)-elev(i,j-1))/dx;
                else
                    if elev(i,j+1) > elev(i,j) && elev(i,j-1) > elev(i,j)
                        slopeX(i,j) = 0;
                    else slopeX(i,j) = (elev(i,j+1)-elev(i,j-1))/(2*dx);
                    end
                end
            end
        end
        M = (slopeX.^2+slopeY.^2).^0.5;
    end
    sumflag = squeeze(sum(sum(flag))); %Number of cells with M = 0 each iteration
else
    sumflag = 0;
end
%% 6. CHECK DEPRESSION STORAGE
elevR = elev - elevSlopes;
k = 1;
for i = 1:ny
    for j = 1:nx
        if parcelCover(i,j) == 0
            elevRR(k) = elevR(i,j);
            k = k+1;
        end
    end
end
RRinc = 0;
for i = 1:k-1
    RRinc = RRinc + (elevRR(i) - mean(elevRR))^2;
end
RRcalc = sqrt((1/(k-2))*RRinc)*100; %Random roughness [cm]
DScalc = 0.112*RRcalc+0.031*RRcalc^2-0.012*RRcalc*landSlope*100; %Depression storage [cm]

%% 7. ADD MASK OF IMPERVIOUS SLOPES
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        
        %ROOFS
        if downspout == 0
            %0: FULLY CONNECTED
            %Y-direction
            if ( (parcelCover(i,j) == 9) && (thisY < (fc(9,3)+2*dy)) ) ||...
                    ( (parcelCover(i,j) == 7) && (thisY < (fc(7,4)-3*dy)) )
                %Front of garage & house
                slopeY(i,j) = -roofSlope;
            elseif (parcelCover(i,j) == 9) && (thisY >= (fc(9,3)+3*dy)) ||...
                    ( (parcelCover(i,j) == 7) && (thisY > (fc(7,4)-2*dy)) )
                %Back of garage & house
                slopeY(i,j) = roofSlope;
            elseif thisX > fc(9,2) && thisX < xU && thisY > fc(9,3)+2*dy &&...
                    thisY < fc(9,3)+3*dy
                %Garage "downspout" off side
                slopeY(i,j) = 0;
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
            %1: DOWNSPOUT AT CORNERS
            %Y-direction
            if parcelCover(i,j) == 9
                %Garage
                if (thisY < ymidGarage && thisY > fc(9,3)+2*dy)...
                        || (thisY < ymidGarage && thisX <= fc(9,2) && (thisX >= fc(9,2)-2*dx))...
                        || (thisY >= (fc(9,4)-dy))
                    slopeY(i,j) = roofSlope;
                elseif (thisY >= ymidGarage && thisY <= fc(9,4)-2*dy)...
                        || (thisY < ymidGarage && thisY < fc(9,3)+dy && thisX <= fc(9,2)-3*dx)
                    slopeY(i,j) = -roofSlope;
                end
            elseif thisX >= (fc(7,1)+dx) && thisX <= (fc(7,2)-dx) && parcelCover(i,j) == 7
                %House
                if ( thisY < ymidHouse && thisY >= fc(7,3)+2*dy )...
                        || ( thisY < ymidHouse && thisX <=(fc(7,1)+2*dx) )...
                        || ( thisY < ymidHouse && thisX >=(fc(7,2)-2*dx) )...
                        || ( thisY > fc(7,4)-dy && thisX >(fc(7,1)+3*dx) && thisX < xmidHouse )...
                        || ( thisY > fc(7,4)-dy && thisX <(fc(7,2)-3*dx) && thisX >= xmidHouse)
                    slopeY(i,j) = roofSlope;
                elseif ( thisY > ymidHouse && thisY <= fc(7,4)-2*dy )...
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
                        (thisY >= ymidGarage && thisX >= fc(9,1)+2*dx) ||...
                        (thisY > (fc(9,4)-2*dy) && thisY < (fc(9,4)-dy))
                    slopeX(i,j) = roofSlope;
                elseif (thisY < ymidGarage && thisX <= fc(9,2)-2*dx) ||...
                        (thisY >= ymidGarage && thisY <= fc(9,4)-3*dy && thisX < fc(9,1)+dx)
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
            %Make downspouts go straight out
            if parcelCover(i,j) == 4 && thisY > fc(4,4) && thisY < fc(7,4)
                slopeX(i,j) = 0;
                slopeY(i,j) = landSlope;
            elseif parcelCover(i,j) == 4 && thisY > fc(7,4) && thisY < fc(7,4)+3*dy
                slopeX(i,j) = 0;
                slopeY(i,j) = -landSlope;
            elseif parcelCover(i,j) == 4 && thisY > fc(7,4)+3*dy && thisY < fc(9,3)
                slopeX(i,j) = 0;
                slopeY(i,j) = landSlope;
            elseif parcelCover(i,j) == 4 && thisY > fc(9,3)
                slopeX(i,j) = landSlope;
                slopeY(i,j) = 0;
            end
            %Avoid issue at end of one downspout
            if thisY < fc(9,3)-3*dy && thisY > fc(9,3)-4*dy &&...
                    thisX < fc(9,2)-dx && thisX > fc(9,2)-2*dx
                slopeY(i,j) = 0;
                slopeX(i,j) = -landSlope;
            end
            %Avoid issue at end of other downspout
            if thisX < fc(9,1)-3*dx && thisX > fc(9,1)-4*dx &&...
                    thisY < fc(9,4)-dy && thisY > fc(9,4)-2*dy
                if slopeX(i,j) < 0
                    slopeX(i,j) = -slopeX(i,j);
                end
            end
        end
        
         
        %FORCE SIDEWALK SLOPE
        if parcelCover(i,j) == 4 && thisY < fc(4,4)
            slopeX(i,j) = 0;
            slopeY(i,j) = landSlope;
        end
        
        %FORCE FRONTWALK SLOPE
        if parcelCover(i,j) == 6 && thisY < fc(7,3)
            slopeX(i,j) = 0;
            slopeY(i,j) = landSlope;
        end
        
        %FORCE STREET & ALLEY SLOPE
        if parcelCover(i,j) == 1 && thisY > fc(1,4)-dy
            slopeX(i,j) = 0;
            slopeY(i,j) = landSlope;
        elseif parcelCover(i,j) == 2 && thisY < fc(2,3)+dy
            slopeX(i,j) = 0;
            slopeY(i,j) = -landSlope;
        end
        
        %FIX SLOPE NEAR GARAGE
        if parcelCover(i,j) == 0 && thisX > fc(9,1) && thisX < fc(9,2) &&...
                thisY < fc(9,3) && thisY > fc(9,3)-dy
            slopeY(i,j) = 0;
            if slopeX(i,j) >= 0
                slopeX(i,j) = -landSlope;
            end
        end
        
        %FIX TRANSVERSE FOR DRIVEWAY OR FRONT WALK
        if transverse == 0
            %Driveway
            if parcelCover(i,j) == 5
                slopeX(i,j) = 0;
            end
        elseif transverse == 1
            if parcelCover(i,j) == 6
                slopeX(i,j) = -landSlope;
                slopeY(i,j) = landSlope;
            elseif parcelCover(i,j) == 5;
                slopeX(i,j) = -landSlope;
                slopeX(i,j) = -landSlope;
            end
        end
        
        %FIX SLOPES NEAR HOUSE AND GARAGE
        if thisX > fc(7,1) && thisX < fc(7,2) && thisY < fc(7,3) && thisY > fc(7,3)-dy
            %just below house
            if slopeY(i,j) < 0
                slopeY(i,j) = -slopeY(i,j);
            end
        elseif thisX > fc(7,1) && thisX < fc(7,2) && thisY > fc(7,4) && thisY < fc(7,4)+dy
            %just above house
            if slopeY(i,j) > 0
                slopeY(i,j) = -slopeY(i,j);
            end
        elseif thisY > fc(7,3) && thisY < fc(7,4) && thisX < fc(7,1) && thisX > fc(7,1)-dx
            %just left of house
            if slopeX(i,j) < 0
                slopeX(i,j) = -slopeX(i,j);
            end
        elseif thisY > fc(7,3) && thisY < fc(7,4) && thisX > fc(7,2) && thisX < fc(7,2)+dx
            %just right of house
            if slopeX(i,j) > 0
                slopeX(i,j) = -slopeX(i,j);
            end
        elseif thisX > fc(9,1) && thisX < fc(9,2) && thisY < fc(9,3) && thisY > fc(9,3)-dy
            %just below garage
            if slopeY(i,j) < 0
                slopeY(i,j) = -slopeY(i,j);
            end
        elseif thisY > fc(9,3) && thisY < fc(9,4) && thisX < fc(9,1) && thisX > fc(9,1)-dx
            %just left of garage
            if slopeX(i,j) < 0
                slopeX(i,j) = -slopeX(i,j);
            end
        elseif thisY > fc(9,3)-dy && thisY < fc(9,4) && thisX > fc(9,2) && thisX < fc(9,2)+dx
            %just right of garage
            if slopeX(i,j) > 0
                slopeX(i,j) = -slopeX(i,j);
            end
        elseif thisY < fc(4,3) && thisY > fc(4,3)-dy
            %just below sidewalk
            if slopeY(i,j) < 0
                slopeY(i,j) = -slopeY(i,j);
            end
        end
    end
end

%% 8. UNDO ALL FOR UNDEVELOPED
if developed == 0
    slopeX = zeros([ny nx]);
    slopeY = zeros([ny nx]);
    for i = 1:ny
        thisY = y(i);
        for j = 1:nx
            thisX = x(j);
            if (thisY < yU/2)
                slopeY(i,j) = landSlope;
            elseif (thisY >= yU/2)
                slopeY(i,j) = -landSlope;
            end
            if (thisX < 1.5)
                slopeX(i,j) = landSlope;
            elseif (thisX >= (xU - 1.5))
                slopeX(i,j) = -landSlope;
            end
        end
    end
end
end