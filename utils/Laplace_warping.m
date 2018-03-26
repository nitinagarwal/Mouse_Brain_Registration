function output_image = Laplace_warping(A,bx,by,atlasnormimage,I)
%---------------Final Laplace transform------------------------------------
% Input:
% A=mx3 matrix; A is the points whose correspondence are in bx and by.
% bx=mx1 matrix; x coordinates of the matched points in the atlas
% by=mx1 matrix; y coordinates of the matches points in the atlas
% atlasnorimage; is row x col logical atlas image
% I = Warped image from previous iteration which is to be warped again in the next iteration. Has the same size as atlas image.
%
% Output:
% outputimage: warped output image.
% For interpolation we are computing a delauny traingulation and then
% interpolating(refer to scatteredinterpolation documentation in matlab)

% creating three images. boundary, xdis, ydis
boundary=zeros(size(I,1),size(I,2));                            % microscope image having pixel value 1 where we have correspondece

for index=1:length(A)
    boundary(A(index,2),A(index,1))=1;
end

xdis=zeros(size(I,1),size(I,2)); 
ydis=zeros(size(I,1),size(I,2));

for index=1:length(bx)
    
    xdis(A(index,2),A(index,1))= bx(index) - A(index,1);        % x and y displacement images
    
    ydis(A(index,2),A(index,1))= by(index) - A(index,2);
end

[Lx, Ly]=solveLaplace(xdis,ydis,int32(boundary));               % Laplace Transform

x=zeros(size(I(:,:,1)));
y=zeros(size(I(:,:,1)));

for i=1:size(Lx,1)                           % rows of the microscope image
    for j=1:size(Lx,2)                       % columns of the microscope image
               
        y(i,j)= i+Ly(i,j) ;
        x(i,j)= j+Lx(i,j) ;

    end
end

[r,c]=size(atlasnormimage);
[xq,yq]=meshgrid(1:c,1:r);

x=reshape(x,[],1);
y=reshape(y,[],1);

tic
parfor i=1:3
F = scatteredInterpolant(x,y,reshape(double(I(:,:,i)),[],1),'linear','none');
output_image(:,:,i) =F(xq,yq);
end
fprintf('Time for laplace warping is %f secs \n',toc) 

output_image=uint8(output_image);

end

