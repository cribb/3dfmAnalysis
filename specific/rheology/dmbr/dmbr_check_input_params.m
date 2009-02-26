% handles values inside the input parameters structure
function input_params = dmbr_check_input_params(input_params);

    if ~isfield(input_params, 'metafile');    
        logentry('No metafile found.  Exiting now....');
        error('');
    end

    if ~isfield(input_params, 'trackfile');    
        logentry('No trackfile found.  Exiting now....');
        error('');
    end
   
    if ~isfield(input_params, 'calibfile');    
        logentry('No force calibration file found.  Exiting now....');
        error('');
    end
    
    if ~isfield(input_params, 'poleloc');
        logentry('No pole location found.  Exiting now....');
        error('');
    end

    if ~isfield(input_params, 'poletip_radius');    
        logentry('No poletip radius entered.  Assuming no offset from described monopole location.');
        input_params.poletip_radius = 0;
    end

    if ~isfield(input_params, 'drift_remove');
        logentry('no drift removal preference entered, Assuming you want to remove drift');
        input_params.drift_remove = 'on';
    end

    if ~isfield(input_params, 'num_buffer_points');
        logentry('no buffer point number entered, Assuming you want to remove zero');
        input_params.num_buffer_points = '0';
    end

    if ~isfield(input_params, 'granularity');
        logentry('No granularity entered.  Assuming you want a granularity of 8');
        input_params.granularity = 8;
    end

    if ~isfield(input_params, 'window_size');
        logentry('No window size entered.  Assuming you want a window size of 1');
        input_params.window_size = 3;                
    end

    if ~isfield(input_params, 'wn');
        logentry('No smoothing parameter specified.  Setting wn to 2.');
        input_params.wn = 2;
    end
    
    if ~isfield(input_params, 'plot_results');
        logentry('No automatic plotting.  Set .plot_results ''on'' to change this.');
        input_params.plot_results = 'off';
    end

    if ~isfield(input_params, 'tau');
        logentry('No tau (time constant for Wi).  Setting to 6.25 seconds.');
        input_params.tau = 6.25;
    end
    
    if ~isfield(input_params, 'fit_type');
        logentry('No fit_type specified, assuming Jeffrey model.');
        input_params.fit_type = 'Jeffrey';
    end
    
    if ~isfield(input_params, 'scale');
        logentry('no scale specified.  defaulting to 0.5 stdev.');
        input_params.scale = 0.5;
    end


    return;
    
    
    %% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_check_input_params: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;
