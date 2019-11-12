function rheo_impreview
% BA_IMPREVIEW UI for previewing the microscope's camera image.
%
    imaqmex('feature', '-previewFullBitDepth', true);
    
    vid = videoinput('pointgrey', 1, 'F7_Raw16_1024x768_Mode2');
    
    vid.ReturnedColorspace = 'grayscale';
    
    src = getselectedsource(vid);
    
    src.Brightness = 5.8594;   
    src.ExposureMode = 'off';    
    src.GainMode = 'manual';
    src.Gain       = 10;
    src.GammaMode = 'manual';
    src.Gamma      = 1.15;
    src.FrameRateMode  = 'off';
%     src.FrameRate = 125;
    src.ShutterMode = 'manual';
    src.Shutter = 8;

    pause(0.1);
    
    vidRes = vid.VideoResolution;
    imageRes = fliplr(vidRes);   
    
    f = figure('Visible', 'off', 'Units', 'normalized');
    ax = subplot(2, 1, 1);
    set(ax, 'Units', 'normalized');
    set(ax, 'Position', [0.05, 0.4515, .9, 0.53]); 
    
    hImage = imshow(uint16(zeros(imageRes)));
    axis image

    edit_exptime = uicontrol(f, 'Position', [20 20 60 20], ...
                                'Style', 'edit', ...
                                'String', num2str(src.Shutter), ...
                                'Callback', @change_exptime);
    btn_grabframe = uicontrol(f, 'Position', [20 40 60 20], ...
                                 'Style', 'pushbutton', ...
                                 'String', 'Grab Frame', ...
                                 'Callback', @grab_frame);
    edit_exptime.Position
    btn_grabframe.Position
    
    
    setappdata(hImage, 'UpdatePreviewWindowFcn', @ba_livehist);
%     hImage.CData = log10(double(hImage.CData));
    h = preview(vid, hImage);
    set(h, 'CDataMapping', 'scaled');

    function change_exptime(source,event)

        exptime = str2num(source.String);
        fprintf('New exposure time is: %4.2g\n', exptime);
        
        src.Shutter = exptime;
       
        edit_exptime.String = num2str(src.Shutter);
        
    end

    function grab_frame(source, event)
        imwrite(hImage.CData, 'grabframe.png');
        disp('Frame grabbed to grabframe.png');
    end

end

function ba_livehist(obj,event,hImage)
% BA_LIVEHIST is a callback function for ba_impreview.
%


% Display the current image frame.
set(hImage, 'CData', event.Data);

% Select the second subplot on the figure for the histogram.
ax = subplot(2,1,2);
set(ax, 'Units', 'normalized');
set(ax, 'Position', [0.28, 0.05, 0.4, 0.17]);

D = double(event.Data(:));
avgD = round(mean(D));
stdD = round(std(D));
maxD = num2str(max(D));
minD = num2str(min(D));

avgD = num2str(avgD, '%u');
stdD = num2str(stdD, '%u');
maxD = num2str(maxD, '%u');
minD = num2str(minD, '%u');

% Plot the histogram. Choose 128 bins for faster update of the display.
imhist(event.Data, 32768);

set(gca,'YScale','log');
xlim([0 66500]);
title([avgD, ' \pm ', stdD, ' [', minD ', ', maxD, ']']);

% Modify the following numbers to reflect the actual limits of the data returned by the camera.

% For example the limit a 16-bit camera would be [0 65535].

a = ancestor(hImage, 'axes');

cmin = min(double(hImage.CData(:)));
cmax = max(double(hImage.CData(:)));

if cmin < cmax
    set(a, 'CLim', [uint16(cmin) uint16(cmax)]);
end
% set(a, 'CLim', [0 65535]);

% Refresh the display.
drawnow

end