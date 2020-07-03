function [bayes_output] = bayes_sub_master(filename, num_subtraj, frame_rate)
% BAYES_SUB_MASTER
%
% Created:       1/?/14, Luke Osborne
% Last modified: 3/7/14, Luke Osborne 
%
% inputs:   filename         this is a video, which may have multiple trackers
%           num_subtraj      number of subtrajectories to use in analysis
%
% outputs:  bayes_output     matrix of tracker IDs and model types
% 
%
%
% this function is responsible for 
%   - loading aggregate data set
%   - separating aggregate data into individual curves
%   - for each individual trajectory,
%         1. break into a specified number of subtrajectories
%         2. 


video_tracking_constants;                                                   % TIME,ID,FRAME,X,Y... for column headers


msd_params.models = {'N', 'D', 'DA', 'DR', 'V'};
%msd_params = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};

data = load_video_tracking(filename, frame_rate, 'm', 0.152, ...
                           'absolute', 'no', 'matrix');                      % loads aggregate data set


agg_msdcalc = video_msd(data, 35, frame_rate, 0.152, 'n');

% plot_msd(data_msdcalc, [], 'ame');                       
                       
                       
% create the list structure
bayes_output = struct;
                       
% separate aggregate tracker data set into individual trackers
tracker_IDlist = unique(data(:,ID));                                        % creates the list of unique tracker IDs

for i = 1:length(tracker_IDlist)
    
    row_index = data(:,ID)==tracker_IDlist(i);                              % selects all the rows in data matrix that belong 
                                                                            % to the ith tracker (the ith element of the tracker_IDlist) 
                                 
    single_curve = data(row_index,:);                                       % assigns variable to a single tracker
    
    fprintf('Separated tracker %-1.0f from the aggregated data set', i)
    fprintf('\rBreaking up curve for this tracker into %-1.0f subtrajectories', num_subtraj)
    
    
    [subtraj_matrix, subtraj_dur] = break_into_subtraj(single_curve, ...
                                        frame_rate, num_subtraj);           % break into subtrajectories
    
    
    % pulls out duration and frame rate of dataset   
    duration = subtraj_dur;
    % number of time scales for which to calculate MSD. This is an aim.
    num_taus = 35;  
    % This evenly spaces the tau given the length and frame rate of dataset
    num_taus = unique(floor(logspace(0,round(log10(duration*frame_rate)), num_taus)));
    num_taus = num_taus(:);
    
    % Prepares the win vector for msd calculations.
    taus = num_taus * (1/frame_rate);                                       % turns the vector of frames into a vector of times                       
    index = taus(:) < duration;                                             % finds the taus that are smaller than the duration of the subtrajectory
    win = taus(index,:);                                                    % creates a win vector
    win = taus(index,:) * frame_rate;                                    % creates a win vector in terms of frames, for input into video_msd
    
    
    
    sc_msdcalc = video_msd(single_curve, win, frame_rate, 0.152, 'n');   % calculates the MSD of the single curve
                                                                            % and stores in struc with: tau, MSD, n, n, win 
     
    msdcalc = video_msd(subtraj_matrix, win, frame_rate, 0.152, 'n');    % calculates the MSD of the matrix of subtrajectories
                                                                            % and stores in struct with: tau, MSD, n, ns, win
    
    
    bayes_results = msd_curves_bayes(msdcalc.tau(:,1), ...
                                     msdcalc.msd*1E12, msd_params);         % computes Bayesian statistics on MSDs of matrix of subtrajectories
    
    
    [model, prob] = bayes_assign_model(bayes_results);                      % assigns each single curve a model and assocaited probability
    
    
    bayes_output.trackerID(i,:) = tracker_IDlist(i);
    bayes_output.model{i,:} = model;
    bayes_output.prob(i,:) = prob;
    bayes_output.results(i,:) = bayes_results;
    bayes_output.num_subtraj = num_subtraj;
    bayes_output.original_curve_msd(i,:) = sc_msdcalc;
    bayes_output.agg_data(:) = agg_msdcalc;
        
end





end
