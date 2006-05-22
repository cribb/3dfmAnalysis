function v = raw2avi(rawfilein, stride, frame_rate)
% 3DFM function  
% Video 
% last modified 11/19/2004 
%  
% This function converts RAW files from the Pulnix camera
% (via take, GLUItake, etc...) into an AVI file.
%  
%  v = raw2avi(rawfilein, stride, frame_rate);  
%   
%  where "rawfilein" is the filename of the input RAW file (wildcards ok)
%        "stride" takes every <stride> frame (reduces bandwidth, removes timelapse)
%        "frame_rate" is the frame_rate of the output AVI.
%   
%  ??/??/?? - created.  jcribb.
%  09/07/04 - added documentation and removed a bug that only
%             allowed one to capture 60 frames.  jcribb.
%  11/19/04 - added stride and changed name to raw2avi (from 
%             make_pulnix_movie).  added "time remaining indicator
%             updated documentation.  removed movieout. output filename
%             is the input filename with .avi extension; jcribb.
%  


% get input file information
file = dir(rawfilein);

% frame properties
rows = 484;
cols = 648;
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
           , 'Position', [1 1 cols rows] ...
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
