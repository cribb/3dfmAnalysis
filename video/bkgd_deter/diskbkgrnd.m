
function outs = diskbkgrnd(filepath,numframes,disksize)

if nargin < 3
    disksize=128;
elseif nargin<2
    numframes=50;
end


% load the frames 
cd(filepath);
filelist = dir('*.tif');
for k = 1:numframes; 

    imtemp = imread(filelist(k).name); 
    sub_background(:,:,k) = imopen(imtemp,strel('disk',disksize));
    
    

end;

background=uint16(mean(sub_background,3));
imwrite(background,'background.tif');



