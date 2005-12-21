function [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
%
% [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% 
% v = data minus drift
% q = drift vector
% type = 'linear' or 'center-of-mass'
%

    % handle "global" variables that contain column positions for video
    global TIME ID FRAME X Y Z ROLL PITCH YAW;     
    video_tracking_constants;  

    % handle the argument list
    if ~exist('data');
        error('No data found.'); 
    end;
    
    if nargin < 4 | isempty(type); 
        type = 'linear'; 
        logentry('No drift type specified.  Choosing linear method.');
    end;

    if nargin < 3 | isempty(drift_end_time); 
        drift_end_time = max(data(:,TIME)); 
        logentry('No end_time specified.  Choosing last time in dataset.');
    end;

    if nargin < 2 | isempty(drift_start_time); 
        drift_start_time = min(data(:,TIME)); 
        logentry('No start_time specified.  Choosing first time in dataset.');
    end;
    
    if nargin < 1 | isempty(data); 
        error('No data found.'); 
    end;

	switch type
        case 'linear'
            [v,q] = linear(data, drift_start_time, drift_end_time);
        case 'center-of-mass'
            [v,q] = center_of_mass(data, drift_start_time, drift_end_time);            
        otherwise
            [v,q] = linear(data, drift_start_time, drift_end_time);
            logentry('Specified type is undefined.  Switching to linear method.');
	end
        
    return
    
function [v,q] = center_of_mass(data, drift_start_time, drift_end_time);
% at each time point, average all beads x, y, and z values to determine
% center of mass vector and subtract that from each bead's position.
% This routine is insensitive to the disapperance of old trackers or the 
% sudden existence of new trackers.  This may cause sudden 'jumps' in the 
% center-of-mass, so a polyfit of the center-of-mass should be used.

    global TIME ID FRAME X Y Z ROLL PITCH YAW;   

    order = 1;
    
    % clip data to desired time points
    t_idx = find( data(:,TIME) >= drift_start_time & data(:,TIME) <= drift_end_time);
    data = data(t_idx,:);
    
	% set up text-box for 'remaining time' display
	[timefig,timetext] = init_timerfig;

    % compute center of mass at each frame by looking at existing
	% tracker locations.  
    minframe = min(data(:, FRAME));
    maxframe = max(data(:, FRAME));
    frame_vector = [minframe : maxframe];
    
    t = data(:,TIME);
    t0 = t(1);
    t = t - t0;
    
    for k = 1 : length(frame_vector)
        
        tic;
        
        thisframe_idx = find(data(:, FRAME) == frame_vector(k));
        
        if length(thisframe_idx) > 1
            com(k,:) = [mean(data(thisframe_idx, X)) mean(data(thisframe_idx, Y)) mean(data(thisframe_idx,Z))];  
        end

        timevec(k,1) = t(thisframe_idx(1));
        
        % handle timer
		itertime = toc;
		if k == 1
            totaltime = itertime;
		else
            totaltime = totaltime + itertime;
		end    
		meantime = totaltime / k;
		timeleft = (maxframe-k) * meantime;
		outs = [num2str(timeleft, '%5.0f') ' sec.'];
		set(timetext, 'String', outs);
        drawnow;

    end

    % construct polyfits for the drift vectors to low-pass filter any
    % sudden shifts in the center-of-mass and to avoid problems for
    % trackers who may not exist for the entire duration of the dataset.            
    x_drift_fit = polyfit(timevec, com(:,1), order);
    y_drift_fit = polyfit(timevec, com(:,2), order);
    z_drift_fit = polyfit(timevec, com(:,3), order);    

    logentry(['center-of-mass: x-slope: ' num2str(x_drift_fit(1)) '  x-intercept: ' num2str(x_drift_fit(2))]);
        
        % test plot
        figure(66);
        subplot(2,2,1);
        plot(timevec, com(:,1), '.', timevec, polyval(x_drift_fit, timevec), 'r');
        title('center of mass X vector');
        xlabel('time [s]');
        ylabel('pixels');
        legend('data', 'fit');
        
        figure(66);
        subplot(2,2,2);
        plot(timevec, com(:,2), '.', timevec, polyval(y_drift_fit, timevec), 'r');
        title('center of mass Y vector');
        xlabel('time [s]');
        ylabel('pixels');
        legend('data', 'fit');

        figure(66);
        subplot(2,2,4);
        axis([0 648 0 484]);
        plot(data(:,X), data(:,Y), 'bo', com(:,1), com(:,2), 'g.');
        xlabel('x position'); 
        ylabel('y position');
        
    for k = 0 : get_beadmax(data)
        thisbead_idx = find(data(:,ID) == k);

        x_drift_val = polyval(x_drift_fit, t(thisbead_idx));
        y_drift_val = polyval(y_drift_fit, t(thisbead_idx));
        z_drift_val = polyval(z_drift_fit, t(thisbead_idx));
        
        x_data_fit = polyfit(t(thisbead_idx), data(thisbead_idx, X), order);
        y_data_fit = polyfit(t(thisbead_idx), data(thisbead_idx, Y), order);
        z_data_fit = polyfit(t(thisbead_idx), data(thisbead_idx, Z), order);    
        
        logentry(['tracker ' num2str(k) ': x-slope: ' num2str(x_data_fit(1)) '  x-intercept: ' num2str(x_data_fit(2))]);
        x_data_val = polyval(x_data_fit, t(thisbead_idx));
        y_data_val = polyval(y_data_fit, t(thisbead_idx));
        z_data_val = polyval(z_data_fit, t(thisbead_idx));
      
		% test plots
        figure(66);
        subplot(2,2,3);
        plot(t(thisbead_idx),data(thisbead_idx, X), '.' , t(thisbead_idx),x_data_val, 'r');

        data(thisbead_idx,X) = data(thisbead_idx,X) - x_drift_val + x_drift_fit(end);
        data(thisbead_idx,Y) = data(thisbead_idx,Y) - y_drift_val + y_drift_fit(end);
        data(thisbead_idx,Z) = data(thisbead_idx,Z) - z_drift_val + z_drift_fit(end);
        

        % test plots 
        figure(66);
        subplot(2,2,4);
        hold on; 
        plot(data(thisbead_idx,X), data(thisbead_idx,Y), '.r');
        hold off;
        axis([0 648 0 484]);
        legend('original', 'com', 'corrected');
        pretty_plot;
        
        drawnow;
%         pause;
    end

    close(timefig);
    
    v = data;
    q = com;    
    
    return;

function [v,q] = linear(data, drift_start_time, drift_end_time);

    global TIME ID FRAME X Y Z ROLL PITCH YAW;   

    for k = 0 : get_beadmax(data);

        bead = get_bead(data, k);

        t = bead(:,TIME);
        t0 = t(1);
        t = t - t0;
            
        idx = find(t >= (drift_start_time - t0) & t <= (drift_end_time - t0));
                
        if ( length(idx) > 2 )            
            
            fitx = polyfit(t(idx), bead(idx,X), 1);
            beadx = bead(:,X) - polyval(fitx, t) + fitx(2);
	
            fity = polyfit(t(idx), bead(idx,Y), 1);
            beady = bead(:,Y) - polyval(fity, t) + fity(2);
            
            fitz = polyfit(t(idx), bead(idx,Z), 1);
            beadz = bead(:,Z) - polyval(fitz, t) + fitz(2);

            logentry(['Bead ' num2str(k) ': Removed linear drift velocity of x=' num2str(fitx(1)) ', y=' num2str(fity(1)) ', z=' num2str(fitz(1)) '.']);
            % implement fits for ROLL PITCH AND YAW later.
            
            tmp = bead;
            tmp(:,X) = beadx;
            tmp(:,Y) = beady;
            tmp(:,Z) = beadz;
            
            if ~exist('newdata')
                newdata = tmp;
            else
                newdata = [newdata ; tmp];
            end
        else
            logentry(['Not enough data in bead ' num2str(k) ' to do drift subtraction (empty tracker?).']);
        end
    end    

    v = newdata;
    q = [fitx; fity; fitz];
    
    return;

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'remove_drift: '];
     
     fprintf('%s%s\n', headertext, txt);

