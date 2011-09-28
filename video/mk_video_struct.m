
function video = mk_video_struct(xDim, yDim, fps, pixelsPerMicron)
%   video = makeVideoStructure(xDim, yDim, fps, pixelsPerMicron)
%
%    This function returns a video structure created from the following parameters
%     xDim: horizontal resolution in pixels
%     yDim: vertical resolution in pixels
%     fps: camera's frame rate 
%     pixelsPerMicron: The conversion factor for #of pixels per micron 
%     Default values are 
%        xDim 656
%        yDim 494
%        fps   90
%        pixelsPerMicron    .542
 
%
%
if nargin < 4 || isempty(pixelsPerMicron)
   pixelsPerMicron = .542;
end
if nargin < 3 || isempty(fps)
    fps = 90;
end
if nargin < 2 || isempty(yDim)
    yDim = 494;
end
if nargin < 1|| isempty(xDim)
    xDim = 656;
end

   video.xDim = xDim;
   video.yDim = yDim;
   video.fps = fps;
   video.pixelsPerMicron = pixelsPerMicron;
end

