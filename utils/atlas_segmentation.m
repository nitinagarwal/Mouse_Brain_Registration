function edge_image = atlas_segmentation(image)
% contour extraction from colored atlas images. 
% Only these contours will be used for registration.

image1=double(image);

cord1=find(image1(:,:,1)==255 & image1(:,:,2)==255 & image1(:,:,3)==255); % takes out only black

cord2=find(abs(image1(:,:,1)-image1(:,:,2))<=25 & abs(image1(:,:,2)-image1(:,:,3))<=25 & ...
            abs(image1(:,:,1)-image1(:,:,3))<=25);                            % takes out black+white+gray

im4=zeros(size(image1(:,:,1),1),size(image1(:,:,1),2));
im4(setdiff(cord2,cord1))=1;                                                 % only white and gray   

[im4,~]=largestConnectedComponent(im4,round(size(image,1)/0.625),false);     % removing small unnesccary portions in the segmented atlas image
edge_image=edge(im4,'canny');
% figure,imshow(edge_image)



end