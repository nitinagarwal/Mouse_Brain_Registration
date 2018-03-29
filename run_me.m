% Input parameters

% Make sure your input image is well centered (i.e. the MI slice is not
% touching the boundary and there is enough gap)

% use overlap_image() to see the overlap after warping.

% change parameters for threshold_Histogram() depending on the noise in your dataset. Read the paper for more details. 

% The code is modular. Hence comment/switch the module if its not required.
% The code is well commented as well for easy of use/modification. Also use
% the aux folders for debugging.

% The final non-linear transfromation uses Laplace Equations, can be easily
% replaced to cubic B-spline depending on the applicatin. 

channelInfo=2;     % channel used for registration (v.imp)
alpha=50;          % medial_axis length (edge_length)
thresh1=0;
R=0;               % no rotation              

if(isempty(gcp('nocreate'))==1)
    parpool;                                        
end
warning('off','all')

%% ---------------------------Reading data from file--------------------------
base_dir=pwd;
addpath(genpath(base_dir))

mkdir(fullfile(base_dir,'registered_images'));          % aux folders to store data to debug
mkdir(fullfile(base_dir,'info'));
mkdir(fullfile(base_dir,'overlap_images'));
mkdir(fullfile(base_dir,'dump(edge_images)'));
wdir=fullfile(base_dir,'registered_images');             % for writing the registered images
txt_dir=(fullfile(base_dir,'info'));                     % for writing the data into text file
overlapdir=fullfile(base_dir,'overlap_images');          % for storing the overlaped images
edge_dir = fullfile(base_dir,'dump(edge_images)');       % for storing the edge images-for testing histogram threshold


rdir=(fullfile(base_dir,'data'));                                   

dirinfo=dir(fullfile(rdir,'/img*tif'));                 % sorting the MI images
for i=1:length(dirinfo)
    name1{i}=dirinfo(i).name;
end
sortedImages=sort(name1);
    
dirinfo=dir(fullfile(rdir,'/atlas*tif'));               % sorting the AI images
for i=1:length(dirinfo)
    name2{i}=dirinfo(i).name;
end
sortedAtlas=sort(name2);

%% Registration 
for sliceNum=1:length(sortedImages) 

disp(['Matching ',num2str(sortedImages{sliceNum}),' microscopic slice to ',num2str(sortedAtlas{sliceNum}),' atlas slice']); 
image=imread(fullfile(rdir,sortedImages{sliceNum}));
atlas=imread(fullfile(rdir,sortedAtlas{sliceNum}));
edgepath=fullfile(edge_dir,sprintf('%04d',sliceNum));
mkdir(edgepath);

I=image;
edge_atlas=atlas_segmentation(atlas); 
[xatlas_normal,yatlas_normal]=normal_vector(edge_atlas,false);
atlasorientation=atand(yatlas_normal./xatlas_normal);


%------------------------Rotation Correction----------------------------
% [warped_image,thresh1,R] = rotation_alignment(I,edge_atlas,channelInfo,edgepath);
% figure('Name','AFTER_ROTATION'),imshow(warped_image)

%------------------------Bounding Box Alignment(Scaling & Translation)-----
[warped_image,thresh2,T] = bb_alignment(I,edge_atlas,channelInfo,edgepath);
% figure('Name','AFTER_BOUNDINGBOX'),imshow(warped_image)
 
%---------------------------ICP registration--------------------
[warped_image,num_of_Corres,transf_Matrices,thresh3] = icp_registration(warped_image,edge_atlas,atlasorientation,channelInfo,edgepath);
imwrite(warped_image+(255-atlas),fullfile(edgepath,'4_After_all_warping.jpg')); 


%---------------------------Final Correspondence--------------------------
[output_image,finalCorresNum,thresh4] = final_registration(warped_image,edge_atlas,atlasorientation,channelInfo,alpha, edgepath);

close all
pause(1);

imwrite(output_image,fullfile(wdir,sortedImages{sliceNum}),'tif');
t=rgb2gray(atlas);
t=edge(t,'canny');
t=largestConnectedComponent(t,500,false);
t=uint8(t*255);
overlap_atlas=cat(3,t,t,t);
imwrite((output_image+overlap_atlas),fullfile(overlapdir,sortedImages{sliceNum}),'tif');


%---------------------------Writing_Data_to_Files--------------------------
save(fullfile(edgepath,'imageData.mat'),'warped_image','output_image','atlas'); 
ind_txtdir=fullfile(txt_dir,regexprep(sortedImages{sliceNum},'.tif','.txt')); 

fileID = fopen(ind_txtdir,'w');
fprintf(fileID,'\nThresholds:\n');
fprintf(fileID,'thresh1: %f\t thresh2: %f\t thresh3: %f\t thresh4: %f\t\n',...
    thresh1,thresh2,thresh3,thresh4);
fprintf(fileID,'\n#Correspondences: %f %f %f %f #finalCorres %f\n',num_of_Corres(1),num_of_Corres(2),...
    num_of_Corres(3),num_of_Corres(4),finalCorresNum);
fprintf(fileID,'\nRotation Angle: %f\n',R);
fprintf(fileID,'\nInitial Bounding_Box_Transformation:\n');
dlmwrite(ind_txtdir,T,'-append','delimiter','\t','precision','%.4f');
fclose(fileID);

fileID = fopen(ind_txtdir,'a');
fprintf(fileID,'\nICP_transformations:\n\n');
dlmwrite(ind_txtdir,transf_Matrices{1},'-append','delimiter','\t','precision','%.4f');
fprintf(fileID,'\n');
dlmwrite(ind_txtdir,transf_Matrices{2},'-append','delimiter','\t','precision','%.4f');
fprintf(fileID,'\n');
dlmwrite(ind_txtdir,transf_Matrices{3},'-append','delimiter','\t','precision','%.4f');
fprintf(fileID,'\n');
dlmwrite(ind_txtdir,transf_Matrices{4},'-append','delimiter','\t','precision','%.4f');
fclose(fileID);

end

