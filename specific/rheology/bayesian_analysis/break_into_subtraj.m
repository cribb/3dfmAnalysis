function [subtraj_matrix, subtraj_dur] = break_into_subtraj(single_curve, frame_rate, num_subtraj)
%BREAK_INTO_SUBTRAJ
%   COMMENTS

% TIME,ID,FRAME,X,Y... for column headers
video_tracking_constants;                                                   

% determines the number of extra frames given num_subtraj
extra_frames = mod(size(single_curve, 1), num_subtraj);                    

% takes out extra frames to make curve divisible by num_subtraj
single_curve = single_curve(1:(end-extra_frames), :);                       
    
% frame column now starts at 1 and ends with last frame
single_curve(:,FRAME) = single_curve(:,FRAME) - min(single_curve(:,FRAME)) + 1;                                
    
% resets bead ID to zero
single_curve(:,ID) = 0;                                              

% determines number of frames per subtrajectory
num_frames_per_subtraj = (max(single_curve(:,FRAME))) / num_subtraj;        
    
for i = 1:num_subtraj
   
    % determines the frames which go to each subtrajectory
    row_index = single_curve(:,FRAME)>((i-1)*num_frames_per_subtraj) ...
              & single_curve(:,FRAME)<=(i*num_frames_per_subtraj);          
    
    % assigns each subtrajectory a new bead ID
    single_curve(row_index,ID) = i;                                         

end

subtraj_dur = num_frames_per_subtraj / frame_rate;

subtraj_matrix = single_curve;


end

