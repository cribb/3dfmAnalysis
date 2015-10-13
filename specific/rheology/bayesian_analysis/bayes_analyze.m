function [bayes_output] = bayes_analyze(num_subtraj, frame_rate, calibum, metadata)
% BAYES_ANALYZE
%
% Created:       3/3/14, Luke Osborne
% Last modified: 3/7/14, Luke Osborne 
%
% inputs:   filename         this is a video, which may have multiple trackers
%           num_subtraj      number of subtrajectories to use in analysis
%
%           bead_radius is in [m]
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

% creates structure array of aggregated data files.
list = dir('*.evt.mat');


% run through Bayesian analysis for each file in the list. bayes_output is
% the structure array that contains the bayesian analysis of each file.

bayes_output = struct;


for k = 1:length(list)
    
    data_in = load_video_tracking(list(k).name, frame_rate, 'm', calibum, ...
                           'absolute', 'no', 'table');                      % loads aggregate data set
    
    bead_radius = metadata.bead_radius(k);
                       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  
    % Filter data for minimum number of frames
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    filt.min_frames = 1600; % DEFAULT
%     filt.min_frames = 500; % Panoptes rebuild analysis
%     filt.min_frames = 667; % Panoptes noise analysis (20s video)
    filt.xyzunits   = 'm';
    filt.calib_um   = calibum;

    [data, filtout] = filter_video_tracking(data_in, filt);                   

    fprintf('\n FILTERED data for a minimum of %-1.0f frames.', filt.min_frames)

    % determine the name of the current file
    filename = list(k).name;
    name = strrep(filename, 'aggregated_data_', '');
    name = strrep(name, '.vrpn.evt.mat', '');
    prd  = strfind(name,'.');
    name = name(prd+1:length(name));

    % create the list structure
    b_out = struct;
   
    
    if ~isempty(data_in) && ~isnan(data_in(1))
        
        agg_msdcalc = video_msd(data, 35, frame_rate, calibum, 'n');
        
%         % attach the pass and well ids to the msd data
%         for wp = 1:length(agg_msdcalc.trackerID)
%             wpidx = ( data(:,ID) == agg_msdcalc.trackerID(wp) );
%             wpdata = data(wpidx,:);
%             agg_msdcalc.pass(wp) = wpdata(1, PASS); 
%             agg_msdcalc.well(wp) = wpdata(1, WELL);
%             agg_msdcalc.area(wp) = wpdata(1, AREA);
%             agg_msdcalc.sens(wp) = wpdata(1, SENS);
%         end
        
        % plot_msd(data_msdcalc, [], 'ame');    

        % separate aggregate tracker data set into individual trackers
%         tracker_IDlist = unique(data(:,ID));                                        % creates the list of unique tracker IDs
        goodIDs = ~isnan(agg_msdcalc.trackerID);
        
        tracker_IDlist = agg_msdcalc.trackerID(goodIDs);
%              firstposX = agg_msdcalc.firstposX(goodIDs);
%              firstposY = agg_msdcalc.firstposY(goodIDs);
        
        for i = 1:length(tracker_IDlist)

            row_index = ( data(:,ID)==tracker_IDlist(i) );                          % selects all the rows in data matrix that belong 
                                                                                    % to the ith tracker (the ith element of the tracker_IDlist) 
            single_curve = data(row_index,:);                                       % assigns variable to a single tracker

%             fprintf('\n Separated tracker %-1.0f ', i)
%             fprintf('from the %s data set. ', filename)
%             fprintf('Breaking up curve into %-1.0f subtrajectories.', num_subtraj)
            
            agg_msdcalc.pass(i) = single_curve(1, PASS); 
            agg_msdcalc.well(i) = single_curve(1, WELL);
            agg_msdcalc.area(i) = single_curve(1, AREA);
            agg_msdcalc.sens(i) = single_curve(1, SENS);
            
