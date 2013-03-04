function v = vid_frame_mean(files, start, stop, savename, stride)


% 3DFM Function
% Video
% Last modified by Robert Judith 2013.01
% This code is based of of Jeremy Cribbs MIP code.
%
% MFavg outputs the average intensity for each frame of a movie (avi or 
% raw), or stack of images in any matlab suported format. A vector of the
% values is returned and can be saved to a cvs file.
% x = vid_frame_mean(files, start, stop, savename, stride)
% where "files" is an .avi or .raw file or stack of images
%        "start" is starting frame number, defaults to first frame.
%        "stop"  is ending frame number, defaults to last frame.
%        "savename" is the desired name for the csv file. If left blank the data is not saved.
%        "stride" is the number of frames to jump between "start" and "stop"    

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
        savename = 0;
        
    case 2
        if isempty(start); start = 1; end;
        stop = number_of_frames;
        stride = 1;
        savename = 0;
        
    case 3
        if isempty(start); start = 1; end;
        if isempty(stop); stop = number_of_frames; end;
        stride = 1;
        savename = 0;
        
    case 4
         if isempty(start); start = 1; end;
         if isempty(stop); stop = number_of_frames; end;
         if isempty(savename); savename = 0; end;
         stride =1;
         
    case 5
         if isempty(start); start = 1; end;
         if isempty(stop); stop = number_of_frames; end;
         if isempty(savename); savename = 0; end;
         if isempty(savename); stride = 1; end;

    otherwise
        error('mip:UnknownInputParameter', 'Incorrect number of input parameters.');
end

% set up text-box for 'remaining time' display
[timefig,timetext] = init_timerfig;
%Predefine output matrix v
meanI = zeros(number_of_frames,1);
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
    meanI(k) = mean(im(:));
 
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

%Writes Data To CSV File if there is a save name
if savename ~= 0
    headers = {'Avg'};
            savename = strcat(savename,'.csv');
            sfile = fopen(savename,'w');
                % Write headers
                for i=1:length(headers)
                    fprintf(sfile,'%s,',headers{i});
                end
            fprintf(sfile,'\n');
            fclose(sfile);

            %write data
            dlmwrite(savename, meanI,'-append');
end
switch nargout
    case 0
		figure;
		plot(meanI);
    case 1
		v = meanI;
end

