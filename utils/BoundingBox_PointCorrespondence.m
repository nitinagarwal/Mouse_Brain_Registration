function [A,bx,by]=BoundingBox_PointCorrespondence(image_edge,atlas_edge)
% aligning the bounding boxes of both the images
% input is the edge image(>200 components) of the microscope image and
% atlas image. Both are logical images
% correspondence output of the form A*T=b where T is the transformation matrix (6 elements) 
% A=[x of image, y of image, 1] and bx = [matched x coordinate of atlas] and by = [matched y coordinate of atlas] 

[row,col]=find(image_edge==1);

bottom=max(row);
top=min(row);
left=min(col);
right=max(col);

[row,col]=find(atlas_edge==1);

bottom1=max(row);
top1=min(row);
left1=min(col);
right1=max(col);

% Correspondences for corner and center points of the bounding boxes
% four corners
A(1,:)=[left top 1]; bx(1,:)=left1; by(1,:)=top1;
A(2,:)=[left bottom 1]; bx(2,:)=left1; by(2,:)=bottom1;
A(3,:)=[right top 1]; bx(3,:)=right1; by(3,:)=top1;
A(4,:)=[right bottom 1]; bx(4,:)=right1; by(4,:)=bottom1;

% 4 center edges
A(5,:)=[((right-left)/2+left) top 1]; bx(5,:)=((right1-left1)/2+left1); by(5,:)=top1;
A(6,:)=[((right-left)/2+left) bottom 1]; bx(6,:)=((right1-left1)/2+left1); by(6,:)=bottom1;
A(7,:)=[left ((bottom-top)/2+top) 1]; bx(7,:)=left1; by(7,:)=((bottom1-top1)/2+top1);
A(8,:)=[right ((bottom-top)/2+top) 1]; bx(8,:)=right1; by(8,:)=((bottom1-top1)/2+top1);

% center image
A(9,:)=[((right-left)/2+left) ((bottom-top)/2+top) 1]; bx(9,:)=((right1-left1)/2 + left1); by(9,:) = ((bottom1-top1)/2 + top1);


end