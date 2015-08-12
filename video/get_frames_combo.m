function outs=get_frames_combo(filepath,datatag)


file_name=filepath;
info=imfinfo(file_name);
num_images=numel(info);
for k=1:num_images
   
   frame(:,:,k)=imread(file_name,k);
   
   
   
end

im=frame(:,:,1);
for i = 2:num_images
im = imadd(im,frame(:,:,i));
end
im = im/num_images;
background = imopen(im,strel('disk',100));


for i=1:num_images
    frame(:,:,i)=frame(:,:,i)-background;
    
end


[snr, em] = tracking_image_SNR(frame, 0.05, 'n');
   avgSNR=mean(snr)
   snfig = figure; 
   plot(1:length(snr), snr);
   xlabel('Frame #');
   ylabel('Signal-to-Noise Ratio');
   title([datatag ' full frame, with bkgd subtr']);
   pretty_plot;
  

   