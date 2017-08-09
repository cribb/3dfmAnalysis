function outs = frmsd(vstdata, window)
% frMSD computes the mean-square displacements (via the Stokes-Einstein
% relation) for paired-sets of trajectory points
%
% 3DFM function
% specific\rheology\msd

    video_tracking_constants;   
    
    v = vstdata;
    
    firstframe = min(v(:,FRAME));
    lastframe  = max(v(:,FRAME));    
    id_list    = unique(v(:,ID));

    df = [1 3];  % df corresponds to 'taus' --> winsizes = msd_gen_taus(lastframe, window, 1);

    % for different window sizes
    for fidx = 1:length(df)
        
    % Identify the first and last "frames of existence" for every tracker and
    % place the list as 'frameone' and 'frameend' variables
    for k = 1:length(id_list); 
        q = v(  v(:,ID) == id_list(k) , FRAME); 
        frameone(1,k) = q(1,1); 
        frameend(1,k) = q(end,1); 
        
        time_pts = v( v(:,ID) == id_list(k), TIME);
        frame_rates(1,k) = mean(1./diff(time_pts));
    end;
    
    % use frameone and frameend to establish the available windowsizes we
    % need in order to successfuly carry out the user's request for
    % 'window' taus.
%     winsizes = msd_gen_taus(frameend-frameone, window, 1);

    
    % 'C=setdiff(A,B)' returns for C the values in A that are not in B.  Here we use
    % setdiff to identify the frames where no "popping in and out of existence"
    % occurs.
    C = setdiff([firstframe:df(fidx):lastframe]', [frameone frameend]');

    % Next we want to identify regions of stable tracking in the set of frames,
    % i.e. those regions in the dataset where we can find chunks of contiguous 
    % frames
    dC = diff(C);
    contig_list = C(dC > 0);

    end
    
    % Algorithm:  Iterate through frames where stable bead IDs and 1-frame 
    % jumps are guaranteed.  At each frame, compute the center of mass for x 
    % and y at each frame.  From the two positions, compute the x and y 
    % velocities as a forward difference.  NOTE: Must retain the frame 
    % identification for each estimate in order to re-attach the computation 
    % to the global "clock".
    count = 1;
    for k = 1:length(contig_list)
        thisFRAME = contig_list(k);

        idx1 = find(v(:,FRAME) == thisFRAME);
        idx2 = find(v(:,FRAME) == thisFRAME+1);
        
        table1 = v(idx1,:);
        table2 = v(idx2,:);
        myN = size(table1,1);
        
        d = (table1(:,X:Y)-table2(:,X:Y));
        sd = d.^2;
        logsd = log10(sd);        
        mean_logMSD = mean(logsd,1);
               
        outv(k,:) = [thisFRAME mean_logMSD myN];
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

     outs = 0;
     
    return;