function [warped_image,num_of_Corres,transf_Matrices,thresh3]=icp_registration(new_image,edge_atlas,atlasorientation,flag,edgepath)

disp('ICP registration');

distance=[200 100 50 25];   % without MLS
angle=[10 8 6 4];
num_of_Corres=zeros(length(distance),1);
    
for iter=1:4                            

I=new_image(:,:,flag); %imtool(I)
    
% median filtering
G0=medfilt2(I,[20 20]); %imtool(G0)  

% filtering & smoothening   
hgaus=fspecial('gaussian',12,2); %figure,surf(hgaus)         
                                                             % curves in the next step normal computation). 
G1=imfilter(G0,hgaus); %imtool(G1)

if(iter==1)                                                  % Only compute this threshold one time                         
thresh3 = threshold_Histogram(G1,2,false);                   % Very important   
end

% edge detection
Inew=edge(G1,'canny',[0 thresh3]); %imtool(Inew)             % this threshold can be varied depending on the edges you want
Inew=remove_HoriVeriLines(Inew,50); %imtool(Inew)

% connected componenet of >300 pixels.
[Inew,~] = largestConnectedComponent(Inew,300,false);       % if you are reducing the canny threshold then this has to be increased to keep the dominant curves

% alignment visualization for only the curves
% figure,imshow(cat(3,edge_atlas,Inew,zeros(size(Inew))));

imwrite(Inew,fullfile(edgepath,sprintf('3_%2d_ICP_edgeImage_whoseNormalVectors_areMatched.jpg',iter))); % storing the edge image for testing

% normal vector computation
[ximage_normal,yimage_normal]=normal_vector(Inew,false);

% computing orientation of normal vectors.(angles of the normal vectors)
imageorientation=atand(yimage_normal./ximage_normal);

% finding correspondence and plotting them
[A,bx,by]=find_PointCorrespondence(imageorientation,atlasorientation,distance(iter),angle(iter));  
% plotting_PointCorresponce(I,edge_atlas,A,bx,by,true)

% removing outliers
[A1,bx1,by1] = outlierRemoval(I,Inew,edge_atlas,atlasorientation,A,bx,by,false);

% for computing the distance threshold for final correspondence;
num_of_Corres(iter)=size(A1,1) + str2double(sprintf('0.%d',size(A,1)-size(A1,1)));

% Linear warping
[new_image,T] = image_warping(A1,bx1,by1,edge_atlas,new_image);    
transf_Matrices{iter}=T;

end

warped_image=new_image;

end




