function v = get_beadmax(data)
% GET_BEADMAX Returns the maximum tracker ID in a video_tracking structure.
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
%  
% Extracts the maximum tracker ID in a video tracking dataset.
%  
%  [v] = get_beadmax(data);  
%   
%  where "data" is the output matrix from load_video_tracking
%   
%  06/27/05 - created; jcribb.
%

video_tracking_constants;

% determine whether the input data is in the table or structure of vectors
% format...
if isfield(data, 'id')
    v = max(data.id);
else
    v = max(data(:, ID));
end

