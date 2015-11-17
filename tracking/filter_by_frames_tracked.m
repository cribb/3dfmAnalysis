function [data]= filter_by_frames_tracked(filepath,numframes)

if isempty(filepath)
    error('No file found, please enter a vide to filter');
end

video_tracking_constants;
data = load_video_tracking(filepath, [], 'pixels', 1, 'absolute', 'no', 'table');

freqstats=tabulate(data(:,ID));
for (i=1:length(freqstats(:,2)))
    if(freqstats(i,2)<numframes)
     TF1= data(:,ID)==freqstats(i);
     data(TF1,:)=[];
    end
     
end
;
   