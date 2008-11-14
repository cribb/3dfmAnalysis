function v = raw2avi(rawfilein, stride, frame_rate, framesize_vector)
% RAW2AVI converts a Pulnix RAW file to an AVI file.
%
% 3DFM function  
% Video 
% last modified 07.07.2008 (jcribb) 
%  
% This function converts RAW files from the Pulnix camera
% (via take, GLUItake, etc...) into an AVI file.
%  
%  v = raw2avi(rawfilein, stride, frame_rate, framesize_vector);  
%   
%  where "rawfilein" is the filename of the input RAW file (wildcards ok)
%        "stride" takes every <stride> frame (reduces bandwidth, removes timelapse)
%        "frame_rate" is the frame_rate of the output AVI.
%        "framesize_vector" is the [width height] of framein pixels,
%                           default [648 484]
%   

if nargin < 4 || isempty(framesize_vector)
    xpos = 1;
    ypos = 1;
    cols = 648;
    rows = 484;
    logentry('No frame size for raw file specified. Setting to default 648x484 pixels.');
else
    xpos = framesize_vector(1);
    ypos = framesize_vector(2);
    cols = framesize_vector(3);
    rows = framesize_vector(4);
end

if nargin < 3 || isempty(frame_rate)
    frame_rate = 30;
    logentry('No output AVI frame rate specified.  Setting to default 30 fps.');
end

if nargin < 2 || isempty(stride);
    stride = 4;
    logentry('No stride defined.  Using default stride of every 4 frame.');
end

if nargin < 1 || isempty(rawfilein);
    error('No input rawfile defined.');
end

% get input file information
file = dir(rawfilein);

% frame properties
color_depth = 1; % bytes
frame_size = rows * cols * color_depth;

for f = 1 : length(file)
    
    number_of_frames = (file(f).bytes) / frame_size;
    
    % setup the input file
	fid = fopen(file(f).name);
    
    % setup the output file name
    movieout = file(f).name;
    movieout = [movieout(1:end-3) 'avi'];
	
	% setup the output file
  	mov = avifile(movieout,'quality',60,'fps',frame_rate,'keyframe',2.0,'compression','none');
%   mov = avifile(movieout,'quality',60,'fps',frame_rate,'keyframe',2.0,'compression','XviD');
%   mov = avifile(movieout,'compression','XviD');

    % initialize figure and set initial properties
	fig = figure;
	set(fig, 'visible','off' ...
           , 'Position', [xpos ypos cols rows] ...
           , 'DoubleBuffer','on' ...
           , 'Renderer','zbuffer' ...
           , 'Resize',  'on' ...
           , 'Colormap', gray(256));
	
	% set axes properties
    ax = gca;
	set(ax, 'Units', 'Pixels', ...
            'Position', [1 1 cols rows], ...
            'Visible', 'off');
	axis square;

	% set up text-box for 'remaining time' display
	[timefig,timetext] = init_timerfig;
	
	for k=1:stride:number_of_frames
		tic;  % start timer
		
		im = fread(fid, [648,484],'uint8');   % read in the next frame
        im = balance_pulnix_gains(im);

        imagesc(im','parent',ax);               % puts image in invisible axes  
		axis off;
        drawnow;
		mov = addframe(mov,ax);               % adds frames to the AVI file 
		status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
		
		% handle timer
		itertime = toc;
		if k == 1
            totaltime = itertime;
		else
            totaltime = totaltime + itertime;
		end    
		meantime = totaltime / (k / stride);
		timeleft = (number_of_frames-k)/stride * meantime;
		outs = [num2str(timeleft, '%5.0f') ' sec.'];
		set(timetext, 'String', outs);
	end 
	
	mov=close(mov);     % closes the AVI file  
	close(fig);         % closes the handle to invisible figure
	close(timefig);
    
end    
    
v = 0;

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
     headertext = [logtimetext 'raw2avi: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
