
function outs = diskbkgrnd(filepath,numframes,disksize)



% load the frames 
cd(filepath);
filelist = dir('*.tif');
for k = 1:numframes; 

    imtemp = imread(filelist(k).name); 
    sub_background(:,:,k) = imopen(imtemp,strel('disk',disksize));
    
    

end;

background=uint16(mean(sub_background,3));
imwrite(background,'background.tif');



