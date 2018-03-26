function [A,bx,by] = outlierRemoval(I,Inew,edge_atlas,atlasorientation,A,bx,by,selection)
% removing points due to symmetry
% The returned points are less than the input

% normal vector computation for image & atlas
[ximage_normal,yimage_normal]=normal_vector(Inew,false);
imageorientation=atand(yimage_normal./ximage_normal);

imageorientation(isnan(imageorientation))=0;
atlasorientation(isnan(atlasorientation))=0;


remove=false(size(A,1),1);

for k=1:size(A,1)
    
       i=A(k,2); j=A(k,1); 
    
       Imagekernel=imageorientation(i-3:i+3,j-3:j+3);           % 5 by 5 neighbourhood of image
       
       i=by(k,1); j=bx(k,1);
       
       Atlaskernel=atlasorientation(i-3:i+3,j-3:j+3); 
       
       diff=(Imagekernel-Atlaskernel);
       temp=diff.^2;
       val=sqrt(sum(temp(:)));
       
       if (val > 160)                                            % testing condition using threshold as 10
           remove(k,1)=true;
       end
end


if(selection==true)
   plotting_PointCorresponce(I,edge_atlas,A(remove,:),bx(remove,:),by(remove,:),false)
 end

A(remove,:)=[];
bx(remove,:)=[];
by(remove,:)=[];

end