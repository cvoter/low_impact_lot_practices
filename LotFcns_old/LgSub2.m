function [x,xL,xU,y,yL,yU,X,Y,fc,parcelCover,used] = LgSub2(dx,dy,nx,ny,sidewalkOffset,downspout,dsLength)
%Creates a 2D matrix the size of PF computaitonal grid with different keys for
%each parcel feature. Also outputs matrix with coordinates of feature
%corners, format:
%   [leftX rightX lowerY upperY]
%where coordinates for parcel cover key = i can be found in row i

%INPUTS
%sidewalkOffset and downspoutDisconnect must be in meters.

%KEY
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

%% SPECIFY DOMAIN
xL = 0; xU = xL+dx*nx;  x0 = xL+dx/2;   xf = xU-dx/2;
x = x0:dx:xf;

yL = 0; yU = yL+dy*ny;  y0 = yL+dy/2;   yf = yU-dy/2;
y = y0:dy:yf;

[X,Y] = meshgrid(x,y);

%% FEATURE SIZES (enter in meters)
%Street = 1
streetLength = 6;

%Domain
parcelWidth = xU;
parcelLength = yU-streetLength;

%Alley = 2
%unused

%Parking Lot = 3
%unused

%Sidewalk = 4
sidewalkLength = 1;
sidewalkOffset = sidewalkOffset;

%Driveway = 5
frontSetback = 12;
drivewayLeftSetback = 6.5;
drivewayWidth = 5;
drivewayLength = frontSetback + 1;

%Frontwalk = 6
frontwalkLeftSetback = 12 + 3;
frontwalkWidth = 0.5;

%House = 7
sideLeftSetback = 12;
sideRightSetback = 5.5;
houseWidth = 7;
houseLength = 14.5;

%House2 = 8
sideLeftSetback2 = 5.5;
sideRightSetback2 = 12.5;
houseWidth2 = 13.5-houseWidth;
houseLength2 = houseLength - 8 - 1;

%Garage = 9
garageLeftSetback = 5.5;
garageWidth = houseWidth2;
garageLength = 8;


%% FEATURE COORDINATES
fc = zeros([9,4]);
used = [1 4 5 6 7 8 9];

%Street = 1
fc(1,1) = 0;                              %Left X
fc(1,2) = parcelWidth;                    %Right X
fc(1,3) = 0;                              %Lower Y
fc(1,4) = streetLength;                   %Upper Y

%Alley = 2
%unused

%Parking Lot = 3
%unused

%Sidewalk = 4
fc(4,1) = 0;                              %Left X
fc(4,2) = parcelWidth;                    %Right X
fc(4,3) = streetLength + sidewalkOffset;  %Lower Y
fc(4,4) = fc(4,3) + sidewalkLength;       %Upper Y

%Driveway = 5
fc(5,1) = drivewayLeftSetback;          %Left X     
fc(5,2) = fc(5,1) + drivewayWidth;      %Right X
fc(5,3) = streetLength;                 %Lower Y
fc(5,4) = fc(5,3) + drivewayLength;     %Upper Y

%Frontwalk = 6
fc(6,1) = frontwalkLeftSetback;         %Left X
fc(6,2) = fc(6,1) + frontwalkWidth;     %Right X
fc(6,3) = fc(4,4);                      %Lower Y
fc(6,4) = streetLength + frontSetback;  %Upper Y

%House = 7
fc(7,1) = sideLeftSetback;              %Left X
fc(7,2) = fc(7,1) + houseWidth;         %Right X
fc(7,3) = streetLength + frontSetback;  %Lower Y
fc(7,4) = fc(7,3) + houseLength;        %Upper Y

%House2 = 8
fc(8,1) = sideLeftSetback2;              %Left X
fc(8,2) = fc(8,1) + houseWidth2;         %Right X
fc(8,3) = streetLength + drivewayLength + garageLength;  %Lower Y
fc(8,4) = fc(8,3) + houseLength2;        %Upper Y

%Garage = 9
fc(9,1) = garageLeftSetback;            %Left X
fc(9,2) = fc(9,1) + garageWidth;        %Right X
fc(9,3) = fc(5,4);                      %Lower Y
fc(9,4) = fc(9,3) + garageLength;       %Upper Y

%% PARCEL COVER
parcelCover = zeros([ny,nx]);
for i = 1:ny
    thisY = y(i);
    for j = 1:nx
        thisX = x(j);
        for k = used %Loop through used feature types
            if (thisX >= fc(k,1)) && (thisX <= fc(k,2)) &&...
                    (thisY >= fc(k,3)) && (thisY <= fc(k,4))
                parcelCover(i,j) = k;
            end
        end
        if (downspout == 2) &&...
                ( ( (thisX <= (fc(9,1)+2*dx)) && (thisX > (fc(9,1)+dx)) ) ||...
                ( (thisX <= (fc(7,1)+2*dx)) && (thisX > (fc(7,1)+dx)) ) ||...
                ( (thisX >= (fc(7,2)-2*dx)) && (thisX < (fc(7,2)-dx)) ) )
            %Backyard downspouts
            if (thisY > fc(7,4)) && (thisY <= (fc(7,4)+dsLength))
                parcelCover(i,j)=6;
            %Frontyard house downspouts
            elseif (thisX > fc(9,2)) && (thisY < fc(7,3)) && (thisY >= fc(7,3)-dsLength)
                parcelCover(i,j)=6;
            %Frontyard garage downspouts
            elseif (thisX < fc(9,2)) && (thisY < fc(9,3)) && (thisY >= fc(9,3)-dsLength)
                parcelCover(i,j)=6;
            end
        elseif (downspout == 3) &&...
                (thisX <= fc(9,1)) && (thisY >= fc(9,4)-3*dy) && (thisY <= fc(9,4)-2*dy)
            parcelCover(i,j) = 6;
        end
    end
end



end

    

