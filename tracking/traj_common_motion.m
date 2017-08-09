function common_xy = traj_common_motion(vid_table)
% at each time point, average all beads x, y, and z values to determine
% center of mass vector and subtract that from each bead's position.
% This routine is insensitive to the disapperance of old trackers or the 
% sudden existence of new trackers that would otherwise cause sudden 
% jumps in the center-of-mass, so a polyfit of the center-of-mass should be
% used.

    video_tracking_constants;   

    %     clip data to desired time points
    %     t_idx = find( vid_table(:,TIME) >= drift_start_time & vid_table(:,TIME) <= drift_end_time);
    %     vid_table = vid_table(t_idx,:);

    firstframe = min(vid_table(:,FRAME));
    lastframe  = max(vid_table(:,FRAME));
    
    id_list = unique(vid_table(:,ID));

    % Identify the first and last "frames of existence" for every tracker and
    % place the list as 'frameone' and 'frameend' variables
    frameone = NaN(1,length(id_list));
    frameend = NaN(1,length(id_list));    
    for k = 1:length(id_list); 
        q = vid_table(  vid_table(:,ID) == id_list(k) , FRAME); 
        frameone(1,k) = q(1,1); 
        frameend(1,k) = q(end,1); 
    end;

    % 'C=setdiff(A,B)' returns for C the values in A that are not in B.  Here we use
    % setdiff to identify the frames where no "popping in and out of existence"
    % occurs.
    C = setdiff([firstframe:lastframe]', [frameone frameend]');

    % I'm going to add 'frame 1' back into C (because it's an edge case, it
    % doesn't count as a "pop-in" for this algorithm)
    C = [1; C];
    
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

        idx1 = find(vid_table(:,FRAME) == thisFRAME);
        idx2 = find(vid_table(:,FRAME) == thisFRAME+1);
        
        table1 = vid_table(idx1,:);
        table2 = vid_table(idx2,:);

        mean1 = mean(table1(:,X:Y),1);
        mean2 = mean(table2(:,X:Y),1);

        comv = mean2 - mean1;

        outv(k,:) = [thisFRAME comv];
    end

    % computing the mean center-of-mass velocity for x and y directions 
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
%     weights = ones(size(full_frame_list));
%     weights(idx_for_missing_frames) = 0;
    interp_velocities = interp1(outv(:,1),outv(:,2:3),full_frame_list, 'pchip', 'extrap');  
    
    common_xy.frame = full_frame_list;
    common_xy.xy = cumsum(interp_velocities);
    
    return;