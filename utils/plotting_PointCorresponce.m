function plotting_PointCorresponce(I,edge_atlas,A,bx,by,selection)
% IF selection= true, select the region to show correspondence. 

% combining the images and plotting point correspondences
atlasnormimage=uint8(edge_atlas*255);
micronormimage=I;
bigimage=cat(2,micronormimage,atlasnormimage);
figure('Name','showing_point_correspondence'),imshow(bigimage);hold on

if (selection==true)

        % which points correspondence you want to see
        [col,row]=ginputc(2,'Color','r','LineWidth',1); 
        [val,~] = find( A(:,1)>=col(1) & A(:,1) <=col(2) & A(:,2)>=row(1) & A(:,2)<=row(2) );

        if (numel(val)~=0)
        
            for i=1:10:length(val)

               x1plot(i)=A(val(i),1);
               x2plot(i)=bx(val(i))+size(I,2);  %x2plot(i)=bx(val(i))+2744;  
               y1plot(i)=A(val(i),2);
               y2plot(i)=by(val(i));

            end
            plot([x1plot;x2plot],[y1plot;y2plot],'r-'); hold on
            plot(x1plot,y1plot,'gx', 'MarkerSize',4);plot(x2plot,y2plot,'yx', 'MarkerSize',4)
        else
            disp('NO CORRESPONDENCE WAS MADE')
        end
            
else
       for i=1:length(bx)
               x1plot(i)=A(i,1);
               x2plot(i)=bx(i)+size(I,2);  %x2plot(i)=bx(i)+2744;  
               y1plot(i)=A(i,2);
               y2plot(i)=by(i);
       end
    plot([x1plot;x2plot],[y1plot;y2plot],'r-');hold on 
    plot(x1plot,y1plot,'gx', 'MarkerSize',4);plot(x2plot,y2plot,'yx', 'MarkerSize',4)

end

end