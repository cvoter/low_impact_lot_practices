function [x,xL,xU,y,yL,yU,X,Y,fc,parcelCover,used] = Town(dx,dy,nx,ny,sidewalkOffset,downspout,dsLength)
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
streetLength = 5;

%Domain
parcelWidth = xU;
parcelLength = 23;

%Alley = 2
%unused

%Parking Lot = 3
parkingLotLength = 3.5;

%Sidewalk = 4
sidewalkLength = 1;
sidewalkOffset = sidewalkOffset;

%Driveway = 5
%unused

%Frontwalk = 6
frontwalkWidth = 0.5;
frontwalkLength = 5;
frontwalkLeftSetback = 10;
frontwalkSpace = 16.5;

%House = 7
frontSetback = 6;
sideLeftSetback = 2;
sideRightSetback = 2;
houseWidth = 51;
houseLength = 10;
duWidth = houseWidth/6;

%House2 = 8
%unused

%Garage = 9
%unused


%% FEATURE COORDINATES
fc = zeros([11,4]);
used = [1 3 4 6 7 10 11];

%Street = 1
fc(1,1) = 0;                              %Left X
fc(1,2) = parcelWidth;                    %Right X
fc(1,3) = 0;                              %Lower Y
fc(1,4) = streetLength;                   %Upper Y

%Alley = 2
%unused

%Parking Lot = 3
fc(3,1) = 0;                              %Left X
fc(3,2) = parcelWidth;                    %Right X
fc(3,3) = streetLength;                   %Lower Y
fc(3,4) = streetLength+parkingLotLength;  %Upper Y

%Sidewalk = 4
fc(4,1) = 0;                              %Left X
fc(4,2) = parcelWidth;                    %Right X
fc(4,3) = streetLength + parkingLotLength + sidewalkOffset;  %Lower Y
fc(4,4) = fc(4,3) + sidewalkLength;       %Upper Y

%Driveway = 5
%unused

%Frontwalk = 6
fc(6,1) = frontwalkLeftSetback;         %Left X
fc(6,2) = fc(6,1) + frontwalkWidth;     %Right X
fc(6,3) = fc(4,4);                      %Lower Y
fc(6,4) = streetLength + parkingLotLength + frontSetback;  %Upper Y

%House = 7
fc(7,1) = sideLeftSetback;              %Left X
fc(7,2) = fc(7,1) + houseWidth;         %Right X
fc(7,3) = streetLength + parkingLotLength + frontSetback;  %Lower Y
fc(7,4) = fc(7,3) + houseLength;        %Upper Y

%House2 = 8
%unused

%Garage = 9
%unused

%Frontwalk2 = 10
fc(10,1) = fc(6,2) + frontwalkSpace;     %Left X
fc(10,2) = fc(10,1) + frontwalkWidth;    %Right X
fc(10,3) = fc(4,4);                      %Lower Y
fc(10,4) = streetLength + parkingLotLength + frontSetback;  %Upper Y

%Frontwalk3 = 11
fc(11,1) = fc(10,2) + frontwalkSpace;     %Left X
fc(11,2) = fc(11,1) + frontwalkWidth;    %Right X
fc(11,3) = fc(4,4);                      %Lower Y
fc(11,4) = streetLength + parkingLotLength + frontSetback;  %Upper Y

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
                if parcelCover(i,j) >= 10
                    parcelCover(i,j) = 6;
                end
            end
        end
        if (downspout == 2) &&...
                ( ( (thisX > (fc(7,1)+dx) && (thisX < fc(7,1)+2*dx))...
                || (thisX > (fc(7,1)+duWidth+dx) && thisX < (fc(7,1)+duWidth+2*dx))...
                || (thisX > (fc(7,1)+2*duWidth+dx) && thisX < (fc(7,1)+2*duWidth+2*dx))...
                || (thisX > (fc(7,1)+3*duWidth+dx) && thisX < (fc(7,1)+3*duWidth+2*dx))...
                || (thisX > (fc(7,1)+4*duWidth+dx) && thisX < (fc(7,1)+4*duWidth+2*dx))...
                || (thisX > (fc(7,1)+5*duWidth+dx) && thisX < (fc(7,1)+5*duWidth+2*dx)) )...
                && ( (thisY < fc(7,3) && thisY >=fc(7,3)-dsLength) ||...
                (thisY >= fc(7,4) && thisY < fc(7,4)+dsLength) ) )
            parcelCover(i,j) = 6;
        elseif (downspout == 3)...
                && (thisX < fc(7,1) || thisX > fc(7,2))...
                && (thisY > ((fc(7,4)+fc(7,3))/2) && thisY < ((fc(7,4)+fc(7,3))/2 + dy))
            parcelCover(i,j) = 6;
        end
    end
end



end

    

