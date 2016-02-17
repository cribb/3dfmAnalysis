function get_frames()

rootdir=pwd;

filelist=dir('*.tif');
for j=1:length(filelist)
    name=filelist(j).name;
    noext=strsplit(name,'.');
    
    mkdir(noext{1});
    movefile(name,noext{1});
    cd(noext{1});
    info=imfinfo(name);
    num_images=numel(info);

for k=1:num_images
   
   frame{k}=imread(name,k);
   number=num2str(k-1,'%04i');
   newname=strcat('frame_',number,'.tif');
   imwrite(frame{k}, newname);
   
   
end

cd(rootdir);
end 


    
    