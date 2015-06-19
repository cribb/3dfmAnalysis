function [table_out,  params] = varforce_init(params)
% VARFORCE_INIT Initializes the varforce computations by loading metadata and tracking data
%
% 3DFM function   
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%  
% Initializes the varforce computations by loading the metadata and tracking data
% attaching pulse voltages and sequence IDs to the video tracking matrix.  Degauss
% events are also handled here.  The timestamps from GLUItake are aligned with the
% sequences by the user selecting a point in the xy-position that is equal to the
% first point in a new sequence.  This argues for using the
% "highest-as-last" voltage
% in a given pulse sequence. The output table contains all the data in columns
% while the metadata parameters are outputted as a structure.
% 
%   [table_out, drive_params] = varforce_init(params)
%                                       
%  where params is the varforce parameters structure.
%

    format long g;

    %%%%
    % constants describing headers for varforce raw datatable
    %%%%
    varforce_constants;
    
    %%%%
    % Hack that handles the nonexistence of degauss location parameters structure.
    %%%%
    if  ~isfield(params, 'deg_loc')
        params.deg_loc = 'middle';
        logentry('No degauss location specified, assumed to be in middle.');
    end
    
    %%%%
    % Some easier variable names for convenience.
    %%%%
    NRepeats     = params.NRepeats;
    pulse_widths = params.pulse_widths;
    voltages     = params.voltages;
    calib_um     = params.calibum;
    trackfile    = params.trackfile;
    deg_loc      = params.deg_loc;
    poleloc      = params.poleloc;
    
    if isfield(params, 'degauss');
        degauss = params.degauss;
    else
        logentry('This data preceeds degauss routine implementation; entering "n" for degauss.');
        params.degauss='off';
        degauss = drive_params.degauss;
    end
    sequence_width = sum(pulse_widths);

    %%%%
    % Load in the video file.
    %%%%
    table = load_video_tracking(trackfile, [], 'm', calib_um, 'absolute', 'yes', 'table');
    
    %%%%
    % Set the initial value for the additional columns to NaN.  This allows
    % for non-numeric placeholders.  Doesn't affect means or other statistics.
    %%%%
    table(:,AREA:DEGAUSS) = NaN;
    
    %%%%
    % Define the zero location as the center of the circle that inscribes
    % the shape of the poletip.
    %%%%
    poleloc     = poleloc * calib_um * 1e-6;
    params.poletip_radius = params.poletip_radius * calib_um * 1e-6;
    table(:,X) = table(:,X) - poleloc(1);
    table(:,Y) = table(:,Y) - poleloc(2);
    
    %%%%
    % reset the clock such that tzero is not in UCT but starts at "t-zero"
    % with respect to the beginning of the calibration run.
    %%%%
    table(:,TIME) = table(:,TIME) - min(table(:,TIME));
    
    %%%%
    % identify location of a break between sequences by clicking on plot
    %%%%
    time_selected = get_sequence_break(table);

    %%%%
    % how many sequences was the selected break into the data?
    %%%%
    seqbreakID = floor(abs(min(table(:,TIME) - time_selected) / sequence_width));
    tzero = time_selected - seqbreakID * sequence_width;

    %%%%
    % remove any data that occurred before the estimated start of magnet
    % sequence
    %%%%
    BCidx = find(table(:,TIME) < tzero);
    table(BCidx,:) = [];
    
    %%%%
    % setup sequence and voltageID event times
    %%%%
    sequence_id    = [0:NRepeats];
    sequence_times = (sequence_id * sequence_width);
    pulse_times    = [0 cumsum(repmat(pulse_widths, 1, NRepeats))];
    pulse_times    = pulse_times(1:end-1);
    voltage_id     = repmat(0:length(voltages)-1, 1, NRepeats);

    %%%%
    % attach sequence ID's
    %%%%
    rel_time = table(:,TIME) - min(table(:,TIME));
    for k = [1 : NRepeats+1]
        if k<(NRepeats+1)
            idx = find(rel_time >= sequence_times(k) & rel_time < sequence_times(k+1));
        elseif (k == (NRepeats+1))
            idx = find(rel_time >= sequence_times(k));
        end
        
        table(idx,SEQ) = k-1;
    end

    
    %%%%
    % attach voltage IDs
    %%%%
    for k = 1:length(pulse_times)-1
        idx = find(rel_time >= pulse_times(k) & rel_time < pulse_times(k+1));
        table(idx,VID) = voltage_id(k);
    end
   

% % % % %%%%
% % % % % look for undefined sequences and remove
% % % % %%%%
% % % % nanidx = find(table(:,SEQ) ~= NaN);
% % % % table = table(nanidx, :);

    %%%%
    % attach degauss label to each sequence
    %%%%
    if findstr(degauss, 'on')
        logentry('Handling degauss.');
        for k = unique(table(:,SEQ))'  % have to loop through each sequence
            DEGidx = find(table(:,SEQ) == k & table(:,VID) == 0); % reduce to zero voltage        \
            
            % you first have to check and see if we find any zero voltage
            % data.  This must be handled because the video spot tracker
            % allows random access to tracking particles, i.e. trackers can
            % pop in and out of existence at any time during any pulse or
            % any sequence.
            if ~isempty(DEGidx)
                if strcmp(deg_loc, 'middle')
                    start_of_degauss = floor(range(DEGidx)/2) + DEGidx(1);
                    table(DEGidx(1):start_of_degauss-1,DEGAUSS) = 0;                                
                    table(start_of_degauss:DEGidx(end),DEGAUSS) = 1; 
                elseif strcmp(deg_loc, 'beginning')                               
                    table(DEGidx,DEGAUSS) = 1;
                end 
            else
                continue;
            end
%                 figure(3543235); 
%                 foo = DEGidx(1):start_of_degauss-1;
%                 bar = start_of_degauss:DEGidx(end);
%                 plot(table(foo,TIME), table(foo,X:Y), 'b.', table(bar,TIME), table(bar,X:Y), 'r.');
%                 pause;
        end
    else
        DEGidx = find(table(:,VID) == 0);
        table(DEGidx,DEGAUSS) = 0;
    end
    
    %%%%%
    % Remove any extraneous entries in the table that have sequence values
    % of NaN.  They are irrelavent data that exist after the driving code
    % has completed.
    %%%%%
    idx = ~isnan(table(:,VID));
    table = table(idx,:);
        
    %%%%
    %% WRAP IT UP
    %%%%
    table_out = table;

    return;


%%%%
%% extraneous functions
%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforce_init: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return

    
% returns the closest time to a mouseclick on a figure of video tracking
function time_selected = get_sequence_break(table)

    varforce_constants;
    
        figure(38383);
        plot(table(:,TIME), magnitude(table(:,X:Y)), '.');
        drawnow;
        pause;

    logentry('Click once on the figure to identify a break between pulse sequences.');
    [tm,xm] = ginput(1);

        close(38383);
        drawnow;

    t = table(:,TIME);
    x = table(:,X);

    tval = repmat(tm, length(t), 1);
    xval = repmat(xm, length(x), 1);

    dist = sqrt((t - tval).^2 + (x - xval).^2);

    time_selected = t(find(dist == min(dist)));
    
    return;