%             % extract pass, well, area, and starting sens info for this ID
%             pass_data = single_curve(1,PASS);
%             well_data = single_curve(1,WELL);
%             area_data = single_curve(1,AREA);
%             sens_data = single_curve(1,SENS);


            [subtraj_matrix, subtraj_dur] = break_into_subtraj(single_curve, ...
                                            frame_rate, num_subtraj);           % break into subtrajectories


            % pulls out duration and frame rate of dataset   
            duration = subtraj_dur;
            % number of time scales for which to calculate MSD. This is an aim.
            num_taus = 35;  
            % This evenly spaces the tau given the length and frame rate of dataset
            % num_taus = unique(floor(logspace(0,round(log10(duration*frame_rate)), num_taus))); 
            num_taus = unique(floor(logspace(0,log10(duration*frame_rate), num_taus)));  % 4/7 I removed the "round". I checked subtrajectory length and the rounding was chopping a 1 sec subtraj to ~0.3 sec
            num_taus = num_taus(:);                                                      % I think the rounding is not necessary, and it's impact did not affect windows for curves on timescales on 1 min, but
                                                                                         % But for shorter trajectories like subtrajectories, this rounding affects things significantly.
            % Prepares the window vector for msd calculations.
            taus = num_taus * (1/frame_rate);                                       % turns the vector of frames into a vector of times                       
            index = taus(:) < duration;                                             % finds the taus that are smaller than the duration of the subtrajectory
            win = taus(index,:);                                                    % creates a window vector
            window = taus(index,:) * frame_rate;                                    % creates a window vector in terms of frames, for input into video_msd



            sc_msdcalc = video_msd(single_curve, window, frame_rate, calibum, 'n');   % calculates the MSD of the single curve
                                                                                      % and stores in struc with: tau, MSD, n, n, window 

            msdcalc = video_msd(subtraj_matrix, window, frame_rate, calibum, 'n');    % calculates the MSD of the matrix of subtrajectories
                                                                                      % and stores in struct with: tau, MSD, n, ns, window


            bayes_results = msd_curves_bayes(msdcalc.tau(:,1), ...
                                             msdcalc.msd*1E12, msd_params);     % computes Bayesian statistics on MSDs of matrix of subtrajectories


            [model, prob] = bayes_assign_model(bayes_results);                  % assigns each single curve a model and associated probability

            b_out.pass(i,:)                = agg_msdcalc.pass(i);
            b_out.well(i,:)                = agg_msdcalc.well(i);
            b_out.area(i,:)                = agg_msdcalc.area(i);
            b_out.sens(i,:)                = agg_msdcalc.sens(i);
%             b_out.n(i,:)                   = agg_msdcalc.n(i);
            b_out.trackerID(i,:)           = tracker_IDlist(i);
%             b_out.firstposX(i,1)           = firstposX(i);
%             b_out.firstposY(i,1)           = firstposY(i);
            b_out.model{i,:}               = model;
            b_out.prob(i,:)                = prob;
            b_out.results(i,:)             = bayes_results;
            b_out.num_subtraj              = num_subtraj;
            b_out.original_curve_data(i,:) = sc_msdcalc;
            b_out.agg_data(:)              = agg_msdcalc;                       % this is the output of video_msd
        
        end   % loop over trackers in aggregated data set
    
        bayes_output(k,1).name                = name;
        bayes_output(k,1).filename            = filename;
        bayes_output(k,1).min_frames          = filt.min_frames;
        bayes_output(k,1).bead_radius         = bead_radius;
        bayes_output(k,1).pass                = b_out.pass;
        bayes_output(k,1).well                = b_out.well;
        bayes_output(k,1).area                = b_out.area;
        bayes_output(k,1).sens                = b_out.sens;    
%         bayes_output(k,1).n                   = b_out.n;
        bayes_output(k,1).trackerID           = b_out.trackerID;
%         bayes_output(k,1).firstposX           = b_out.firstposX;
%         bayes_output(k,1).firstposY           = b_out.firstposY;
        bayes_output(k,1).model               = b_out.model;
        bayes_output(k,1).prob                = b_out.prob;
        bayes_output(k,1).results             = b_out.results;
        bayes_output(k,1).num_subtraj         = b_out.num_subtraj;
        bayes_output(k,1).original_curve_data = b_out.original_curve_data;
        bayes_output(k,1).agg_data            = b_out.agg_data;
        
    else   % if statement to check if data set is empty
    
        bayes_output(k,1).name                = name;
        bayes_output(k,1).filename            = filename;
        bayes_output(k,1).min_frames          = [];
        bayes_output(k,1).bead_radius         = [];
        bayes_output(k,1).pass                = [];
        bayes_output(k,1).well                = [];
        bayes_output(k,1).area                = [];
        bayes_output(k,1).sens                = [];  
%         bayes_output(k,1).Ntrackers          = [];
        bayes_output(k,1).trackerID           = [];
%         bayes_output(k,1).firstposX           = [];
%         bayes_output(k,1).firstposY           = [];
        bayes_output(k,1).model               = [];
        bayes_output(k,1).prob                = [];
        bayes_output(k,1).results             = [];
        bayes_output(k,1).num_subtraj         = [];
        bayes_output(k,1).original_curve_data = [];
        bayes_output(k,1).agg_data            = [];
    end   % if statement to check if data set is empty
       
end % aggregated file loop


return % bayes_analyze function
