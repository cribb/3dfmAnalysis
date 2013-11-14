function h = plot_tracker_txy(data, h, optstring)   
% PLOT_TRACKER_TXY Plots xy displacments over time for trackers 
%
% 3DFM function
% tracking
% last modified 11/01/13 (cribb)
%  
%  h = plot_tracker_txy(data, h, optstring)  
%   
%  where "h" is the input/output figure handle
%  "frame" is a vector containing frame numbers []
%  "visc" is a vector containing tracker ID numbers []
%  "optstring" is an optional string that doesn't do anything yet
%

    if nargin < 4 || isempty(optstring)
        optstring = '';
    end

    if nargin < 3 || isempty(h)
        h = figure; 
    end

    if nargin < 2
        error('No data specified.');
    end

    video_tracking_constants;
    
    figure(h);
%     set(h,'Visible','off');
    plot(frame, beadID, '.');
    xlabel('frame number');
    ylabel('Tracker ID');
%     set(handles.AUXfig, 'Units', 'Normalized');
%     set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
%     set(h, 'DoubleBuffer', 'on');
%     set(h, 'BackingStore', 'off');    
    drawnow;
    
return;