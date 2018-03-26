function pointsTobeRemoved = damagedPoints(new_image, alpha)

hgaus=fspecial('gaussian',12,2); %figure,surf(hgaus)         
G1=imfilter(new_image,hgaus);
thresh = threshold_Histogram(G1,1,false);
Inew=edge(G1,'canny',[0 thresh]); %imtool(Inew)             % this threshold can be varied depending on the edges you want

disk_size=5;                                                % computing the outermost boundary of image
se = strel('disk',disk_size);
temp=imclose(Inew,se); %imtool(temp)
[moving_image,~] = largestConnectedComponent(temp,1000,false);
moving_image=bwmorph(moving_image,'thin',Inf);

% ---------------- checking for single boundary---------------------------
[B,~,~,A] = bwboundaries(moving_image,'noholes');                           
array=sum(full(A),2);                                   % conversion from sparse to full and adding rows

iter=0;
while (numel(find(array==0))>1)
    if(iter > 3)
        warning('check your edge microscopic image');
        break;
    end
    disk_size=disk_size+2;  
    se = strel('disk',disk_size);
    temp=imclose(Inew,se);%imtool(temp)
    [moving_image,~] = largestConnectedComponent(temp,1000+(iter*100),false);           % experimental code. this line              
     moving_image=bwmorph(moving_image,'thin',Inf);
    [B,~,~,A] = bwboundaries(moving_image,'noholes');                           
    array=sum(full(A),2);
    iter=iter+1;
end

clear A;
A = boundingBox(moving_image);
BW2=imfill(moving_image,'holes');
BW3=imfill(BW2,[round(A(9,2)) round(A(9,1))]);

if(numel(find(BW3==1)) == size(BW3,1)*size(BW3,2) )
    pointsTobeRemoved=[0 0];
    warning('Could not find a closed contour for damage region detection');
    disp('damaged area detection failed');
    return
end

% -------------------checking done---------------------------------

moving_image=zeros(size(moving_image));

for k=1:length(B)
    len(k) = numel(B{k});
end
id = find(len==max(len));
    
boundary = B{id};

for i=1:size(boundary,1)
  moving_image(boundary(i,1),boundary(i,2))=1;         % making a image from outermost boundary
end

% creating constrained delauy triangulation
c=[boundary(:,2) boundary(:,1)];
c(end,:)=[];

constraint(:,1)=(1:size(c,1));
constraint(:,2)=circshift(constraint(:,1),-1);      % adding constraints to the Delaunay traingulation

DT1 = delaunayTriangulation(c,constraint); 
tf = isInterior(DT1);                               % finding all the traingles which are inside the convex hull of the boundary
tf1=~tf;                                             % outside triangles

figure,triplot(DT1.ConnectivityList(tf1,:),DT1.Points(:,1),DT1.Points(:,2))
set (gca,'Ydir','reverse')

DT2=triangulation(DT1(tf1, :),DT1.Points);          % constructing a new triangulation of only points whose triangles are outside
CC=DT2.circumcenter();
ti = pointLocation(DT2,CC);
z=~isnan(ti);                                        % checking if the circumcenters are within ANY triagulation

DT3=triangulation(DT2(z, :),DT2.Points);            % constructing a new triangulation of in which the circumcenter are within any traingle

%Plot voronoi Diagram (for paper)
%voronoiImages(DT3)

pointsTobeRemoved_candi = compute_tear(DT3,alpha);

figure,imshow(new_image);hold on
for i=1:length(pointsTobeRemoved_candi)
   plot(pointsTobeRemoved_candi{i}(:,1),pointsTobeRemoved_candi{i}(:,2),'*y','Markersize',2) 
end

pointsTobeRemoved=[];

for i=1:length(pointsTobeRemoved_candi)    
    pointsTobeRemoved=[pointsTobeRemoved; pointsTobeRemoved_candi{i}];   
end

% check which pts are symmetrical along vertical axis
clear A;
bb_box = boundingBox(moving_image);

corr_image=zeros(size(moving_image));
for i=1:size(pointsTobeRemoved,1)
  corr_image(pointsTobeRemoved(i,2),pointsTobeRemoved(i,1))=1;        
end

% constructing two equal images
image1=corr_image(bb_box(1,2):bb_box(2,2),bb_box(1,1):bb_box(5,1));
image2=corr_image(bb_box(1,2):bb_box(2,2),bb_box(5,1):bb_box(8,1));
image1=fliplr(image1);
% figure,imshow(cat(3,image2,zeros(size(image1,1),size(image1,2)),image1))

[ximage_normal1,yimage_normal1]=normal_vector(image1,false);
imageorientation1=atand(yimage_normal1./ximage_normal1);
[ximage_normal2,yimage_normal2]=normal_vector(image2,false);
imageorientation2=atand(yimage_normal2./ximage_normal2);

[A,bx,by]=damage_correspondences(imageorientation1,imageorientation2);
% plot([A(:,1)';bx'],[A(:,2)';by'],'-g')

A(:,1)=(size(image1,2)+1-A(:,1))+bb_box(1,1);
A(:,2)=A(:,2)+bb_box(1,2);

bx=bx+bb_box(5,1);
by=by+bb_box(1,2);
symmetry=[A(:,1) A(:,2);bx by];

for i=1:length(pointsTobeRemoved_candi)    
    d=ismember(pointsTobeRemoved_candi{i},symmetry,'rows');  % removing points from symmetry
    if(numel(find(d==1))~=0)
        pointsTobeRemoved=setdiff(pointsTobeRemoved,pointsTobeRemoved_candi{i},'rows');
    end
end

A1=pointsTobeRemoved(:,1)-1;          % creating a 3x3 neighbourhood of the pointsTobeRemoved
A2=pointsTobeRemoved(:,1)+1;
A3=pointsTobeRemoved(:,1);
B1=pointsTobeRemoved(:,2)+1;
B2=pointsTobeRemoved(:,2)-1;
B3=pointsTobeRemoved(:,2);

pointsTobeRemoved=[[A1 B1];[A1 B2];[A1 B3];[A2 B1];[A2 B2];[A2 B3];[A3 B1];[A3 B2];[A3 B3]];

figure,imshow(new_image);hold on;
plot(pointsTobeRemoved(:,1),pointsTobeRemoved(:,2),'c*','MarkerSize',4)



