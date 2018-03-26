function overlap_image(atlasimage,microscopeimage)
% input are the actual atlas and microscope image which you to overlap

atlasimage=255-atlasimage;

% figure,imshow(microscopeimage+atlasimage);
imtool(microscopeimage+atlasimage)

end