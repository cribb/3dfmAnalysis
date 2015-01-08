function outfilelist = set_fps_and_calibum(filemask, frame_rate, calibum)

%USAGE:
%     set_fps_and_calibum(filemask, frame_rate, calibum)
%     
if(nargin < 3)
    logentry('Frame rate and/or calibum not defined. Exiting now.');
    error('Frame rate and/or calibum not defined. Exiting now.');
end

video_tracking_constants;
files = dir(filemask);

count = 1;

for i = 1:length(files)
    filename = files(i).name;
    
    logentry(['Loading ' num2str(i) ' of ' num2str(length(files)) '.'] );
    
    d = load_video_tracking(filename, frame_rate, [], [], 'absolute', 'no', 'table');
    d.frame_rate = frame_rate;
    d.calibum = calibum;
    
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

