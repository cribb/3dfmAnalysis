%filepath1 is where the  frames you want to load are stored
%filepath2 is where you want the foreground images to be saved
%filepath3 is wher you want the background images to be saved

function outs = diskbkgrnd(filepath1,filepath2,filepath3)



% load the frames 
cd(filepath1);
filelist = dir('frame_*.tif');

for k = 1:length(filelist); 
    cd(filepath1);
    imtemp = imread(filelist(k).name); 
    background = imopen(imtemp,strel('disk',20));
    foreground=imtemp-background;
    cd(filepath2);
    imwrite(foreground,filelist(k).name);
    cd(filepath3);
    imwrite(background,filelist(k).name);
end;





