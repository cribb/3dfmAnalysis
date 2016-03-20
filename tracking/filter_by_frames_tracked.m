function [data]= filter_by_frames_tracked(filepath,numframes,sensitivity)

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

TF1= data(:,SENS)<sensitivity;
     data(TF1,:)=[];
sz=size(data);
orderData=zeros(sz(1),16);
 orderData(:,1)=data(:,3);
 orderData(:,2)=data(:,2);
 orderData(:,3)=data(:,4);
 orderData(:,4)=data(:,5);
[path, name, ext]=fileparts(filepath);
newfile=[name '_filtered' ext];
csvwrite(newfile,orderData);
   