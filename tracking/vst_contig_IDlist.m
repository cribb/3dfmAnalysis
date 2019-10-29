function clist = vst_contig_IDlist(vid_table)

    video_tracking_constants;
    
    full_frame_list(:,1) = unique(vid_table(:,FRAME));
    id_list(:,1) = unique(vid_table(:,ID));
    
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
    
    clist = contig_list;
    