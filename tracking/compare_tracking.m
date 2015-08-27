function q = compare_tracking(fileA, fileB, id_error_thresh, xy_error_thresh, filteryn)
% COMPARE_TRACKING Compares Video Spot Tracker datasets and reports differences.
%
% CISMM function  
% Tracking 
% 
% This function reads in two tracking datasets from Video Spot Tracker, and
% them compares them for differences in tracking data and reports the data
% in an output table that includes ID mismatches and absence/presence in
% domain A or B, where fileA is considered the base reference (ground
% truth);
% 
% [q] = compare_tracking(fileA, fileB, id_error_thresh, xy_error_thresh)
%  
% where "q" is the tabulated results of the comparison
%       "fileA" is the "ground truth" tracking file
%       "fileB" is the tracking file to be compared to fileA
%       "id_error_thresh" is the error threshold for identifying a tracker
%         in A and a tracker in B as 'mismatched', i.e. where the distance
%         between their starting positions is greater than the threshold. The
%         threshold is defined in pixels with a default of 1, meaning the
%         starting positions for a trajectory must be more than 1 pixel apart
%         from A to B in order for it to be labeled as "mismatched"
%       "xy_error_thresh" is the error threshold for all xy locations
%         between matched trajectories in A and B. Here the default is 0.1,
%         meaning that is the standard deviation of the differences between
%         two matching trajectories exceeds 0.1 pixels, then the trajectory
%         (i.e. its tracking) in B fails to sufficiently match the
%         corresponding/matched tracker ID in A.
%       "filteryn"
%       
%

if nargin < 5 || isempty(filteryn)
    filteryn = 'n';
end

if nargin < 4 || isempty(xy_error_thresh)
    xy_error_thresh = 0.1; % on average s
end

if nargin < 3 || isempty(id_error_thresh)
    id_error_thresh = 1; % pixel distance between Atracker and the closest Btracker
end

if nargin < 2
    error('Need two tracking files for comparison');
end


video_tracking_constants;

% MUST ASSUME THAT FILE *A* IS THE BASE REFERENCE (GROUND TRUTH)
A = load_video_tracking(fileA, [], 'pixels', 1, 'absolute', 'no', 'table');
B = load_video_tracking(fileB, [], 'pixels', 1, 'absolute', 'no', 'table');

% check file A for "no data" (just NaNs) and return if true
if isempty(A)    
    q.pairedAB_IDs      = NaN;
    q.match_err         = NaN;
    q.nPointsAB         = NaN;
    q.diff_nPointsAB    = NaN;
    q.meanABdiffXY      = NaN;
    q.maxABdiffXY       = NaN;
    q.stdABdiffXY       = NaN;
    q.filteredB         = NaN(size(A));
    return;
end

% Pull the first tracker locations for each available ID.
Afirst = pull_first_points(A);
Bfirst = pull_first_points(B);

% Generate list of IDs that exist in (A), in (B), and in (A AND B)
[pairedAB_IDs match_err] = gen_AB_tracker_list(Afirst, Bfirst, id_error_thresh);

% Now we drill into the specific trajectories and compare their properties
stats = gen_traj_stats(pairedAB_IDs, A, B);

q.pairedAB_IDs      = pairedAB_IDs;
q.match_err         = match_err;
q.nPointsAB         = stats.nPointsAB;
q.diff_nPointsAB    = stats.diff_nPointsAB;
q.meanABdiffXY      = stats.meanABdiffXY;
q.maxABdiffXY       = stats.maxABdiffXY;
q.stdABdiffXY       = stats.stdABdiffXY;

% Filter the data if (1) we are instrusted to do so and (2) if there's any
% reason to, i.e. if there are any NaNs in the paired IDs variable.
if strcmpi(filteryn, 'y')
        q.filteredB = filter_mismatches(pairedAB_IDs, A, B);
end

return;

function v = filter_mismatches(IDlist, A, B)
% filter out erroneus trackers that appear in B that were not in A.

    video_tracking_constants;
    
    % the "good" IDs in B correspond to IDs in A that are NOT NaN. Because
    % A is assumed to be the "good" tracking file, there is no need to
    % filter out data in A that has no corresponding good data in B.
    goodIDsA = IDlist( ~isnan(IDlist(:,1)) );
    goodIDsB = IDlist( ~isnan(goodIDsA),2);
    
    v = [];
    
    for k = 1:length(goodIDsB)
        goodB = B( B(:,ID) == goodIDsB(k), :);
        
        v = [v; goodB];
    end
    
return;

