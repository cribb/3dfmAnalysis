function outfile = save_evtfile(filename, data, xyzunits, calib_um)

    video_tracking_constants;

    if isempty(data)
        logentry('Saving empty dataset.');
        data = ones(0,10);    
    elseif strcmp(xyzunits,'m')
		data(:,X:Z) = data(:,X:Z) ./ calib_um * 1e6;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'um')
		data(:,X:Z) = data(:,X:Z) ./ calib_um;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'nm')
		data(:,X:Z) = data(:,X:Z) ./ calib_um * 1e-3;  % convert video coords from pixels to nm
    elseif strcmp(xyzunits, 'pixels')
        % do nothing
    else
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
    end
        
    tracking.spot3DSecUsecIndexFramenumXYZRPY = data;
    
    logentry(['Saving ' num2str(length(unique(data(:,ID)))) ' trackers in ' filename]);
    
    filename = strrep(filename, '.evt', '');
    filename = strrep(filename, '.mat', '');
    outfile = [filename '.evt.mat'];
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