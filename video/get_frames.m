function outs=get_frames(filepath,filepath2)

file_name=filepath;
info=imfinfo(file_name);
num_images=numel(info);
for k=1:num_images
   cd(filepath2);
   frame{k}=imread(file_name,k);
   cd(filepath2);
   s1='frame_';
   s2=num2str(k);
   s3='.tif';
   s=strcat(s1,s2,s3);
   imwrite(frame{k},s);
   
   
end

    
    