function v = pull_first_points(table)

    video_tracking_constants;

    list = unique(table(:,ID));

    if isempty(table)
        v = NULLTRACK;
        return;
    end
    
    for k = 1:length(list)
        idx = find(table(:,ID) == list(k));
        if ~isnan(list)
            v(k,:) = table(idx(1),:);
        else
            v(k,:) = NULLTRACK;
        end
    end
    
    return;


    
function [list, match_err] = gen_AB_tracker_list(A, B, id_error_thresh)

    % pixel distance between Atracker and the closest Btracker
    if nargin < 3 || isempty(id_error_thresh)
            id_error_thresh = 1; 
    end

    video_tracking_constants;

     id_error_thresh = 1; 
    % initialize counter for output table
    count = 1;
    
    % Handle the ground truth "A" list first, checking if B has any matches
    % to "A's" contents...
    while ~isempty(A) 
        
        % pull out the current A bead's X and Y locations and copy it to the
        % number of first B locations that exist.
        ax = repmat(A(1,X), size(B,1), 1); 
        ay = repmat(A(1,Y), size(B,1), 1);

        % all of the B X and Y locations
        bx = B(:,X);
        by = B(:,Y);

        % compute the distance between this A bead locations and all of the B
        % bead locations
        dist = sqrt( (ax - bx).^2 + (ay - by).^2 );

        % The bead in B that matches this bead in A will have the smallest
        % distance value and its index will provide the location the list of first locations.
        [mindist closest_Blist_IDX] = min(dist);

        % If the minimum distance is less than the defined error threshold,
        % then this A tracker has a match in B, so define it as a match and
        % eliminate the tracker in B so that it doesn't errorneously match
        % something else again later.
        if mindist < id_error_thresh

            % To get the B bead's ID, use the index value with the list of firsts
            list(count,:) = [A(1,ID) B(closest_Blist_IDX,ID)];

            % this bead is matched, so remove it from lists A and B
            A(1,:) = [];
            B(closest_Blist_IDX,:) = [];

            match_err(count,:) = mindist; % distance between the matched IDs in pixels                
        end

        % If the minimum distance is greater than (or equal to) the defined
        % error threshold, then this A tracker does NOT have a match in B,
        % and needs to be identified as such. BECAUSE we make the
        % assumption that the A list is the 'ground truth', we remove
        % the tracker from the A list, and place its ID number only in to
        % an "A_list_only" variable so we can keep track of which trackers
        % didn't get picked up by the conditions used to create trajectory
        % list B.
        if isempty(mindist) || isnan(mindist) || mindist >= id_error_thresh
            list(count,:) = [A(1,ID) NaN];
            if isempty(mindist) 
                mindist = NaN;
            end
            
            match_err(count,:) = mindist;
            A(1,:) = [];
        end

        count = count + 1;
            
    end
    
    % Whatever trackerIDs are left exist only in B
    while ~isempty(B)
      list(count,:) = [NaN B(1,ID)];
      B(1,:) = [];
      match_err(count,:) = NaN;
      count = count + 1;
    end
    
    
    return;

    
    
function q = gen_traj_stats(pairedAB_IDs, A, B)
    video_tracking_constants;

    for k = 1:size(pairedAB_IDs,1)
        A_ID = pairedAB_IDs(k,1);
        B_ID = pairedAB_IDs(k,2);

        if ~isnan(A_ID)
            Abead = get_bead(A, A_ID);
        else
            Abead = NaN(1,size(A,2));
        end

        if ~isnan(B_ID)
            Bbead = get_bead(B, B_ID);
        else
            Bbead = NaN(1,size(B,2));
        end

        AN = size(Abead,1);
        BN = size(Bbead,1);

        nPointsAB(k,:) = [AN BN];
        diff_nPointsAB(k,:) = AN-BN;

        % trim longer trajectory
        if AN > BN
            Abead = Abead(1:BN,:);
            AN = BN;
        elseif AN < BN
            Bbead = Bbead(1:AN,:);
            BN = AN;
        end
        
        % Compute the differences between the (A AND B)'s X and (A AND B)'s Y
        % values. This should be zero is there is no difference in the tracker
        % locations in the A video and the B video
        ABdiffXY = [ (Abead(:,X) - Bbead(:,X)) (Abead(:,Y) - Bbead(:,Y)) ];

        % Calculate statistical values for the output....
        meanABdiffXY(k,:) = mean(ABdiffXY,1);
         maxABdiffXY(k,:) = max(ABdiffXY,[],1);
         stdABdiffXY(k,:) = std(ABdiffXY,[],1);    
    end
    
    q.nPointsAB         = nPointsAB;
    q.diff_nPointsAB    = diff_nPointsAB;
    q.meanABdiffXY      = meanABdiffXY;
    q.maxABdiffXY       = maxABdiffXY;
    q.stdABdiffXY       = stdABdiffXY;
    
    return;