function v = raw2img(varargin)
% 3DFM function  
% Video 
% last modified 09/22/2004 
%  
% This function converts RAW files (contiguous image stack) from the 
% Pulnix camera (via take, GLUItake, etc...) to a stack of image files.
%  
%  v = raw2img(rawfilein)
%  v = raw2img(rawfilein, image_format)
%  v = raw2img(rawfilein, image_format, end_frame)
%  v = raw2img(rawfilein, image_format, start_frame, end_frame);  
%   
%  where "rawfilein" is the filename of the input RAW file. 
%        "image_type" is any image type supported by matlab's imwrite (default=tif)
%          ('tif', 'bmp', 'jpg', etc...)
%        "start_frame" is the starting frame to convert for output stack
%          (default = 1)
%        "end_frame" is the final frame to convert for output stack
%          (default = the number of frames in the rawfile)
%   
%  09/22/04 - created; jcribb.
%  05/14/05 - fixed an off by one error.  Now single frame RAWs are
%             converted without error.
%

switch nargin
    case 1
        rawfilein = varargin{1};
        image_type = 'tif';
        start_frame = 0;
        end_frame = inf;        % will handle this later
    case 2
        rawfilein = varargin{1};
        image_type = varargin{2};
        start_frame = 0;
        end_frame = inf;        % will handle this later
    case 3
        rawfilein = varargin{1};
        image_type = varargin{2};        
        start_frame = 0;
        end_frame = varargin{3};
    case 4
        rawfilein = varargin{1};
        image_type = varargin{2};        
        start_frame = varargin{3};
        end_frame = varargin{4};       
    otherwise
        error('Invalid use of argument-list.');
end

% get input file information
file = dir(rawfilein);

% frame properties
rows = 484;
cols = 648;
color_depth = 1;   % byte
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% finish handling argument-list
if (nargin <= 2)
    start_frame = 0;
    end_frame = number_of_frames;
end

% check validity of parameters
if (start_frame < 0) | (start_frame > number_of_frames)
    error('The start_frame parameter is less than zero, or exceeds the number of frames in the RAW stack.');    
elseif (end_frame < 0) | (end_frame > number_of_frames)
    error('The end_frame parameter is less than zero, or exceeds the number of frames in the RAW stack.');
end

% setup the input file
fid = fopen(rawfilein);

% initialize figure and set initial properties
fig = figure;
set(fig,'Position', [100 100 cols rows]);
set(fig,'DoubleBuffer','on');
set(fig,'Renderer','zbuffer',...
        'Resize',  'on');
set(fig, 'Visible', 'off');

% set axes properties
ax = axes;
set(ax, 'Units', 'Pixels');
set(ax, 'Position',[1 1 cols rows]);
axis square;
set(ax, 'Visible', 'off');


for k=start_frame:end_frame-1
    
  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
    
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  imagesc(im','parent',ax);             % puts image in invisible axes  
  colormap(gray(256));
  axis off;
  
  % setup the output file(s)
  myfile =  rawfilein(1:end-3);
  %filename_out = [myfile num2str(k) '.tif']

  f = getframe(gcf);
  [X, MAP] = frame2im(f);
  imwrite(X, [myfile num2str(k,'%.5d') '.' image_type], image_type);

  drawnow;
  
end 


close(fig);    % closes the handle to invisible figure

v = X;
