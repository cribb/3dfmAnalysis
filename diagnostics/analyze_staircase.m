function v = analyze_staircase(stagefile, videofile, videofps)
% 3DFM function  
% Diagnostics 
% last modified 05/07/04 
%  
% This function analyzes "staircase" datasets, where a staircase shaped 
% step-input is applied to one or more axes of the Mad City Labs stage.  
% Immobilized objects (e.g. beads) are tracked via video-feed and the 
% resulting video-tracking data serves as the output.  Using input and
% output data streams, some measurements are made to estimate noise and
% tracking quality.
%  
%  [v] = analyze_staircase(stagefile, videofile, videofps);  
%   
%  where "stagefile" is *.mcl.mat filename containing MCL and QPD data
%        "videofile" is *.vrpn.mat filename containing tracked video data
%		     "videofps"  is frames_per_second of camera
%  
%  Notes:  
%   
%   
%  03/10/04 - created; jcribb
%  05/07/04 - added documentation; jcribb
%   
%  


% 	stage_file = 'staircase_workspace.mat';
%     videofile = './2004.02.25/staircase_y_110sec_04nm.vrpn.mat';

    % load the stage file.  This contains sensed and command signals from MCL stage.
    % constructs a 'steps' variable
	load(stagefile);

	% load the video tracking datasets
	d = load_video_tracking(videofile,videofps,[],[],'rectangle','pixels');
	
	% set constants for MCL stage
	stage_Volts_to_nm = 10 * 1000;  % conversion factor for V to um to nm.
	
	% the time signal for the commanded and sensed MCL vectors should be equal to:
    if exist('steps.time')
        stagetime = steps.time;
    else
        stagetime = [1/200 : 1/200 : length(steps.commanded)/200]';
    end;

    % pull out command and sensed signals from structures and convert from V -> nm
	commands = steps.commanded(:,1) * stage_Volts_to_nm;
	sensed = steps.reportedPos(:,1) * stage_Volts_to_nm;

    % upsample signals to stagefrequency*10.  This will be used to better 
	% align the datasets with respect to time delay between protomcl output and pulnix output
	% 
	hyperstagetime   = [stagetime(1) : mean(diff(stagetime)) / 10 : stagetime(end)]';
	commands = interp1(stagetime, commands, hyperstagetime);
	sensed   = interp1(stagetime, sensed, hyperstagetime);
	videoy   = interp1(d.video.time, d.video.y, hyperstagetime); 
    stagetime = hyperstagetime;
    
	% setup and apply the calibration between the commands and sensed signals.  
    % Use the command signal as the reference.
	Pc   = polyfit(stagetime, commands,1);          % get the slope/intercept for command signal
	Ps   = polyfit(stagetime, sensed,1);            % get the slope/intercept for sensed signal
	ref_commands = commands - Pc(2);                % remove the offset (intercept) from the command signal
	ref_sensed = (Pc(1)/Ps(1)) * sensed;            % calibrate sensed signals by the ratio of slopes (command/sensed)
	Pref = polyfit(stagetime, ref_sensed, 1);       % get the slope/intercept for the new sensed signal
	ref_sensed = ref_sensed - Pref(2);              % subtract off offset (intercept)
    

    % now that we have calibrated sensed and command signals, we want to calibrate our
    % video signals to the new reference signal.  We need to iterate for each bead
    [r c] = size(videoy);
    for k = 1 : c
   
		Pv   = polyfit(stagetime, videoy(:,k),1);   % get the slope/intercept for the kth bead
		ref_videoy = (Ps(1)/Pv(1)) * videoy(:,k);   % calibrate video signal by the ratio of slopes (sensed/video)
		Pvref= polyfit(stagetime, ref_videoy, 1);   % get slope/intercept for new video signal
		ref_videoy = ref_videoy - Pvref(2);         % subtract off offset(intercept)
		Pfinal = polyfit(stagetime, ref_videoy,1);
		new_videoy(:,k) = ref_videoy;               % store results in temporary video variable (export later)
        
    end	

    % Variable juggling
    videoy = new_videoy;        
    commands = ref_commands;
    sensed = ref_sensed;
    
		% % % % % Can we find the delay by cross correlating the signals?
		% % % % s = xcorr(commands,videoy(:,1));
		% % % % s_peak = find(s == max(s));
		% % % % s_peak_dist_from_center = length(s)/2 - s_peak;
		
		% hand-discovered delay value (because above code doesn't work yet)
		index_delay = 4000;
		
		% Offset the command and video signals by the delay discovered above
		stagetime   = stagetime(1:end-(index_delay-1));
		commands = commands(1:end-(index_delay-1));
		sensed   =   sensed(1:end-(index_delay-1));
		videoy   = videoy(index_delay:end,:);
		
% 		indices_to_keep = find(diff(commands) == 0);
% 		indices_to_lose = find(diff(commands) ~= 0);
		
		% compute sys_error as rms(sensed_signal - command_signal)
		sys_error = rms(sensed - commands);
		
		% compute cerror as rms(command_signal - video_signal)
		rms_cerror = rms(repmat(commands,1,size(d.video.y,2)) - videoy);
		
		% compute serror as rms(sensed_signal - video_signal)
		rms_serror = rms(repmat(sensed,1,size(d.video.y,2)) - videoy);

	v.sys_error = sys_error;
    v.rms_cerror = rms_cerror;
    v.rms_serror = rms_serror;
    v.time      = stagetime;
    v.commands   = commands;
    v.sensed     = sensed;
    v.videoy     = videoy;
    
    
