function outfilelist = SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels, tcrop, xycrop)

%USAGE:
%     SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels, tcrop,
%     xycrop)
%     
if(nargin < 4)
    minPixels = 0;
end

video_tracking_constants;
files = dir(filemask);

count = 1;

for i = 1:length(files)
    filename = files(i).name;
    
    filt.min_frames = minFrames;
    filt.min_pixels = minPixels;
    filt.tcrop     = tcrop; 
    filt.xycrop    = xycrop;
    
    logentry(['Loading ' num2str(i) ' of ' num2str(length(files)) '.'] );
    
    d = load_video_tracking(filename, frameRate, [], [], 'absolute', 'no', 'matrix');
    d = filter_video_tracking(d, filt);
    
    if ~isempty(d)

        outfile = save_evtfile(filename, d, 'pixels');
               
        if count <= 1
            outfilelist = dir(outfile);
        else
            outfilelist(count) = dir(outfile);
        end
            
        count = count + 1;
    else
        logentry('No trackers. No .evt.mat created. \n');
        
    end
    
    if ~exist('outfilelist','var');
        outfilelist = [];
    end
    
    
end

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'SetFPSandMinFrames: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;
