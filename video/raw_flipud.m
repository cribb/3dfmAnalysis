function v = raw_flipud(rawfilein, rawfileout)
% RAW_FLIPUD flips a Pulnix file in the up/down direction
%
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb) 

tic;

% get input file information
file = dir(rawfilein);

% setup the input file
fid = fopen(rawfilein);
fod = fopen(rawfileout,'w');

% frame properties
rows = 484;
cols = 648;
color_depth = 1; % bytes
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;
	
for k=1:number_of_frames    
    tic;
    
    im = fread(fid, [648,484],'uint8');   % read in the next frame    

    im = im';
    im = flipud(im);
    im = im';
    
    fwrite(fod, im, 'uint8');
    
    % handle timer
    itertime = toc;
    if k == 1
        totaltime = itertime;
    else
        totaltime = totaltime + itertime;
    end    
    meantime = totaltime / k;
    timeleft = (number_of_frames-k) * meantime;
    outs = [num2str(timeleft, '%5.0f') ' sec.'];
    set(timetext, 'String', outs);

    drawnow;
end

fclose('all');

v = 0;
