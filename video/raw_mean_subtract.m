function v = raw_mean_sub(rawfilein, rawfileout)
% RAW_MEAN_SUB subtract the mean pixel values from a Pulnix RAW file.
%
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb) 
%

% get input file information
file = dir(rawfilein);

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;

% setup the input file
fid = fopen(rawfilein);
fod = fopen(rawfileout,'w');

% construct mean image projection
mean_im = mip(rawfilein, 1, 500, 1, 'mean');
mean_im = double(mean_im) / max(max(mean_im));

% process each frame by mean
% frame properties
% file = rawfilein;
rows = 484;
cols = 648;
color_depth = 1; % bytes
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% m = max(m);
% n = min(n);
% 
% gain = 255/m;

fid = fopen(rawfilein);

start = 1;
stride = 1;
stop = number_of_frames;

for k=start:stride:stop    
    tic;
    
    % read in the target frame and cast to double to avoid losing precision
    im = fread(fid, [648,484],'uint8');   % read in the next frame    
    im = double(im) / max(max(im));
    
    % subtract off mean image.
    im = im - mean_im';
    
    % add minimum as offset and renormalize
    im = im + abs(min(min(im)));
    im = 255 * im / max(max(im));
    
    fwrite(fod, im, 'uint8');
    
    % handle timer
	itertime = toc;
	if k == start
        totaltime = itertime;
	else
        totaltime = totaltime + itertime;
	end    
	meantime = totaltime / ((k-start+1) / stride);
	timeleft = (stop-k)/stride * meantime;
	outs = [num2str(timeleft, '%5.0f') ' sec.'];
	set(timetext, 'String', outs);
    drawnow;

end

fclose('all');

v = 0;

toc;
