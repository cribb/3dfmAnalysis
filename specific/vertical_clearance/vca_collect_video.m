filename='SNABMucSInterference5';

% Set video parameters, start camera
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
% propinfo(vid)
src = getselectedsource(vid); % Following code found in apps -> image acquisition
src.Exposure   = 0.0075073; 
src.FrameRate  = 120;
src.Gain       = 10;
src.Gamma      = 1.15;
src.Brightness = 5.8594;
src.Shutter    = 4; %8?

vid.ReturnedColorspace = 'grayscale';
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = Inf;
% preview(vid);
pause(2)
start(vid);
pause(2);
% More info here: http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html


% Saving data
[data time meta ] = getdata(vid);
time=zeros(size(data,4)),1);
for i=1:length(meta)
    time(i)=seconds(days(datenum(meta(i).AbsTime)));
end
save_bin_on_nvme(data,filename)
xlswrite([filename,'.xlsx'],time');