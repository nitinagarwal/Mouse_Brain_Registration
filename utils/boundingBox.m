function A = boundingBox(image)
% Find the bounding box of a binary image

[row,col]=find(image==1);
bottom=max(row);
if(mod(bottom,2)~=0)
    bottom=bottom+1;
end

top=min(row);
if(mod(top,2)~=0)
    top=top-1;
end

left=min(col);
if(mod(left,2)~=0)
    left=left-1;
end

right=max(col);
if(mod(right,2)~=0)
    right=right+1;
end
% four corners
A(1,:)=[left top 1]; 
A(2,:)=[left bottom 1];
A(3,:)=[right top 1]; 
A(4,:)=[right bottom 1];
% 4 center edges
A(5,:)=[((right-left)/2+left) top 1];
A(6,:)=[((right-left)/2+left) bottom 1];
A(7,:)=[left ((bottom-top)/2+top) 1];
A(8,:)=[right ((bottom-top)/2+top) 1];
% center image
A(9,:)=[((right-left)/2+left) ((bottom-top)/2+top) 1];


