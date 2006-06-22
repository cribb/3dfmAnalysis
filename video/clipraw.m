function v = clipraw(rawfilein, rawfileout, position, start_frame, end_frame, stride, output)
% 3DFM function  
% Video 
% last modified 06/22/2006 (jcribb)
%  
% This function clips RAW files (contiguous image stack) from the 
% Pulnix camera (via take, GLUItake, etc...).
%  
%  v = clipraw(rawfilein, rawfileout, position, start_frame, end_frame, stride, output)
%   
%  where "rawfilein" is the filename of the input RAW file. 
%        "rawfileout" is the filename of the output RAW file.
%        "position" is the cropping vector [initial_x initial_y width height]
%        "start_frame" is the starting output frame
%        "end_frame" is the final output frame
%        "stride" 
%        "output"  is 'file' or 'var'.  'file' is the default, and records
%        the output as a file.  'var' records as a file and outputs the
%        data as a matrix variable v(x,y,frame).
%        !! WARNING !! -- clipraw doesn't check to see if the 'var' you
%        wish to generate exceeds current available memory.  If you exceed
%        that value, matlab will probably crash!
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
if nargin < 7 | isempty(output);    
    output = 'file';
    logentry('No output type specified.  Outputting to file only.');    
end

if nargin < 6 | isempty(stride);    
    stride = 1;        
    logentry('No stride specified.  Using default stride of 1.');
end

if nargin < 5 | isempty(end_frame); 
    end_frame = number_of_frames; 
    logentry('No end_frame specified.  Using last frame as default.');
end

if nargin < 4 | isempty(start_frame); 
    start_frame = 1;  
    logentry('No start_frame specified, Using first frame as default.');
end

if (start_frame < 1) | (start_frame > number_of_frames)
    logentry('The start_frame parameter is less than one, or exceeds the number of frames in the RAW stack.');
    logentry('Switching to first frame instead.');
    start_frame = 1;
elseif (end_frame < 1) | (end_frame > number_of_frames)
    logentry('The end_frame parameter is less than one, or exceeds the number of frames in the RAW stack.');
    logentry('Switching to last frame instead.');
    end_frame = number_of_frames;
end

if nargin < 3 | isempty(position)
    position = [1 1 648 484];
    logentry('No position specified.  Using full frames as the default.');
end

if nargin < 2 | isempty(rawfileout)
    logentry('No output filename specified.');
end

% Decode position
xpos = position(1);
ypos = position(2);
width = position(3);
height = position(4);

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;

% setup the input file
fid = fopen(rawfilein);
fod = fopen(rawfileout, 'w');

logentry('Generating output file and/or matrix.  Please wait...');

iter = 1;
for k=start_frame:stride:end_frame
    tic;
    
  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame

  im = fread(fid, [648,484],'uint8');   % read in the next frame

  im = im(xpos:xpos+width-1,ypos:ypos+height-1);

  count = fwrite(fod, im, 'uint8');  
  
  if strcmp(output, 'var')
      rawout(:,:,iter) = im;
      iter = iter + 1;
  end
  
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

% clean up
close(timefig);
fclose(fid);
fclose(fod);

% generate output
if exist('rawout')
    v = rawout;
else
    v = 0;
end

return;



%%%%%%%%%%%  EXTERNAL FUNCTIONS  %%%%%%%%%%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'clipraw: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return