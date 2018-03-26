function [rotated_image,thresh2,difference]=rotation_alignment(new_image, edge_atlas,flag,edgepath)

disp('Rotation Correction');

I=new_image(:,:,flag); %imtool(I)
    
% median filtering
G0=medfilt2(I,[20 20]); %imtool(G0)  

% filtering & smoothening   
hgaus=fspecial('gaussian',12,2); %figure,surf(hgaus)    
G1=imfilter(G0,hgaus);

% Computed the threshold for hysterisis to be used for canny edge  
thresh2 = threshold_Histogram(G1,2,false);                          % Very important. Its lower than bounding box becuase I need the boundary curves.   

% edge detection
Inew=edge(G1,'canny',[0 thresh2]); %imtool(Inew)
Inew=remove_HoriVeriLines(Inew,50); %imtool(Inew)
 
% Rotation Correction
difference=Rotation_Calculations(Inew,edge_atlas,edgepath);

new_image=padarray(new_image,[200 200],0);          
new_image=imrotate(new_image,difference,'crop');
rotated_image=new_image(200:size(new_image,1)-200-1,200:size(new_image,2)-200-1,:);

end



function difference = Rotation_Calculations(Inew,edge_atlas,edgepath)

ymid_image=(size(Inew,1)/2);
xmid_image=(size(Inew,2)/2);

[Inew,~] = largestConnectedComponent(Inew,100,false);  % remove any debris 

imwrite(Inew,fullfile(edgepath,'1_Rotation_edgeImage_used_for_ConvexHull.jpg')); % storing the edge image for testing

[rows1,cols1]=find(Inew==1);
k1=convhull(cols1,rows1);                           % computing the convex hull
new1=interparc(1000,cols1(k1),rows1(k1),'linear');  % resampling the convex hull at equal intervals (1000 points)

figure,plot(cols1,rows1,'b*'); %original points
hold on
plot(new1(:,1),new1(:,2),'g*') % resampled convex hull
set(gca,'Ydir','reverse')

B1=[new1(:,1)-xmid_image new1(:,2)-ymid_image]';    % centering the points
[U1,~,~]=svd(B1);                                   % SVD
U1=U1(:,2);                                         % orientation of the image

%---------same thing for atlas-----------------
ymid_atlas=(size(edge_atlas,1)/2);
xmid_atlas=(size(edge_atlas,2)/2);

% convex hull of atlas image
[rows,cols]=find(edge_atlas==1);

k=convhull(cols,rows);                              % computing the convex hull
new=interparc(1000,cols(k),rows(k),'linear');       % resampling the convex hull into equal intervals(1000 points)

figure,plot(cols,rows,'b*'); %original points
hold on
plot(new(:,1),new(:,2),'g*') % resampled convex hull
set(gca,'Ydir','reverse')

B=[new(:,1)-xmid_atlas new(:,2)-ymid_atlas]';
[U,~,~]=svd(B);                                     % SVD
U=U(:,2);                                           % orientation of the atlas. (usually around 90)

%------------angle difference-------------------
angle_between = acosd(dot(U,U1));
difference = -angle_between;

end


