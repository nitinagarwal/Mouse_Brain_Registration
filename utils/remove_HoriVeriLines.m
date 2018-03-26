function image=remove_HoriVeriLines(image,line_length)
% input is a logical image
% and output is the same logical image with horizontal and vertical lines
% removed (of length specified by user as line_length).
% using connected component finding the longest components

%--------------------------------------------------------------------------------
% remove long horizontal lines (25 pixels wide) 

% first removing horizontal lines 
for i=1:size(image,1)           
    
    array=image(i,:);
    CC=bwconncomp(array,4);                 % using 4 connected component
    
    numPixels = cellfun(@numel,CC.PixelIdxList);
    idx=find(numPixels>line_length);                 %remove horizontal line greater than 25 pixels
    
    if(isempty(idx)==false)
        for j=1:length(idx)
                image(i,CC.PixelIdxList{idx(j)}) = 0;
        end
    end
end
    
    
%--------------------------------------------------------------------------------
% remove long vertical lines (25 pixels wide)     
    
for k=1:size(image,2)           
    
    array=image(:,k);
    CC=bwconncomp(array,4);                 % using 4 connected component
    
    numPixels = cellfun(@numel,CC.PixelIdxList);
    idx=find(numPixels>line_length);                 %remove vertical line greater than 50 pixels
    
    if(isempty(idx)==false)
        for j=1:length(idx)
                image(CC.PixelIdxList{idx(j)},k) = 0;
        end
    end
end    
 


end