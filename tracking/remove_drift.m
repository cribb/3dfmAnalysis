function [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% REMOVE_DRIFT Subtracts drift from 3DFM video tracking data.
%
% [v,q] = remove_drift(data, drift_start_time, drift_end_time, type)
% 
% v = data minus drift
% q = drift vector
% type = 'linear' or 'center-of-mass'
%

    % handle "global" variables that contain column positions for video
    video_tracking_constants;  

    % handle the argument list
    if nargin < 1 
        data = [];
    end;
    

    if isempty(data) || sum(isnan(data(:))) == length(data(:))
        logentry('No data found. Exiting function.'); 
        v = data;
        q = [];
        return;
    end;

    if nargin < 2 || isempty(drift_start_time); 
        drift_start_time = min(data(:,TIME)); 
%         logentry('No start_time specified.  Choosing first time in dataset.');
    end;
    
    if nargin < 3 || isempty(drift_end_time); 
        drift_end_time = max(data(:,TIME)); 
%         logentry('No end_time specified.  Choosing last time in dataset.');
    end;

    if nargin < 4 || isempty(type); 
        type = 'linear'; 
        logentry('No drift type specified.  Choosing linear method.');
    end;

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

function [cleaned_v,common_v] = common_mode(v, drift_start_time, drive_end_time)
    common_v = traj_common_motion(v);
    cleaned_v  = traj_subtract_common_motion(v, common_v);        
return


function [v,q] = center_of_mass(v, drift_start_time, drift_end_time)
% at each time point, average all beads x, y, and z values to determine
% center of mass vector and subtract that from each bead's position.
% This routine is insensitive to the disapperance of old trackers or the 
% sudden existence of new trackers that would otherwise cause sudden 
% jumps in the center-of-mass, so a polyfit of the center-of-mass should be
% used.

        video_tracking_constants;   

        % clip data to desired time points
    %     t_idx = find( v(:,TIME) >= drift_start_time & v(:,TIME) <= drift_end_time);
    %     v = v(t_idx,:);

        % DRIFT SUBTRACTION
%        
%        figh = figure;
%        plot(v(:,X), v(:,Y), '.');
%        xlabel('x [px]');
%        ylabel('y [px]');
%        axis([0 648 0 484]);
%        
    firstframe = min(v(:,FRAME));
    lastframe  = max(v(:,FRAME));

    id_list = unique(v(:,ID));


    % % % % % % % % % % % % % % figh = figure; 
    % % % % % % % % % % % % % % subplot(2,3,1); 
    % % % % % % % % % % % % % % plot(v(:,X), v(:,Y), '.');
    % % % % % % % % % % % % % % xlabel('x [px]');
    % % % % % % % % % % % % % % ylabel('y [px]');
    % % % % % % % % % % % % % % axis([0 648 0 484]);


    % Identify the first and last "frames of existence" for every tracker and
    % place the list as 'frameone' and 'frameend' variables
    for k = 1:length(id_list); 
        q = v(  v(:,ID) == id_list(k) , FRAME); 
        frameone(1,k) = q(1,1); 
        frameend(1,k) = q(end,1); 
        
        time_pts = v( v(:,ID) == id_list(k), TIME);
        frame_rates(1,k) = mean(1./diff(time_pts));

    end;

    % 'C=setdiff(A,B)' returns for C the values in A that are not in B.  Here we use
    % setdiff to identify the frames where no "popping in and out of existence"
    % occurs.
    C = setdiff([firstframe:lastframe]', [frameone frameend]');


    % Next we want to identify regions of stable tracking in the set of frames,
    % i.e. those regions in the dataset where we can find chunks of contiguous 
    % frames
    dC = diff(C);
    contig_list = C(dC == 1);

    % Algorithm:  Iterate through frames where stable bead IDs and 1-frame 
    % jumps are guaranteed.  At each frame, compute the center of mass for x 
    % and y at each frame.  From the two positions, compute the x and y 
    % velocities as a forward difference.  NOTE: Must retain the frame 
    % identification for each estimate in order to re-attach the computation 
    % to the global clock.
    count = 1;
    for k = 1:length(contig_list)
        thisFRAME = contig_list(k);

        idx1 = find(v(:,FRAME) == thisFRAME);
        idx2 = find(v(:,FRAME) == thisFRAME+1);
        
        table1 = v(idx1,:);
        table2 = v(idx2,:);

        mean1 = mean(table1(:,X:Y),1);
        mean2 = mean(table2(:,X:Y),1);

        comv = mean2 - mean1;

        outv(k,:) = [thisFRAME comv];
    end

    if firstframe < min(contig_list)
        firstframe = min(contig_list);
    end

    if lastframe > max(contig_list)
        lastframe = max(contig_list);
    end

    % computing the mean center-of-meass velocity for x and y directions 
    % will allow us to subtract an *average* displacement per time-stamp.
    % This may be sufficient if the velocity itself is constant.
    mean_com_vel_x = nanmean(outv(:,2));
    mean_com_vel_y = nanmean(outv(:,3));

    % Another way to deal with this is to fit the center-of-mass
    % displacement function and subtract out a drift of arbitrary
    % polynomial order. Any order of polynomial and drift subtraction is
    % going to generate artifacts in diffusion data, and the higher the
    % order, the more extreme the artifact. However, it may be useful to be
    % able to subtract out drifts that change direction during the video
    % collection.
    
    % First, get a list of the frames that DO and DO NOT contribute to the 
    % generation of the center-of-mass definition.
    full_frame_list = (firstframe:lastframe)';
    [missing_frames, idx_for_missing_frames] = setdiff(full_frame_list, outv(:,1));
    weights = ones(size(full_frame_list));
    weights(idx_for_missing_frames) = 0;
    
    
    interp_displacements = cumsum(interp1(outv(:,1),outv(:,2:3),full_frame_list));
    
    order = 2;
    
    px = polyfitw(full_frame_list, interp_displacements(:,1),order,[],weights);
    py = polyfitw(full_frame_list, interp_displacements(:,2),order,[],weights);
    
    driftx = polyval(px,full_frame_list);
    drifty = polyval(py,full_frame_list);
    
% %         figh = figure; 
% %         set(figh, 'Units', 'Normalized');
% %         set(figh, 'Position', [0.1 0.1 0.3 0.6]);
% %         
% %         subplot(2,1,1);
% %         hold on;
% %         plot( full_frame_list, interp_displacements(:,1), '.', 'MarkerEdgeColor', [0 1 0])
% %         plot( full_frame_list, interp_displacements(:,2), '.', 'MarkerEdgeColor', [0 0.5 0])
% %         plot( full_frame_list, [driftx drifty], 'k');
% %         plot( full_frame_list(idx_for_missing_frames), [interp_displacements(idx_for_missing_frames,1) interp_displacements(idx_for_missing_frames,2)], 'or');
% %         legend('x com', 'y com', 'x fit', 'y fit', 'missing');
% %         title(['Center-of-mass for tracking data, order=' num2str(order)]);
% %         grid on;
% %         xlabel('Frame Number');
% %         ylabel('Pixels');
% %         pretty_plot;
% %         
% %         subplot(2,1,2);
% %         plot(interp_displacements-[driftx drifty], '.');
% %         Title('Residuals from center-of-mass fit');
% %         grid on;
% %         xlabel('Frame Number');
% %         ylabel('Pixels');
% %         pretty_plot;
       
    % subtract out drift vector from each tracker
     for k = 1:length(id_list)
        idx = (  v(:,ID) == id_list(k)  );
        tmp = v(idx,:);

        dt = diff(tmp(:,FRAME));  % labeled as 'dt' here for 'velocity' sake, but actually it's 'dFRAME'

        my_frame_list = ( min(tmp(:,FRAME)):max(tmp(:,FRAME)) )';
        my_driftx = polyval(px,my_frame_list);
        my_drifty = polyval(py,my_frame_list);               

        v(idx,X) = tmp(:,X) - my_driftx;
        v(idx,Y) = tmp(:,Y) - my_drifty;    
    
%         figure; 
%         plot(tmp(:,TIME), tmp(:,X:Y), 'or', v(idx,TIME), v(idx,X:Y), '.b');
%         drawnow;
     end
    
     % output average velocities for x and y (not sure what else to do
     % here, maybe polynomial coefficients?)
     q = [mean(diff(driftx)), mean(diff(drifty))];    % px/sec

    return;

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
