function [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% REMOVE_DRIFT Subtracts drift from 3DFM video tracking data.
%
% [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% 
% v = data minus drift
% q = drift vector/struct
% type = 'linear' or 'center-of-mass'
%

    % handle "global" variables that contain column positions for video
    video_tracking_constants;  

    % handle the argument list
    if nargin < 1 
        data = [];
    end
    

    if isempty(data) || sum(isnan(data(:))) == length(data(:))
        logentry('No data found. Exiting function.'); 
        v = data;
        q = [];
        return;
    end

    if nargin < 2 || isempty(drift_start_time)
        drift_start_time = min(data(:,TIME)); 
%         logentry('No start_time specified.  Choosing first time in dataset.');
    end
   
    if nargin < 3 || isempty(drift_end_time)
        drift_end_time = max(data(:,TIME)); 
%         logentry('No end_time specified.  Choosing last time in dataset.');
    end

    if nargin < 4 || isempty(type)
        type = 'linear'; 
        logentry('No drift type specified.  Choosing linear method.');
    end

%     if nargin < 5 | isempty(plotOption); 
%         type = 'y'; 
%         logentry('No plot option specified.  Choosing to plot drift vectors.');
%     end;
    
    
    switch type
        case 'linear'
            [v,q] = linear(data, drift_start_time, drift_end_time);
        case 'center-of-mass'
            [v,q] = center_of_mass(data, drift_start_time, drift_end_time); 
        case 'linearMean'
            [v,q] = linearMean(data, drift_start_time, drift_end_time);
        case 'common-mode'
            [v,q] = common_mode(data, drift_start_time, drift_end_time);
        otherwise
            [v,q] = linear(data, drift_start_time, drift_end_time);
            logentry('Specified type is undefined.  Switching to linear method.');
	end
        
    return

function [cleaned_v,common_v] = common_mode(v, drift_start_time, drift_end_time)
    common_v = traj_common_motion(v);
    cleaned_v  = traj_subtract_common_motion(v, common_v);        
return


function [cleaned_v,com_v] = center_of_mass(v, drift_start_time, drift_end_time)
    common_v = traj_common_motion(v);
    [cleaned_v, com_v] = traj_subtract_centmass_motion(v, common_v);
return


function [v,drift_vectors] = linear(data, drift_start_time, drift_end_time)


    video_tracking_constants;

    for k = unique(data(:,ID))'

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

%             logentry(['Bead ' num2str(k) ': Removed linear drift velocity of x=' num2str(fitx(1)) ', y=' num2str(fity(1)) ', z=' num2str(fitz(1)) '.']);

            % implement fits for ROLL PITCH AND YAW later.
            
            tmp = bead;
            tmp(:,X) = beadx;
            tmp(:,Y) = beady;
            tmp(:,Z) = beadz;
            
            if ~exist('newdata')                
                newdata = tmp;
                drift_vectors = [fitx, fity, fitz];
            else
                newdata = [newdata ; tmp];
                drift_vectors = [drift_vectors ; fitx, fity, fitz];
            end
        else
            logentry(['Not enough data in bead ' num2str(k) ' to do drift subtraction (empty tracker?).']);
        end
    end    

    if exist('newdata')
        v = newdata;
    else
        v = data;
        drift_vectors = [NaN NaN NaN];
        logentry('No drift removed.  Returning raw data.');
    end
    
    return;


function [v,drift_vectors] = linearMean(data, drift_start_time, drift_end_time)

    video_tracking_constants;

    beadlist = unique(data(:,ID))';
    for k = 1:length(beadlist)

        bead = get_bead(data, beadlist(k));

        t = bead(:,TIME);
        t0 = t(1);
        t = t - t0;
            
        idx = find(t >= (drift_start_time - t0) & t <= (drift_end_time - t0));
                
        if ( length(idx) > 2 )                        
            fitx   = polyfit(t(idx), bead(idx,X), 1);
            fity   = polyfit(t(idx), bead(idx,Y), 1);
            fitz   = polyfit(t(idx), bead(idx,Z), 1);
        
            drift_velocities(k,:) = [fitx(1) fity(1) fitz(1)];
            drift_offsets(k,:) = [fitx(2) fity(2) fitz(2)];
        else
            logentry('deleted tracker');
        end
    end
    
    mean_drift_velocity = mean(drift_velocities, 1);
    
    logentry(['Removed linear drift velocity of' ...
               ' x=' num2str(mean_drift_velocity(1)) ...
              ', y=' num2str(mean_drift_velocity(2)) ...
              ', z=' num2str(mean_drift_velocity(3)) '.']);
        
        
    for k = 1:length(beadlist)
        
        bead = get_bead(data, beadlist(k));

        t = bead(:,TIME);
        t0 = t(1);
        t = t - t0;
            
        idx = find(t >= (drift_start_time - t0) & t <= (drift_end_time - t0));

        if ( length(idx) > 2 )
            beadx   = bead(:,X) - polyval([mean_drift_velocity(1) 0], t)+drift_offsets(k,1);
            beady   = bead(:,Y) - polyval([mean_drift_velocity(2) 0], t)+drift_offsets(k,2);
            beadz   = bead(:,Z) - polyval([mean_drift_velocity(3) 0], t)+drift_offsets(k,3);
        
            tmp = bead;
            tmp(:,X) = beadx;
            tmp(:,Y) = beady;
            tmp(:,Z) = beadz;

            if ~exist('newdata')                
                newdata = tmp;
            else
                newdata = [newdata ; tmp];
            end          
        end
    end

    if exist('newdata')
        v = newdata;
        drift_vectors = mean_drift_velocity;
    else
        v = data;
        drift_vectors = [NaN NaN NaN];
        logentry('No drift removed.  Returning raw data.');
    end
    
    return;


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'remove_drift: '];
     
     fprintf('%s%s\n', headertext, txt);
