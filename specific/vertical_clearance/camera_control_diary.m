vid = videoinput('pointgrey', 1,'F7_Raw8_1024x768_Mode2');
imaqhelp(vid, 'LoggingMode');
vid
propinfo(vid, 'VideoFormat')
imaqhelp(vid, 'VideoFormat');
help IMAQHWINFO
vid = videoinput('pointgrey', 1,'F7_Raw8_1024x768_Mode2');
src = getselectedsource(vid);
src.Exposure   = 0.0075073;
src.FrameRate  = 120;
src.Gain       = 10;
src.Gamma      = 1.15;
src.Brightness = 5.8594;
src.Shutter    = 4;
vid.ReturnedColorspace = 'grayscale';
vidRes = vid.VideoResolution
f = figure('Visible', 'off');
imageRes = fliplr(cidRes)
imageRes = fliplr(vidRes)
subplot(1,2,1);
hImage = imshow(zeros(imageRes));
axis image
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
which update_livehistogram_display
preview(vid, hImage);
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);
f = figure('Visible', 'off');
imageRes = fliplr(vidRes)
subplot(1,2,1);
hImage = imshow(zeros(imageRes));
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);
pause(30)
f = figure('Visible', 'off');
subplot(2,1,1);
hImage = imshow(zeros(imageRes));
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);
preview(vid, hImage);