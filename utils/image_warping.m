function [new_image,T] = image_warping(A,bx,by,atlasnormimage,I)
% Input:
% A=mx3 matrix; A is the points whose correspondence are in bx and by.
% bx=mx1 matrix; x coordinates of the matched points in the atlas
% by=mx1 matrix; y coordinates of the matches points in the atlas
% atlasnorimage; is row x col logical atlas image
% I = Warped image from previous iteration which is to be warped again in the next iteration. 
% size of the image >= size of atlas  
%
% Output:
% outputimage: warped output image. (size of atlas)
% T: transformation matrix used to warp I
% For interpolation we are computing a delauny traingulation and then
% interpolating(refer to scatteredinterpolation documentation in matlab)

% computing the transformation matrix T
[U,S,V]=svd(A,0);
q = V*(S\(U'*bx));
r = V*(S\(U'*by));

T=[q';r'];

[r,c]=size(atlasnormimage); % points where we want interpolated values. Has to be atlas points
[xq,yq]=meshgrid(1:c,1:r);

[r1,c1,~]=size(I);          % because my microscope image can or cannot be of same size as atlas image
[x,y]=meshgrid(1:c1,1:r1);    
x=reshape(x,[],1);
y=reshape(y,[],1);

% doing the transformation
imagecordold=[x';y';ones(length(x),1)'];
imagecordnew=T*imagecordold;

x=imagecordnew(1,:)';
y=imagecordnew(2,:)';

tic
parfor i=1:3
F = scatteredInterpolant(x,y,reshape(double(I(:,:,i)),[],1),'linear','none');
new_image(:,:,i)=F(xq,yq);
end
fprintf('Time for image warping is %f secs \n',toc) 

new_image=uint8(new_image);

end