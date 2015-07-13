function outs = video_analysis(filepath,datatag)

%      frames=get_frames_combo(filepath);
%      sub_frames=diskbkgrnd_combo(frames);
%      tracking_image_SNR_combo(sub_frames,.05,'n');
   cd(filepath);
   tracking_image_SNR(filepath,.05,'n');
   snfig = figure; 
   subplot(2,2,1);
   plot(1:length(snr), snr); 
   xlabel('Frame #');
   ylabel('Signal-to-Noise Ratio');
   title([datatag]);
  
     