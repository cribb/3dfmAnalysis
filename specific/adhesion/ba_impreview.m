function [vid, src] = ba_impreview

    imaqmex('feature', '-previewFullBitDepth', true);
    % imaqmex('feature', '-previewFullBitDepth', false);
    vid = videoinput('mwpointgreyimaq', 1, 'F7_Raw16_1024x768_Mode2');
    
    vid.ReturnedColorspace = 'grayscale';
    
%     triggerconfig(vid, 'manual');
    
%     vid.FramesPerTrigger = Inf;
    % imaqhelp(vid, 'LoggingMode');
    % imaqhelp(vid, 'VideoFormat');
    % propinfo(vid, 'VideoFormat')

    src = getselectedsource(vid);
    % src.Exposure   = 0.016;

    disp('Before doing anything: ');
    propinfo(src,'Shutter');
    
    src.Brightness = 5.8594;
   
    src.ExposureMode = 'off';
    
    src.GainMode = 'manual';
    src.Gain       = 10;

    src.GammaMode = 'manual';
    src.Gamma      = 1.15;

    src.FrameRateMode  = 'off';
%     src.FrameRate = 1e3 / (25 + 0.1)
    
%     src.FrameRate = 1;

%     src.ShutterMode = 'auto';
    disp('Before setting shutter');

    
    pause(0.1);
    
    src.ShutterMode = 'manual';
    propinfo(src,'Shutter')   
     
    src.Shutter = 8;
    
    
%     offtime = 1000 ./ src.FrameRate - src.Shutter;
%     fprintf('Initial frame-rate is set to: %4.4g [fps]\n', src.FrameRate);
    fprintf('Intial shutter time is set to: %4.4g [ms] \n', src.Shutter);
%     fprintf('This corresponds to an off-time of: %4.7g [ms] \n', offtime);
%     src.FrameRate  = 20;



    vidRes = vid.VideoResolution;

    f = figure('Visible', 'off');

    imageRes = fliplr(vidRes);

    subplot(2,1,1);
    hImage = imshow(uint16(zeros(imageRes)));
    axis image

    text_exptime = uicontrol('Style', 'text', 'String', 'Exp. time');
    edit_exptime = uicontrol('Style', 'edit', 'String', num2str(src.Shutter), 'Callback', @change_exptime);

    setappdata(hImage, 'UpdatePreviewWindowFcn', @ba_livehist);

    h = preview(vid, hImage);
    set(h, 'CDataMapping', 'scaled');

    function change_exptime(source,event)

        exptime = str2num(source.String);
        fprintf('New exposure time is: %4.2g\n', exptime);
        
%         new_fps = 1 ./ (exptime/1000);
%         fprintf('New frame-rate is: %4.2g\n', new_fps);

        
%         fprintf('Old frame-rate of src: %4.2g\n', src.FrameRate);
%         fprintf('Old Shutter time of src: %4.2g\n', src.Shutter);
        
%         src.FrameRate = new_fps;
        src.Shutter = exptime;
%         fprintf('New frame-rate of src: %4.2g\n', src.FrameRate);
%         fprintf('New Shutter time of src: %4.2g\n\n', src.Shutter);
        
        edit_exptime.String = num2str(src.Shutter);
        
    end


    % % pause(30)
    % f = figure('Visible', 'off');
    % subplot(2,1,1);
    % hImage = imshow(zeros(imageRes));
    % setappdata(hImage,'UpdatePreviewWindowFcn',@ba_livehist);
    % preview(vid, hImage);
end