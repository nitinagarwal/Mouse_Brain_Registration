function [final_image,CC] = largestConnectedComponent(image,component_size,flag)
% this function retains 8 connected componenet having number of pixels 
% greater than component_size.
% Input: image = logical image
% Output: 

CC = bwconncomp(image,8);

numPixels = cellfun(@numel,CC.PixelIdxList);
idx=find(numPixels>=component_size);                   % removing curves less than component_size pixels

final_image=image;

for i=1:length(numPixels)                   % visualizaing the remaining curves
    if (any(i==idx) == 0)
        final_image(CC.PixelIdxList{i}) = 0;
    end
end


CC = bwconncomp(final_image,8);         % displaying curves of greater than component_size pixels

if(flag==true)
    L = labelmatrix(CC);
    RGB = label2rgb(L,'hsv','k','shuffle');
    figure('Name','showing_largest_8_connected_component'), imshow(RGB);
end

end