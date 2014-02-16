function outfile = save_evtfile(filename, data, xyzunits, calib_um)
% SAVE_EVTFILE saves tracking data to the evt.vrpn.mat format 
%
% 3DFM function
% video
% last modified 2013.09.08 (cribb)
%
% This function saves tracking data (eg. from simulations, etc) to the
% evt.vrpn.mat format used in EVT_GUI.  This format retains the length scale
% calibration information provided in the function call as a field in the
% evt data structure (tracking.calib_um).
%
% [outfile] = save_evtfile(filename, data, xyzunits, calib_um)
%
% where "outfile" is the filename where save_evtfile saved the data.
%       "filename" is the filename where save_evtfile will save the data. 
%       "data" is a table of tracking data used in video_spot_tracker.  The
%              column id's can be found in the 'video_tracking_constants'
%              file, but are typically in this order: TIME, FRAME, ID, X,
%              Y, Z, ROLL, PITCH, YAW.
%       "xyzunits" defines the length scale units used in the "data" input,
%                  which can be 'm' (meters), 'um', 'nm', or 'pixels'
%       "calib_um" defines the length scale calibration in [um/pixel]
%

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
    tracking.calib_um = calib_um;       
    
    filename = strrep(filename, '.vrpn', '');
    filename = strrep(filename, '.evt', '');
    filename = strrep(filename, '.mat', '');
    outfile = [filename '.vrpn.evt.mat'];
    
    save(outfile, 'tracking');   
    logentry(['Saved ' num2str(length(unique(data(:,ID)))) ' trackers in ' outfile]);
    
return;


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'save_evtfile: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;