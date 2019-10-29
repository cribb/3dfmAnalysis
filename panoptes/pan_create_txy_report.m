function dataout = pan_create_txy_report(filepath, systemid)
% PAN_CREATE_TRAV_REPORT creates tracker availability report for a Monoptes/Panoptes experiment
%
% Panoptes function 
% 
% This function contains  
% 
% function dataout = pan_create_trav_report(filepath, systemid) 
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

video_tracking_constants;

% defaults the single-channel instrument
if nargin < 2 || isempty(systemid)
    systemid = 'monoptes';
end

% does not exit matlab by default when the analysis run is complete
if nargin < 3 || isempty(exityn)
    exityn = 'n';
end

% moving to the path defined as the 'root for the experimental data'
cd(filepath);

% start a timer (to report computation time later on)
tid = tic;

% load the metadata from the appropriate files generated by PanopticNerve
metadata = pan_load_metadata(filepath, systemid, '96well');


filelist = metadata.files.tracking.csv;

Nfiles = length(filelist);

duration = metadata.instr.seconds;

logentry(['Plotting the longest trajectories for ' num2str(Nfiles) ' files.']);

for k = 1:Nfiles
    d = load_video_tracking(filelist(k).name, ...
                        metadata.instr.fps_imagingmode, ...
                        'pixels', 1, ...
                        'absolute', 'no', 'table');
                    
    if ~isempty(d)
        tracker_list = unique(d(:,ID));
        txy_file_temp = strrep(filelist(k).name, 'vrpn.mat', '');
        txy_file_temp = strrep(txy_file_temp, 'vrpn.evt.mat', ''); 
        
        txy_file{k} = [txy_file_temp  'txy'];

            longest_tracker = mode(tracker_list);
            LTidx = find(d(:,ID) == longest_tracker);
            this_trajectory = d(LTidx,:);

            x_px = ( this_trajectory(:,X) - this_trajectory(1,X) );
            y_px = ( this_trajectory(:,Y) - this_trajectory(1,Y) );
            
            XTfig = figure;
            plot(this_trajectory(:,TIME), [ x_px, y_px ], '.-'); 
            set(gca, 'XLim', [0 duration]);
            xlabel('time [s]');
            ylabel('displacement [px]');
            legend('x', 'y');    
            set(XTfig, 'DoubleBuffer', 'on');
            set(XTfig, 'BackingStore', 'off');    
            drawnow;

            saveas(XTfig, [txy_file{k} '.png'], 'png');
            close(XTfig)
    end
    
end

elapsed_time = toc(tid); 

logentry(['Plotting these data took ' num2str(elapsed_time) 'seconds.']);

dataout = 0;

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
     headertext = [logtimetext 'pan_create_trav_report: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    

return;
