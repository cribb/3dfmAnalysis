function v = extract_magnet_log(magnet_log_file, expt_time_stamps);
% 3DFM function  
% Magnetics 
% last modified 07/19/2005
%  
% This function does something  
%  
%  [outputs] = function_name(parameter1, parameter2, etc...);  
%   
%  where "magnet_log_file" is logfile from 3dfm force server in .mat format
%        "expt_time_stamps" is [something in [sec], UTC format
%  
%  07/19/05 - created; jcribb.
%   

try
    mag = load(magnet_log_file);
catch
    error('Magnet log file not found.');
end


% extract time stamps recorded in magnet log.  To preserve precision 
% (significant digits) these timestamps are recorded in two integers, 
% the first being time in seconds since midnight Jan 1, 1970 (UCT)
% and the second being microseconds.  We combine those here into one
% number and matlab keeps precision down to tenths of microseconds (10 kHz)
magtime = mag.magnets.time(:,1) + mag.magnets.time(:,2) / 1e6;


% We make the assumption that the magnets log file envelops the
% experimental time scale.  We check for that here...
if ( min(magtime) > min(expt_time_stamps) ) | ...
   ( max(magtime) < max(expt_time_stamps)

    error('Magnet data does not exist for all times recorded in experiment.');
end


% extract only that information in the magnet log that coincides with the
% times recorded for the experiment.
idx = find( magtime >= min(expt_time_stamps) & magtime <= max(expt_time_stamps) );

% We're done.  Export appropriate information.
v.time    = magtime(idx);
v.analogs = mag.magnets.analogs(idx,:);

