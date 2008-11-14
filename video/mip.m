function v = mip(files, start, stop, stride, mode)
% MIP Creates a time-lapse image from a RAW file and outputs to an image object.
%
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb) 
%  
% This function returns the maximum or minimum intensity 
% projection image for a movie (avi or raw), or a stack of images in
% any format Matlab supports.  The image matrix is returned
% and the image is plotted into a figure for viewing.
%  
%  [im] = mip(files, start, stop, stride, mode);  
%   
%  where "files" is an .avi or .raw file or stack of images 
%        "start" is starting frame number, defaults to first frame.
%        "stop"  is ending frame number, defaults to last frame.
%        "stride" is the number of frames to jump between "start" and "stop"
%        "mode"  is 'mean', 'max', or 'min', defaulting to 'min' 
%  

% handle argument list

% get directory for a file or a list of files (using wildcards)
files = dir(files);
ext = lower(files(1).name(end-2:end));

% set the number of frames value according to the filetype
switch ext
    case 'avi'
        file = files(1);       % handle only the first avi file
        nfo = aviinfo(file.name);
        number_of_frames = nfo.NumFrames;
    case 'raw'  % pulnix ptm6710 format
        file = files(1);       % handle only the first raw file
        % frame properties
		rows = 484;
		cols = 648;
		color_depth = 1; % bytes
		frame_size = rows * cols * color_depth;        
        number_of_frames = (file.bytes) / frame_size - 1;
        
        % go ahead and open the input file
		fid = fopen(file.name);

    otherwise                  % it's a stack of images
        number_of_frames = length(files);
end

% Handle the rest of the argument list 
switch nargin
    case 1
        start = 1;
        stop = number_of_frames;
        stride = 1;
        mode = 'min';
    case 2
        if isempty(start); start = 1; end;1
        stop = number_of_frames;
        stride = 1;
        mode = 'min';
    case 3
        if isempty(start); start = 1; end;
        if isempty(stop); stop = number_of_frames; end;
        stride = 1;
        mode = 'min';
    case 4
        if isempty(start); start = 1; end;
        if isempty(stop); stop = number_of_frames; end;
        if isempty(stride); stride = 1; end;        
        mode = 'min';
    case 5
        if isempty(start); start = 1; end;
        if isempty(stop); stop = number_of_frames; end;
        if isempty(stride); stride = 1; end;        
        if isempty(mode); mode = 'min'; end;
    otherwise
        error('mip:UnknownInputParameter', 'Incorrect number of input parameters.');
end

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;

% now, the meat of the routine.... handle it according to parameters
for k = start : stride :  stop
    tic;
    
    switch ext
        case 'avi'
            im = aviread(file.name, k);
            im =im.cdata;
        case 'raw'
			status = fseek(fid, frame_size*k, 'bof');  % advance to beginning of k'th frame
			im = fread(fid, [648,484],'uint8');   % read in the k'th frame
        otherwise
            try
                im = imread(files(k).name, ext);
            catch
                error('mip:UnknownFileType',  'This image filetype is not recognized.');            
            end        
	end
    
    im = im(:,:,1);
    
    % Maximum or minimum intensity projection code
    if k == start 
        imMIP = double(im);
    else
        temp(:,:,1) = imMIP;
        temp(:,:,2) = double(im);
        
        switch mode
            case 'min'
                imMIP = min(temp,[],3);
            case 'max'
                imMIP = max(temp,[],3);
            case 'mean'
                imMIP = sum(temp,3);
        end
    end
 
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

close(timefig);

if strfind(mode, 'mean');
    imMIP = imMIP / ( (stop-start)/stride );
end


if findstr('raw', ext)
    fclose(fid);
    imMIP = imMIP';
end

switch nargout
    case 0
		figure;
		imagesc(imMIP);
		colormap(gray(256));
    case 1
		v = imMIP;
end

