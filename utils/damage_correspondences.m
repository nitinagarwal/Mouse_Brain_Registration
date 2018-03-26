function [A,bx,by]=damage_correspondences(imageorientation,atlasorientation)
% using single point matching. 
% input is the orientation image of the two symmetric images
% which is atand(ynormal./xnormal)
% correspondence output of the form A*T=b where T is the transformation matrix (6 elements) 
% A=[x of image, y of image, 1] and bx = [matched x coordinate of atlas] and by = [matched y coordinate of atlas] 
% THIS FUNCTION INTIALLY SEARCHES FOR POINTS IN THE ATLAS SPACE WHICH ARE
% NEAR (WITHIN A THRESHOLD) THE IMAGE POINT. HENCE NARROWING THE SEARCH
% SPACE. The output of this is all the good/final/true correspondences
% (hence they are slightly less) have parallelized the code for speed up.

tic
totalIterations=find(isnan(imageorientation)==0);        % only valid positions in image

A=zeros(length(totalIterations),3);                      % predefining them then removing the zeros.
bx=zeros(length(totalIterations),1);
by=zeros(length(totalIterations),1);

parfor tIter=1:length(totalIterations)

[i,j]=ind2sub(size(imageorientation),totalIterations(tIter));
        
        % Initial reduction of search space.
        actual_values = find(isnan(atlasorientation)==0);                     % finding valid positions in atlas
        [y,x]=ind2sub(size(atlasorientation),actual_values);
        
        distance_image =  sqrt((x-j).^2 + (y-i).^2);
        filter_values1 = actual_values(distance_image <= 50);                 % set to 50
        
        if(length(filter_values1) >= 1)
           
            % second filter based on normal vector deviation
            [y,x]=ind2sub(size(atlasorientation),filter_values1);   

            angle_diff=zeros(length(filter_values1),1);
            for ind=1:length(filter_values1)
                angle_diff(ind) = abs( atlasorientation(y(ind),x(ind)) - imageorientation(i,j));
            end

            filter_values2 = filter_values1(angle_diff < 0.5);                    % angle deviation of 0.5 degree

            if(length(filter_values2) >= 1)
               
                [y,x]=ind2sub(size(atlasorientation),filter_values2); 

                eucl_dist= sqrt((x-j).^2 + (y-i).^2);        
                [~,index]=sort(eucl_dist,'ascend');
                r=y(index(1));                                             % taking the closest value
                c=x(index(1));
                     
                A(tIter,:)=[j i 1];
                bx(tIter,:)=c;
                by(tIter,:)=r;
            end
        end
        
end

idx=find(bx==0 & by==0);
A(idx,:)=[];
bx(idx,:)=[];
by(idx,:)=[];

fprintf('Time for final correspondence is %f secs \n',toc)

end























