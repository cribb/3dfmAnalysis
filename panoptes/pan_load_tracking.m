function [dataout, summary] = pan_load_tracking(filepath, systemid, filetype, filt)
% PAN_LOAD_TRACKING loads all tracking files for a panoptes run
%
% Panoptes function 
% 
% This function contains  
% 
% function dataout = pan_load_tracking(filepath, systemid) 
%
% where "dataout" is the outputted data structure for the entire run
%       "filepath" defines the location for tracking data and metadata files
%       "systemid" defines the systed used, is either 'Monoptes' or 'Panoptes'
%       "exityn" if 'y' matlab closes after finishing the analysis
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can be used manually from the matlab command line interface.
%

% First, set up default values for input parameters in case they are empty 
% or otherwise do not exist.  
if nargin < 3 || isempty(filetype)
    filetype = 'vrpn';
end

% defaults to the single-channel instrument
if nargin < 2 || isempty(systemid)
    systemid = 'monoptes';
end

% Pull in constants for panoptes video tracking structure
pan_video_tracking_constants;

% moving to the path defined as the 'root for the experimental data'
cd(filepath);

% start a timer (to report computation time later on)
tid = tic;

% load the metadata from the appropriate files generated by PanopticNerve
metadata = pan_load_metadata(filepath, systemid, '96well');

filelist = metadata.files.tracking.csv;

Nfiles = length(filelist);

logentry(['Combining ' num2str(Nfiles) ' tracking files.']);

dataout = [];

for k = 1:Nfiles
    [mywell mypass] = pan_wellpass(filelist(k).name);
    
    switch filetype 
        case 'vrpn'
            myfile = filelist(k).name;
        case 'csv'
            myfile = filelist(k).name;
            myfile = strrep(myfile, 'vrpn.mat', 'csv');

        otherwise
            error('Unknown filetype. Use ''vrpn'' or ''csv'' instead.');
    end

    d_in = load_video_tracking(myfile, ...
                              metadata.instr.fps_imagingmode, ...
                              'pixels', ...
                              1, ...
                              'absolute', ...
                              'no', ...
                              'matrix');
    video_tracking_constants;                           
    if nargin >= 4 && ~isempty(filt)
        [d_in, newfilt] = filter_video_tracking(d_in, filt);        
    end
    
    % OLD SPEC
    % These constants come from 'video_tracking_constants' specification but
    % are renamed here. They are used for importing data from vrpn.mat files 
    % outputted by vrpnlog2matlab converter
    video_tracking_constants;
                                
    if ~isempty(d_in)
        numrows = size(d_in,1);
        
        pass_vec = repmat(mypass,numrows,1);
        well_vec = repmat(mywell,numrows,1);


        % New spec for pan_load_tracking
        d(:,PANPASS)  = pass_vec;
        d(:,PANWELL)  = well_vec;
        d(:,PANFRAME) = d_in(:,FRAME);
        d(:,PANID)    = d_in(:,ID);
        d(:,PANX)     = d_in(:,X);
        d(:,PANY)     = d_in(:,Y);
        d(:,PANAREA)  = d_in(:,AREA);
        d(:,PANSENS)  = d_in(:,SENS);
            
        dataout = [dataout ; d];
        
        % summarize the information for each video (this should be remoted
        % off to another function
        num_trackers = length(unique(d(:,PANID)));
        tracker_with_longest_duration = mode(d(:,PANID));
        longest_duration = max( d( d(:,PANID) == tracker_with_longest_duration, PANFRAME));
        
        % well, pass, num_trackers, tracker_with_longest_duration, longest_duration
        summary(k,:) = [mywell mypass num_trackers tracker_with_longest_duration longest_duration];
        
        clear d; % so next sizes are correct
    end
    
end

elapsed_time = toc(tid); 

logentry(['Combining these data files took ' num2str(elapsed_time) ' seconds.']);

% dataout = 0;

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
     headertext = [logtimetext 'pan_load_tracking: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    

return;
