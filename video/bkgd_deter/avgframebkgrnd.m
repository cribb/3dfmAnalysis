function outs = avgframebkgrnd(filepath,numframes,disksize)

if nargin < 3 || isempty(disksize)
    disksize=128;
end
if (nargin<2 || isempty(numframes))
    numframes=50;
end


% load the frames 
cd(filepath);
filelist = dir('*.tif');
for k = 1:numframes; 

    imtemp(:,:,k) = imread(filelist(k).name); 
    
    
    

end;

mean_im=uint16(mean(imtemp,3));
background=imopen(mean_im,strel('disk',disksize));
imwrite(background,'avgdbackground.tif');
