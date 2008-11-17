function v = varforce_construct_spatial_map(Ftablein, params)
% VARFORCE_CONSTRUCT_SPATIAL_MAP instantaneous derivative method of determining force 
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%
% (NOT FULLY IMPLEMENTED)  instantaneous derivative method of determining force
% 
%   v = varforce_construct_spatial_map(Ftablein, params)
%
% where 
% 

    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;

    varforce_constants;
    
    calib_um    = params.calibum;
    poleloc     = params.poleloc;
    granularity = params.granularity;

    width = 648;
    height = 484;

    x = Ftablein(:,1);
    y = Ftablein(:,2);
    F = Ftablein(:,3);
    V = Ftablein(:,5);
    pulse_list = unique(V);
    
    % now set up the binning process... if there is no data in a bin, 
    % it's a divide by zero. we don't care about that.
    warning off MATLAB:divideByZero; 

    % we want all length scales in SI units, meters.    	
    x_bins(:,1) = [1 : granularity : width] * calib_um * 1e-6;
    y_bins(:,1) = [1 : granularity : height] * calib_um * 1e-6;
    
    for myVolt = 1:length(pulse_list)
        tic;
        
        % observe only the current voltage
        idx = find(V == pulse_list(myVolt));
        
        [im_mean(:,:,myVolt), im_stderr(:,:,myVolt)] = bin2d(x(idx), y(idx), F(idx), x_bins, y_bins);
        

        % handle timer
        itertime = toc;
        if myVolt == 1
            totaltime = itertime;
        else
            totaltime = totaltime + itertime;
        end    
        meantime = totaltime / myVolt;
        timeleft = ( length(pulse_list) - myVolt) * meantime;
        outs = [num2str(timeleft, '%5.0f') ' sec.'];
        set(timetext, 'String', outs);
        drawnow;
    end

    close(timefig);

    % output variables to structure, v
    v.force_map = im_mean;
    v.error_map = im_stderr;
    v.x_bins = x_bins;
    v.y_bins = y_bins;
    v.step = granularity * calib_um * 1e-6;    
    



    
