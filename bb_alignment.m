function [warped_image,thresh1,T]=bb_alignment(new_image,edge_atlas,flag,edgepath,varargin)
% can take a user defined threshold (esp after rotation) varargin=thresh1

disp('Aligning Bounding Box');

% considering the second channel as it has the max information only for xinagming datas
I=new_image(:,:,flag); %imtool(I) 

% median filtering
G0=medfilt2(I,[20 20]); %imtool(G0)  

% Gaussian filtering    
hgaus=fspecial('gaussian',12,2); %figure,surf(hgaus)       
                                                            % curves in the next step normal computation). 
G1=imfilter(G0,hgaus); %imtool(G1)

if(isempty(varargin))
% Compute the threshold for hysterisis to be used for canny edge detector  
thresh1 = threshold_Histogram(G1,2,false);                   % Very important interval_size = 2
else
thresh1=varargin{1};
end

% edge detection
Inew=edge(G1,'canny',[0 thresh1]); %imtool(Inew)             
Inew=remove_HoriVeriLines(Inew,50); %imtool(Inew)

% connected componenet of >400 pixels.
[Inew,~] = largestConnectedComponent(Inew,250,false);        
                            
imwrite(Inew,fullfile(edgepath,'2_BoundingBox_edgeImage_whose_BB_areMatched.jpg')); % storing the edge image for testing

% Bounding box correspondences
[A,bx,by]=BoundingBox_PointCorrespondence(Inew,edge_atlas);

% Linear warping
[warped_image,T] = image_warping(A,bx,by,edge_atlas,new_image);

end
