function [A,bx,by]=find_PointCorrespondence(imageorientation,atlasorientation,distance_threshold,angle_threshold)
% using single point matching. 
% input is the orientation image of the microscope image and atlas image.
% which is atand(ynormal./xnormal)
% correspondence output of the form A*T=b where T is the transformation matrix (6 elements) 
% A=[x of image, y of image, 1] and bx = [matched x coordinate of atlas] and by = [matched y coordinate of atlas] 
% THIS FUNCTION INTIALLY SEARCHES FOR POINTS IN THE ATLAS SPACE WHICH ARE
% NEAR (WITHIN A THRESHOLD) THE IMAGE POINT. HENCE NARROWING THE SEARCH
% SPACE. THEN IT SEARCHES FOR POINTS WITHIN AN ANGULAR DIFFERENCE (WITHIN A
% THRESHOLD). have parallelized it for speed.

tic
% iter=1;                                                 % number of rows in the A matrix

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
        filter_values1 = actual_values(distance_image <= distance_threshold);  
        
        if(length(filter_values1) >= 1)
           
            % second filter based on normal vector deviation
            [y,x]=ind2sub(size(atlasorientation),filter_values1);   

            angle_diff=zeros(length(filter_values1),1);
            for ind=1:length(filter_values1)
                angle_diff(ind) = abs( atlasorientation(y(ind),x(ind)) - imageorientation(i,j));
            end

            filter_values2 = filter_values1(angle_diff<angle_threshold);            % initially set to 5/10 degrees and reduced subsequently

            if(length(filter_values2) >= 1)
                
                % if more than one points are within the normal deviation take weighted average
                if(length(filter_values2)>=3)


                    [y,x]=ind2sub(size(atlasorientation),filter_values2); 

                     eucl_dist= sqrt((x-j).^2 + (y-i).^2);        
                     [val,index]=sort(eucl_dist,'ascend');
                        score=zeros(3,1);
                        for k=1:3                                   % taking weighted average of 3 lowest eucledian distance points.
                            if (eucl_dist(index(k))==0)             % if the eucledian distance is 0 give very high score.. good match
                                score(k)=5000;
                            else
                                score(k)=1/eucl_dist(index(k));     % score is just inversely proportional to the eucledian distance. 
                            end
                        end

                        s=sum(score(:));                            % summing the scores for weighted average

                        r = y(index(1))*score(1)/s + y(index(2))*score(2)/s + y(index(3))*score(3)/s;  % weighted average computation
                        c = x(index(1))*score(1)/s + x(index(2))*score(2)/s + x(index(3))*score(3)/s;       

                elseif (length(filter_values2)==2)

                        [y,x]=ind2sub(size(atlasorientation),filter_values2); 
                        eucl_dist= sqrt((x-j).^2 + (y-i).^2);
                        [~,index]=sort(eucl_dist,'ascend');
                      
                       score=zeros(2,1);
                       for k=1:2                                    % taking weighted average of 2 lowest eucledian distance points.
                            if (eucl_dist(index(k))==0)             % if the eucledian distance is 0 give very high score.. good match
                                score(k)=5000;
                            else
                                score(k)=1/eucl_dist(index(k));     % score is just inversely proportional to the eucledian distance. 
                            end
                        end

                        s=sum(score(:));                            % summing the scores for weighted average

                        r = y(index(1))*score(1)/s + y(index(2))*score(2)/s;    % weighted average computation for 2 points
                        c = x(index(1))*score(1)/s + x(index(2))*score(2)/s;       

                else    %(length(filter_values2)==1)
                    [r,c]=ind2sub(size(atlasorientation),filter_values2);                   % for the base case
                end

                    A(tIter,:)=[j i 1];
                    bx(tIter,:)=c;
                    by(tIter,:)=r;
%                     iter=iter+1;
            end
        end
        
end 

idx=find(bx==0 & by==0);
A(idx,:)=[];
bx(idx,:)=[];
by(idx,:)=[];
     
fprintf('Time for point correspondence is %f secs \n',toc) 

end























