function [subtraj_matrix, subtraj_dur] = break_into_subtraj(single_curve, frame_rate, num_subtraj)
%BREAK_INTO_SUBTRAJ
%   COMMENTS





video_tracking_constants;                                                   % TIME,ID,FRAME,X,Y... for column headers



% determines the number of extra frames given num_subtraj
extra_frames = mod(size(single_curve, 1), num_subtraj);                    

% takes out extra frames to make curve divisible by num_subtraj
single_curve = single_curve(1:(end-extra_frames), :);                       
    
frame_num_reset = single_curve(:,FRAME) - min(single_curve(:,FRAME));       % creates column matrix to result frame number (I forget why I did this...?)
single_curve(:,FRAME) = frame_num_reset + 1;                                % frame column now starts at 1 and ends with last frame
    
ID_reset = single_curve(:,ID) - single_curve(:,ID);                         % creates column matrix of zeros
single_curve(:,ID) = ID_reset;                                              % resets bead ID to zero
num_frames_per_subtraj = (max(single_curve(:,FRAME))) / num_subtraj;        % determines number of frames per subtrajectory
    
for i = 1:num_subtraj
   
    row_index = single_curve(:,FRAME)>((i-1)*num_frames_per_subtraj) ...
              & single_curve(:,FRAME)<=(i*num_frames_per_subtraj);          % determines the frames which go to each subtrajectory
    
    single_curve(row_index,ID) = i;                                         % assigns each subtrajectory a new bead ID

end

subtraj_dur = num_frames_per_subtraj / frame_rate;

subtraj_matrix = single_curve;


end

