function [common_xy] = traj_common_motion(vid_table, plotyn)
% at each time point, average all beads x, y, and z values to determine
% center of mass vector and subtract that from each bead's position.
% This routine is insensitive to the disapperance of old trackers or the 
% sudden existence of new trackers that would otherwise cause sudden 
% jumps in the center-of-mass, so a polyfit of the center-of-mass should be
% used.

    video_tracking_constants;   
    
    if nargin < 2 || isempty(plotyn)
        plotyn = 'n';
    end

    if nargin < 1 || isempty(vid_table)
        logentry('No input data. Returning an empty vector'); 
        common_xy = zeros(0,3);
        return;
    end
    
    if istable(vid_table)
        tmptable = NaN(size(vid_table,1), size(NULLTRACK,2));
        tmptable(:,ID)    = vid_table.ID;
        tmptable(:,FRAME) = vid_table.Frame;
        tmptable(:,X)     = vid_table.X;
        tmptable(:,Y)     = vid_table.Y;
        
        vid_table = tmptable;       
    end

    firstframe = min(vid_table(:,FRAME));
    lastframe  = max(vid_table(:,FRAME));
    
    id_list = unique(vid_table(:,ID));
    full_frame_list(:,1) = [firstframe:lastframe];
    headerrows = NaN(length([1:firstframe-1]),2);
    
    % Check to see if there's only one id. My intuition is to just delete
    % this file altogether, but we can use a linear-fit as the estimate for
    % the case of a single tracker without imparting too much error or bias
    % into the computation, so that's what I'm doing here. Return after
    % collecting this estimate.
    if length(id_list) == 1
        myx = vid_table(:,X);
        myy = vid_table(:,Y);
        
        [px, Sx] = polyfit(full_frame_list, vid_table(:,X), 1);
        [py, Sy] = polyfit(full_frame_list, vid_table(:,Y), 1);
        
        x = polyval(px, full_frame_list);
        y = polyval(py, full_frame_list);
        
        common_xy = [x(:) y(:)];           
        common_xy = [headerrows; common_xy];
        
        logentry('WARNING: Only one tracker available. Resorting to linear-fit as common mode vector for this specific field-of-view/video.');
        
        return;
    end
    
    % Identify the first and last "frames of existence" for every tracker and
    % place the list as 'frameone' and 'frameend' variables
    frameone = NaN(1,length(id_list));
    frameend = NaN(1,length(id_list));    
    for k = 1:length(id_list)
        q = vid_table(  vid_table(:,ID) == id_list(k) , FRAME); 
        frameone(1,k) = q(1,1);  
        frameend(1,k) = q(end,1); 
    end

    % 'C=setdiff(A,B)' returns for C the values in A that are not in B.  Here we use
    % setdiff to identify the frames where no "popping in and out of existence"
    % occurs.
    C = setdiff(full_frame_list, [frameone frameend]');

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
    outv = NaN(length(contig_list),3);
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

    % Fit the center-of-mass displacement function and subtract out a drift 
    % of arbitrary polynomial order. Any order of polynomial and drift 
    % subtraction is going to generate artifacts in diffusion data, and the 
    % higher the order, the more extreme the artifact. However, it may be 
    % useful to be able to subtract out drifts that change direction during
    % the video collection.
    
    % First, get lists of the frames that DO and DO NOT contribute to the 
    % generation of the center-of-mass definition.
    [missing_frames, idx_for_missing_frames] = setdiff(full_frame_list, outv(:,1));
    weights = ones(size(full_frame_list));
    weights(idx_for_missing_frames) = 0;
    
    % Need to interpolate for the values where the weights are otherwise
    % zero. However, it might be wise to EXTRAPOLATE over the displacement
    % function INSTEAD of the velocity function, so consider breaking this
    % into two interpolation runs.
    interp_velocities = interp1(outv(:,1),outv(:,2:3),full_frame_list);

    noisemag = nanstd(interp_velocities);
    noisemag = repmat(noisemag, size(interp_velocities,1),1);
    noisevals =  noisemag .* randn(size(interp_velocities));

    missingvel = isnan(interp_velocities);

    noise_filler = missingvel .* noisevals;
    
    x_filled = fillnans(interp_velocities(:,1)) + noise_filler(:,1);
    y_filled = fillnans(interp_velocities(:,2)) + noise_filler(:,2);    

%         if sum(missingvel(:)) > 16 && contains(plotyn, 'y')
%             h = figure; 
%             pos = get(h, 'Position');
%             pos(3) = 2 * pos(3);
%             set(h, 'Position', pos);
%             
%             subplot(1,2,1);
%             plot(full_frame_list, x_filled, 'b', ...
%                  full_frame_list, interp_velocities(:,1), 'k', ...
%                  full_frame_list, y_filled, 'r', ...
%                  full_frame_list, interp_velocities(:,2), 'k');
%             legend('x filled-in NaNs', 'x original', 'y filled-in NaNs', 'y original');
%             title('center-of-mass velocity');
%             xlabel('frame');
%             ylabel('velocity [px/frame]');
%             drawnow;
%         end

    interp_velocities = [x_filled y_filled];
    
    xy = cumsum(interp_velocities);        

%         if sum(missingvel(:)) > 16 && contains(plotyn, 'y')
%             figure(h);
%             subplot(1,2,2);
%             plot(full_frame_list, xy(:,1), 'bo', ...
%                  full_frame_list(~missingvel(:,1)), xy(~missingvel(:,1),1), 'ko', ...
%                  full_frame_list, xy(:,2), 'ro', ...
%                  full_frame_list(~missingvel(:,2)), xy(~missingvel(:,2),2), 'ko');
%             legend('x filled-in NaNs', 'x original', 'y filled-in NaNs', 'y original');
%             title('center-of-mass displacement');
%             xlabel('frame');
%             ylabel('displacement [px]');
%             drawnow;
%         end
    
    
%     common_xy.frame = full_frame_list;
%     common_xy.xy = xy;
%     common_xy.weights = weights;
%     common_xy.missing_frames = missing_frames;
    
    mynans = ~weights;
    
    blah(:,1) = [0; mynans(1:end-1)];
    blah(:,2) = [mynans(2:end); 0];
    
    blah = double(blah);
    num_neighbors = sum(blah,2);
    
    NumNeed2NaN = sum(num_neighbors>1);
    
    xy(num_neighbors>1,:) = NaN(NumNeed2NaN,2);
    
%     fxy = [full_frame_list(:) xy];
    


    
    
% %     headerNaNs = NaN(full_frame_list(1)-1,1);   
% %     xy(self_and_neighbors==3,:) = NaN;   
% %     allframes = [headerNaNs ; full_frame_list];
% %     xy = [headerNaNs headerNaNs ; xy];    
    common_xy = [headerrows; xy];
    
    return;
    
