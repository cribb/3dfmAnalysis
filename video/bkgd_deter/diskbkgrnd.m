
function outs = diskbkgrnd(filepath)



% load the frames 
cd(filepath);
filelist = dir('*.tif');
for k = 1:50; 

    imtemp = imread(filelist(k).name); 
    sub_background(:,:,k) = imopen(imtemp,strel('disk',128));
    
    

end;

background=uint16(mean(sub_background,3));
imwrite(background,'background.tif');



