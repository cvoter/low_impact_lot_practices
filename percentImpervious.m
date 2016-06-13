%Calculate percent impervious

domainArea = dx*dy*nx*ny;

imperCount=0;
for i=1:ny
    for j=1:nx
        if parcelCover(i,j) > 0
            imperCount = imperCount + 1;
        end
    end
end
imperArea = imperCount*dx*dy;
round(imperArea*100/domainArea)