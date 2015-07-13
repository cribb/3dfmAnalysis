function outs = diskbkgrnd_combo(frames)


for k = 1:length(frames); 
    imtemp = frames{k};
    background = imopen(imtemp,strel('disk',100));
    foreground=imtemp-background;
    sub_frames{k}=foreground;
end;

outs=sub_frames;