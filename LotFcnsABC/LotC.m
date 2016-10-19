function [fc,parcelCover,used] = LotC(dx,dy,nx,ny,x,y,triggers,details)
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

%% INPUTS
developed = triggers(1);
downspout = triggers(2);
sidewalk = triggers(3);

dsLength = details(6);
sidewalkOffset = details(7)*sidewalk;

%% FEATURE SIZES (enter in meters)
%Street = 1
streetLength = 5;

%Domain
parcelWidth = xU;
parcelLength = 35;

%Alley = 2
alleyLength = 2;

%Parking Lot = 3
%unused

%Sidewalk = 4
sidewalkLength = 1;
sidewalkOffset = sidewalkOffset;

%Driveway = 5
drivewayRightSetback = 2;
drivewayWidth = 2.5;
drivewayLength = 22;

%Frontwalk = 6
frontwalkWidth = 0.5;
frontwalkLeftSetback = 5.5;

%House = 7
sideLeftSetback = 2.5;
sideRightSetback = 5;
houseWidth = 6;
houseLength = 9;
frontSetback = 5;

%House2 = 8
%unused

%Garage = 9
garageRightSetback = 0.5;
garageWidth = 5;
garageLength = 6.5;


%% FEATURE COORDINATES
fc = zeros([9,4]);
used = [1 2 4 5 6 7 9];

%Street = 1
fc(1,1) = 0;                              %Left X
fc(1,2) = parcelWidth;                    %Right X
fc(1,3) = 0;                              %Lower Y
fc(1,4) = streetLength;                   %Upper Y

%Alley = 2
fc(2,1) = 0;                              %Left X
fc(2,2) = parcelWidth;                    %Right X
fc(2,3) = streetLength + parcelLength;    %Lower Y
fc(2,4) = fc(2,3) + alleyLength;          %Upper Y

%Parking Lot = 3
%unused

%Sidewalk = 4
fc(4,1) = 0;                              %Left X
fc(4,2) = parcelWidth;                    %Right X
fc(4,3) = streetLength + sidewalkOffset;  %Lower Y
fc(4,4) = fc(4,3) + sidewalkLength;       %Upper Y

%Driveway = 5
fc(5,1) = parcelWidth-drivewayRightSetback-drivewayWidth; %Left X     
fc(5,2) = parcelWidth-drivewayRightSetback; %Right X
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
%unused

%Garage = 9
fc(9,1) = parcelWidth-garageRightSetback-garageWidth; %Left X
fc(9,2) = fc(9,1) + garageWidth; %Right X
fc(9,3) = streetLength+drivewayLength; %Lower Y
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
        if (downspout == 1)
            if (thisX <= (fc(9,2)-dx)) && (thisX > (fc(9,2)-2*dx)) &&...
                    (thisY <= fc(9,3)) && (thisY >= fc(9,3)-dsLength)
                parcelCover(i,j) = 4; %Lower garage downspout
            elseif (thisY <= (fc(9,4)-dy)) && (thisY >= (fc(9,4)-2*dy)) &&...
                    (thisX <= fc(9,1)) && (thisX >= (fc(9,1)-dsLength))
                parcelCover(i,j) = 4; %Upper garage downspout
            elseif ( ((thisX <= (fc(7,1)+2*dx)) && (thisX > (fc(7,1)+dx))) ||...
                    ((thisX >= (fc(7,2)-2*dx)) && (thisX < (fc(7,2)-dx))) ) &&...
                    ( ((thisY > fc(7,4)) && (thisY <= (fc(7,4)+dsLength))) ||...
                    ((thisY < fc(7,3)) && (thisY >= (fc(7,3)-dsLength))) )
                parcelCover(i,j) = 4; %House downspouts
            end
        elseif (downspout == 0)
            if (thisX > fc(9,2)) && (thisY > (fc(9,3)+2*dy)) && (thisY < (fc(9,3)+3*dy))
                parcelCover(i,j) = 4;
            elseif (thisX < fc(7,1)) && (thisY > (fc(7,4)-3*dy)) && (thisY < (fc(7,4)-2*dy))
                parcelCover(i,j) = 4;
            end
        end
    end
end

if developed == 0
    fc = zeros([9,4]);
    parcelCover = zeros([ny,nx]);
end

end

    

