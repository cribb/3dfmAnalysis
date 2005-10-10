function [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% data must come from load_video_tracking
% v = data minus drift
% q = drift vector

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
    idx = find( data(:,TIME) >= drift_start_time & data(:,TIME) <= drift_end_time);

    % compute center of mass at each frame by looking at existing
	% tracker locations.  
    meetee = data(idx, TIME);
    for k = 1 : length(idx)
        blah = find(data(idx,TIME) == meetee(k));
        com(k,:) = [mean(data(blah, X)) mean(data(blah, Y)) mean(data(blah,Z))];        
    end

    % construct polyfits for the drift vectors to low-pass filter any
    % sudden shifts in the center-of-mass and to avoid problems for
    % trackers who may not exist for the entire duration of the dataset.
    xfit = polyfit(data(idxt,TIME), com(:,1), 2);
    yfit = polyfit(data(idxt,TIME), com(:,2), 2);
    zfit = polyfit(data(idxt,TIME), com(:,3), 2);    
    
    xdrift = polyval(xfit, data(idxt,TIME));
    ydrift = polyval(yfit, data(idxt,TIME));
    zdrift = polyval(zfit, data(idxt,TIME));
    
    for k = 0 : get_beadmax(data)
        idx = find(data(:,ID) == k);
        data(idx,X:Z) = data(idx,X:Z) - [xfit(idx) yfit(idx) zfit(idx)];
    end

    v = data;
    q = com;
    
    return;

function [v,q] = linear(data, drift_start_time, drift_end_time);

    global TIME ID FRAME X Y Z ROLL PITCH YAW;   

    for k = 0 : get_beadmax(data);

        bead = get_bead(data, k);
        
        if length(bead) > 1)
            t = bead(:,TIME);
            t0 = t(1);
            t = t - t0;
            
            idx = find(t >= (drift_start_time - t0) & t <= (drift_end_time - t0));
            
            fitx = polyfit(t(idx), bead(idx,X), 1);
            beadx = bead(:,X) - polyval(fitx, t) + fitx(2);
	
            fity = polyfit(t(idx), bead(idx,Y), 1);
            beady = bead(:,Y) - polyval(fity, t) + fity(2);
            
            fitz = polyfit(t(idx), bead(idx,Z), 1);
            beadz = bead(:,Z) - polyval(fitz, t) + fitz(2);
	
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
            logentry(['There is not enough data in bead ' k ' to do drift subtraction (empty tracker?).']);
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

