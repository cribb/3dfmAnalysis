function [subtraj_paths, idlist] = sub_tracks(filename, subtraj, idlist)

% SUB_TRACKS divides a single trajectory curve into n subtrajectories
%
% MSD Bayesian Analysis Function
% yingzhou\desktop\MSD Bayes\Panoptes Functions
% last modified 9/5/13 (yingzhou)
%
% This function divides a single particle diffusing trajectory data into a specified
% number of subtrajectories and saves it in evt file format that can be
% tracked in evt_GUI and using video_msd.m 
%
% where 
    % "filename" is the LAST PART of the filename for the file that contains the trajectory, e.g. 'T24.vrpn.evt.mat'
    % "subtraj" the number of desired subtrajectories (this should be an
    % integer factor of the total frame rate). default is set to 10
    % subtrajectories.
    % "ID_start" is the ID number of the first curve
    % "ID_end" is the ID number of the last curve

if (nargin < 2) || isempty(subtraj)  
    subtraj = 10; 
end;

video_tracking_constants;

for i=1:length(idlist)
    
    d = load_video_tracking(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename)], 55, 'm', 0.152, 'absolute', 'no', 'table');
% q(i) = size(d,1);
    if size(d, 1)>0
        
        xtra_frames=mod(size(d, 1), subtraj);
        d = d(1:(end-xtra_frames), :);                 %takes out the extra frames to make the new trajectory matrix divisible by "subtraj"
        
        init_frame = d(1,FRAME)-1;
        d(:, FRAME) = d(:,FRAME)-init_frame;
        max_frame = max(d(:,FRAME));                   % maximum frame number
        subtraj_fend = max_frame / subtraj;            % maximum subtrajectory time

        idx = find(d(:, FRAME)<=subtraj_fend); 
        this_tracker  = d(idx,:);                      %puts the first data set into a new matrix
        mytime = this_tracker(:,TIME);                 %gives the times in s of the first data set to be used to replace every other subtrajectory times
        myframe = this_tracker(:, FRAME);              %gives the frame numbers of the first data set to be used to replace every other subtrajectory frame numbers

        subtraj_paths= [];

        for n=1:subtraj;

        %want n idx trajectories in the same column
            idx1 = find(d(:,FRAME)>(n-1)*subtraj_fend & d(:, FRAME) <= n*subtraj_fend);   
 
            this_subtraj = d(idx1,:);                                                      %puts the nth data set into this_subtraj matrix
            this_subtraj(:, ID)=n;                                                         %changes the nth subtrajectory ID into n
            this_subtraj(:, TIME) = mytime;                                                %change the TIME column of the nth subtrajectory into mytime
            this_subtraj(:, FRAME)= myframe;                                               %changes the FRAME column of the nth subtrajectory into myframe

            subtraj_paths=[subtraj_paths; this_subtraj];                                   %create a matrix containing the new subtrajectories

            save_evtfile(['single_curve_ID'  num2str(idlist(i), '%03u') '_' num2str(filename) '.' num2str(subtraj) 'subtraj.vrpn.evt.mat'], subtraj_paths, 'm', 0.152);
        end 
    else
        disp('size 0');
    end
        
end

return;