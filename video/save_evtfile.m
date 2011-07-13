function outfile = save_evtfile(filename, data)

    video_tracking_constants;

    tracking.spot3DSecUsecIndexFramenumXYZRPY = data;
    
    logentry(['Saving ' num2str(length(unique(data(:,ID)))) ' trackers in ' filename]);
    
    outfile = [filename(1:end-3) 'evt.mat'];
    save(outfile, 'tracking');   
    
return;


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'save_evtfile: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;