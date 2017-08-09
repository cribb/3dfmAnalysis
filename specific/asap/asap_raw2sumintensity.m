function [framenum, Isum, Imean] = asap_raw2sumintensity(rawfilein, start_frame, end_frame, stride)

if nargin < 1 || isempty(rawfilein)
    error('No file defined.');
else
    % get input file information
    file = dir(rawfilein);
    
    if isempty(file)
        error('File not found.')
    end
end

% frame properties
rows = 484;
cols = 648;
color_depth = 1;   % byte
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

if nargin < 2 || isempty(start_frame)
    start_frame = 1;
end

if nargin < 3 || isempty(end_frame)
    end_frame = number_of_frames;
end

if nargin < 4 || isempty(stride)
    stride = 1;
end


% setup the input file
fid = fopen(file.name);

for k = start_frame : stride : (end_frame-1)
    
  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
    
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  
  im = double(im);
  
  framenum(k,1) = k;

  Isum(k,1) = sum( im(:) );
  Imean(k,1) = mean( im(:) );
  
end

return;

