function [subtraj_matrix, subtraj_dur] = break_into_subtraj(single_curve, frame_rate, num_subtraj)
%BREAK_INTO_SUBTRAJ
%   COMMENTS

% TIME,ID,FRAME,X,Y... for column headers
video_tracking_constants;                                                   

% determines the number of extra frames given num_subtraj
extra_frames = mod(size(single_curve, 1), num_subtraj);                    

% takes out extra frames to make curve divisible by num_subtraj
cropped_sc = single_curve(1:(end-extra_frames), :);                       
    
% frame column now starts at 1 and ends with last frame
cropped_sc(:,FRAME) = cropped_sc(:,FRAME) - min(cropped_sc(:,FRAME)) + 1;                                
    
% resets bead ID to zero
cropped_sc(:,ID) = 0;                                              

% determines number of frames per subtrajectory
num_frames_per_subtraj = (max(cropped_sc(:,FRAME))) / num_subtraj;        
    
for k = 1:num_subtraj
   
    % determines the frames which go to each subtrajectory
    row_index = cropped_sc(:,FRAME)>((k-1)*num_frames_per_subtraj) ...
              & cropped_sc(:,FRAME)<=(k*num_frames_per_subtraj);          
    
    % assigns each subtrajectory a new bead ID
    cropped_sc(row_index,ID) = k;                                         

end

subtraj_dur = num_frames_per_subtraj / frame_rate;

subtraj_matrix = cropped_sc;


end

