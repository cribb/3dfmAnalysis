function [bayes_output] = bayes_analyze(filelist, metadata)
%function [bayes_output] = bayes_analyze(num_subtraj, frame_rate, calibum, metadata)
% BAYES_ANALYZE
%
% Created:       3/3/14, Luke Osborne
% Last modified: 2/3/16, Jeremy Cribb
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

video_tracking_constants;

metadata = bayes_check_metadata(metadata);

num_subtraj = metadata.num_subtraj;
frame_rate  = metadata.fps;
calibum     = metadata.calibum;
filt        = metadata.filt;
agg_num_taus= metadata.numtaus;

msd_params.models = metadata.models;

% creates structure array of aggregated data files.
% filelist = dir('*.evt.mat');
filelist = dir(filelist);
Nfiles = length(filelist);

bayes_output = bayes_initialize_output_structure(Nfiles);

% Run through Bayesian analysis for each file in the filelist.
for k = 1:Nfiles
    
    % determine the name of the current file
    filename = filelist(k).name;
    name = strrep(filename, 'aggregated_data_', '');
    name = strrep(name, '.vrpn.evt.mat', '');
    prd  = strfind(name,'.');
    name = name(prd+1:length(name));
    
    my_bead_radius = metadata.bead_radius(k);   
    
    bayes_output(k,1).name = name;
    bayes_output(k,1).filename = filename;    
    
    % loads aggregate data set as trajectories
    data_in = load_video_tracking(filename, frame_rate, 'm', calibum, ...
                           'absolute', 'no', 'matrix');                      
    
    % Filter trajectories for minimum number of frames
    [data, filtout] = filter_video_tracking(data_in, filt);                   

    logentry(['FILTERED data for a minimum of ' num2str(filt.min_frames) ' frames.']);
 
    % Keep initialized form of bayes structure for the 'k'th file, which is 
    % empty, and immediately continue to next file. 
    if isempty(data_in) && isnan(data_in(1))
       continue; 
    end
        
    agg_msdcalc = video_msd(data, agg_num_taus, frame_rate, calibum, 'n');        

    % To separate aggregate tracker data set into individual trackers
    % we need to first create the list of unique trackerIDs
    tracker_IDlist = unique(data(:,ID));
        
    for i = 1:length(tracker_IDlist)

        single_curve = get_bead(data, tracker_IDlist(i));

       % logentry(['Separated tracker ' num2str(i) ' from the ' filename ' data set. Breaking up curve into ' num2str(num_subtraj) ' subtrajectories.']);

        [subtraj_matrix, subtraj_duration] = break_into_subtraj(single_curve, ...
                                             frame_rate, num_subtraj);           % break into subtrajectories

        % Largest frame number in the trajectory dataset, presumed to
        % be equivalent to the experiment duration (though that could
        % just be checked in the metadata structure
        frame_max = max(subtraj_matrix(:,FRAME));
        subtraj_framemax = floor(frame_max / num_subtraj); 

        % number of time scales for which to calculate MSD. This is an aim.
        num_taus = 35;  

%             if subtraj_framemax <= num_taus
%                 qnum_taus = subtraj_framemax - 1;
%             end
% 
%             window = msd_gen_taus(subtraj_framemax, qnum_taus, 0.5);


        % This evenly spaces the tau given the length and frame rate of dataset
        % num_taus = unique(floor(logspace(0,round(log10(subtraj_duration*frame_rate)), num_taus))); 

        % 4/7/14 I removed the "round". I checked subtrajectory length and
        % the rounding was chopping a 1 sec subtraj to ~0.3 sec
        % I think the rounding is not necessary, and it impact did
        % not affect windows for curves on timescales on 1 min, but
        % But for shorter trajectories like
        % subtrajectories, this rounding affects things significantly.
        num_taus = unique(floor(logspace(0,log10(subtraj_duration*frame_rate), num_taus)));  
        num_taus = num_taus(:);                                                      


        % Prepare the window vector for msd calculations.
        % turns the vector of frames into a vector of times                       
        taus = num_taus * (1/frame_rate);                                       

        % finds the taus that are smaller than the duration of the subtrajectory
        index = taus(:) < subtraj_duration;                                             

        % creates a window vector
        win = taus(index,:);     

        % creates a window vector in terms of frames, for input into video_msd
        window = taus(index,:) * frame_rate;                                    

% %             % calculates the MSD of the single curve
% %             % and stores in struc with: tau, MSD, n, n, window 
% %             sc_msdcalc = video_msd(single_curve, window, frame_rate, calibum, 'n');   

        % calculates the MSD of the matrix of subtrajectories
        % and stores in struct with: tau, MSD, n, ns, window
        msdcalc = video_msd(subtraj_matrix, window, frame_rate, calibum, 'n');    

        % MIT code by Monnier et al that computes Bayesian statistics 
        % on MSDs of matrix of subtrajectories. MSDs must be in
        % microns^2 while our default is m^2, hence the 1e12 conversion.
        bayes_results = msd_curves_bayes(msdcalc.tau(:,1), ...
                                         msdcalc.msd*1e12, msd_params);     

        % assigns each single curve a model and associated probability
        [model, prob] = bayes_assign_model(bayes_results);      

        agg_msdcalc.pass(i) = single_curve(1, PASS); 
        agg_msdcalc.well(i) = single_curve(1, WELL);
        agg_msdcalc.area(i) = single_curve(1, AREA);
        agg_msdcalc.sens(i) = single_curve(1, SENS);

        original_curve_msd.trackerID  = agg_msdcalc.trackerID(:,i);
        original_curve_msd.tau        = agg_msdcalc.tau(:,i);
        original_curve_msd.msd        = agg_msdcalc.msd(:,i);
        original_curve_msd.Nestimates = agg_msdcalc.Nestimates(:,i);
        original_curve_msd.window     = agg_msdcalc.window;

        bayes_output(k,1).name                = name;
        bayes_output(k,1).filename            = filename;
        bayes_output(k,1).min_frames          = filt.min_frames;
        bayes_output(k,1).bead_radius         = my_bead_radius;
        bayes_output(k,1).num_subtraj         = num_subtraj;
        bayes_output(k,1).pass(i,1)           = agg_msdcalc.pass(i);
        bayes_output(k,1).well(i,1)           = agg_msdcalc.well(i);
        bayes_output(k,1).area(i,1)           = agg_msdcalc.area(i);
        bayes_output(k,1).sens(i,1)           = agg_msdcalc.sens(i);   
        bayes_output(k,1).trackerID(i,1)      = tracker_IDlist(i);
        bayes_output(k,1).model{i,1}          = model;
        bayes_output(k,1).prob(i,1)           = prob;
        bayes_output(k,1).results(i,1)        = bayes_results;
        bayes_output(k,1).original_curve_msd(i,:)  = original_curve_msd;
        bayes_output(k,1).agg_data            = agg_msdcalc; % this is the output of video_msd

    end   % loop over trackers in aggregated data set
       
end % aggregated file loop

return % bayes_analyze function

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'bayes_analyze: '];
     
     fprintf('%s%s\n', headertext, txt);
return;