function outs = startendbkgrnd(filepath,disksize)

if nargin < 2 || isempty(disksize)
    disksize=128;
end



% load the frames 
cd(filepath);
filelist = dir('*.tif');
counter=1;
for k = 1:length(filelist); 
   if k<=10|| k>=(length(filelist)-10)
    imtemp(:,:,counter) = imread(filelist(k).name); 
    counter=counter+1;
   end   
    

end;

mean_im=uint16(mean(imtemp,3));
background=imopen(mean_im,strel('disk',disksize));
imwrite(background,'startendbackground.tif');