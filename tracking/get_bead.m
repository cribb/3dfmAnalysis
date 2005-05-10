function v = get_bead(data, IDNum)
% 3DFM function  
% Tracking 
% last modified 05/09/05
%  
% Extracts a bead's video tracking data from load_video_tracking.
%  
%  [v] = get_bead(data, IDNum);  
%   
%  where "data" is the output matrix from load_video_tracking
%        "IDNum" is the bead's ID Number 
%   
%  05/09/05 - created; jcribb.
%

    this_bead = find(data(:,2) == IDNum);
    
    v = data(this_bead, :);

	return