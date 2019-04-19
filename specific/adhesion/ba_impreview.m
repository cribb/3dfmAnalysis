function ba_impreview

    imaqmex('feature', '-previewFullBitDepth', true);
    % imaqmex('feature', '-previewFullBitDepth', false);
    vid = videoinput('pointgrey', 1, 'F7_Raw16_1024x768_Mode2');


    % imaqhelp(vid, 'LoggingMode');
    % imaqhelp(vid, 'VideoFormat');
    % propinfo(vid, 'VideoFormat')

    src = getselectedsource(vid);
    % src.Exposure   = 0.016;
    src.FrameRate  = 20;
%     src.FrameRateMode  = 'auto';
    src.Shutter    = 50;
    src.Gain       = 10;
    src.Gamma      = 1.15;
    src.Brightness = 5.8594;


    % triggerconfig(vid, 'manual');
    vid.FramesPerTrigger = Inf;
    vid.ReturnedColorspace = 'grayscale';


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
        x=5
        exptime = str2num(source.String)
        src.Shutter = exptime;
%         src.FrameRate = 1./exptime;
    end


    % % pause(30)
    % f = figure('Visible', 'off');
    % subplot(2,1,1);
    % hImage = imshow(zeros(imageRes));
    % setappdata(hImage,'UpdatePreviewWindowFcn',@ba_livehist);
    % preview(vid, hImage);
end