function [outs_bayes] = Bayesian_analysis(filename, expttype, subtracks, models)

% Bayesian Analysis Function
% yingzhou/desktop/MSD Bayes/Panoptes Functions
% last modified 08/20/13 (yingzhou)
%
%
%BAYESIAN_ANALYSIS will categorize the individual curves within a set of
%aggregate trajectory data into their different model behavior types. The
%output is a struct of the results given by Monnier et al.'s (2012) code with
%a matrix for the idlist, and matrices of the probability of each model
%type and the values for each variable and standard error of each variable
%value.
%  
%  where 
    %'filename' is the filename for the aggregate data set
    %'expt_type' is the type of the experiment you are analyzing
    %'sub_tracks' is the number of subtrajectories you want to split each track into
    %'models' is the set of model types you want the Bayes code to take into account in its hypothesis testing


if nargin<4||isempty(models) 
   msd_params.models = {'N', 'D', 'V', 'DV', 'DR', 'DA', 'DRV', 'DAV'};   
else
   msd_params.models = models; 
end

model_constants; 

video_tracking_constants;

%this will extract the individual curves from the aggregate data file
% for i=1:length(idlist)
[idlist] = extract_indiv_curves (filename, expttype);


%this will separate the individual bead trajectories into a specified
%number of subtrajectories
filename2 = [num2str(expttype) '.vrpn.evt.mat'];
[subtraj_paths, idlist] = sub_tracks(filename2, subtracks, idlist);

%this function runs the Bayesian analysis and creates a new matrix
%structure for the model type, parameters, and parameter standard errors.
%The structure is indexed by ID number and model type.
filename3 = [num2str(expttype) '.vrpn.'  num2str(subtracks) 'subtraj.vrpn.evt.mat']
outs_bayes = Bayes_out_struct(filename3, idlist, msd_params.models)

%this saves the output structure of the Bayesian Analysis in a .mat file 
save (['Bayes_results_' num2str(expttype) '.mat'], 'outs_bayes')

return