function v = clipraw(rawfilein, rawfileout, start_frame, end_frame)
% 3DFM function  
% Video 
% last modified 02/09/2005
%  
% This function clips RAW files (contiguous image stack) from the 
% Pulnix camera (via take, GLUItake, etc...).
%  
%  v = clipraw(rawfilein, rawfileout, start_frame, end_frame)
%   
%  where "rawfilein" is the filename of the input RAW file. 
%        "rawfileout" is the filename of the output RAW file.
%        "start_frame" is the starting output frame
%        "end_frame" is the final output frame
%   
%  02/09/2005 - created; jcribb.
%  
%

% get input file information
file = dir(rawfilein);

% frame properties
rows = 484;
cols = 648;
color_depth = 1;   % byte
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% check validity of parameters
if (start_frame < 1) | (start_frame > number_of_frames)
    error('The start_frame parameter is less than one, or exceeds the number of frames in the RAW stack.');    
elseif (end_frame < 1) | (end_frame > number_of_frames)
    error('The end_frame parameter is less than one, or exceeds the number of frames in the RAW stack.');
end

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;

% setup the input file
fid = fopen(rawfilein);
fod = fopen(rawfileout, 'w');


for k=start_frame:end_frame
    tic;
    
  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
    
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  
  count = fwrite(fod, im, 'uint8');  
  
  	% handle timer
	itertime = toc;
	if k == start_frame
        totaltime = itertime;
	else
        totaltime = totaltime + itertime;
	end    
	meantime = totaltime / (k-start_frame+eps);
	timeleft = (end_frame-k) * meantime;
	outs = [num2str(timeleft, '%5.0f') ' sec.'];
	set(timetext, 'String', outs);
    drawnow;
  
end 

close(timefig);
fclose(fid);
fclose(fod);

v = 0;
