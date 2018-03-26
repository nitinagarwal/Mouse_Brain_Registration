function [xnormal,ynormal] = normal_vector(image,selection)
% input for this function is the canny edge detected image(logical/binary)

template=padarray(image,[2 2]);
[X,Y]=meshgrid(1:size(template,2),1:size(template,1));
xnormal=zeros(size(template,1),size(template,2));
ynormal=zeros(size(template,1),size(template,2));

for i=3:size(template,1)-3
    for j=3:size(template,2)-3
    
      if(template(i,j)==1)                          % will only compute normal for valid pixels
        kernel=template(i-2:i+2,j-2:j+2);           % 5 by 5 neighbourhood of image
        
        if( numel(find(kernel>0)) > 4)              % this removes cluster of pixels < 4    %COMMENT THIS IF REUIQRED
        
        x=X(i-2:i+2,j-2:j+2);                       % 5 by 5 neighbourhood of coordinates
        y=Y(i-2:i+2,j-2:j+2);
        
        x=x.*kernel;
        y=y.*kernel; 
        
        rows=y(y>0);
        cols=x(x>0);
        
        B=[cols-j rows-i]';         
        [U,S,~]=svd(B);
        
        ratio=S(1,1)/S(2,2);            
      
        if(ratio>=3)                                % considering only vctors where the ratio of the upper and lower singluar value is high(higher probablity of correct normal)
            xnormal(i,j)=U(1,2);                    
            ynormal(i,j)=U(2,2);
        end
        
        end
        
      end
        
    end
end

finalrowsize=size(template,1);
finalcolsize=size(template,2); 

xnormal=xnormal(3:finalrowsize-2,3:finalcolsize-2);         % resizing 
ynormal=ynormal(3:finalrowsize-2,3:finalcolsize-2);

if (selection == true)
    % plotting all the normal vectors
    [X,Y]=meshgrid(1:size(image,2),1:size(image,1));
    figure,imshow(image)
    hold on
    quiver(X,Y,xnormal,ynormal,'b')
end

end

