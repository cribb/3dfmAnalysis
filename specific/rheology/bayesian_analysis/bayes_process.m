function dataout = bayes_process(num_subtraj, frame_rate, calibum, metadata, k_norm)
%
%
% Created:       02/06/14, Luke Osborne
% Last modified: 03/11/14, Luke Osborne 
%
%
% inputs:   num_subtraj         number of subtrajectories to use in analysis
%           frame_rate          frame rate of the video
%           calibum             length scale caibration factor for video
%           bead_radius         radius of the bead in [m]
%
% outputs:  dataout structure with:     bayes_output
%                                       bayes_model_output
%


% Set up filter settings for trajectory data
filt.min_frames = 1600; % DEFAULT
     % filt.min_frames = 500; % Panoptes rebuild analysis
     % filt.min_frames = 667; % Panoptes noise analysis (20s video)
filt.xyzunits   = 'm';
filt.calib_um   = calibum;

metadata.filt = filt;

metadata.models = {'N', 'D', 'DA', 'DR', 'V'};
%msd_params = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1. run engine of bayesian analysis wrapper
%%% 2. create structure (MSD,tau,n,ns,window) for each model
%%% 3. create plots and publish results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bayes_output = bayes_analyze(num_subtraj, frame_rate, calibum, metadata);

bayes_model_output = bayes_model_analysis(bayes_output);

bayes_pub = bayes_publish(bayes_output, bayes_model_output, k_norm);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create bayesian analysis directory and move all files into it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bayes_analysis_dir = './bayes_analysis';
mkdir(bayes_analysis_dir)
fclose('all')
copyfile('*.evt.mat', bayes_analysis_dir);
movefile('*.html', bayes_analysis_dir);
movefile('*.fig', bayes_analysis_dir);
movefile('*.png', bayes_analysis_dir);
movefile('*.svg', bayes_analysis_dir);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Defining the output structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
dataout.bayes_output       = bayes_output;
dataout.bayes_model_output = bayes_model_output;
dataout.computation_struct = bayes_pub;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saving the output structure to file and movingto into analysis dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save('bayes_output.mat', 'bayes_output');
save('bayes_model_output.mat', 'bayes_model_output');
save('computation_struct.mat', 'bayes_pub');

movefile('bayes_output.mat', bayes_analysis_dir);
movefile('bayes_model_output.mat', bayes_analysis_dir);
movefile('computation_struct.mat', bayes_analysis_dir);

return;


