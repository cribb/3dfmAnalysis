function outs = video_analysis(filepath,datatag)
cd(filepath);
% frames=get_frames_combo(filepath);
% sub_frames=diskbkgrnd_combo(frames);
% snr=tracking_image_SNR_combo(sub_frames,.05,'n');
%    
[snr, em] = tracking_image_SNR('frame_0000.tif', 0.05, 'y');
   
   snfig = figure; 
   plot(1:length(snr), snr);
   xlabel('Frame #');
   ylabel('Signal-to-Noise Ratio');
   title([datatag ' full frame, with bkgd subtr']);
   pretty_plot;
  
     