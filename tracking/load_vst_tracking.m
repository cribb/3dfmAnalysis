function v = load_vst_tracking(VidTable)
% LOAD_VST_TRACKING Loads csv-format datasets from Video Spot Tracker v8+
%
% CISMM function
% Tracking
%  
% Loads and aggregates tracking from a dataset defined by the input, VidTable
% 
%  pan = panoptes_combine_data(metadata, filtparam_name) 
%   
% 'VidTable' is a specifically formatted Matlab table. Use 'mk_video_table'
% function for help in generating this.
%

filelist = VidTable.File;


% pre-initialize the output so Matlab doesn't have a cow.
v = table;

% Matlab disapproves some of the column-headings in Spot Tracker's 
% csv-outfile. This turns off the warning.

warning('off', 'MATLAB:table:ModifiedVarnames');
fid = unique(VidTable.Fid);
for f = 1:length(fid)    
    
    % Handle the incoming data for whatever type it is...
    % First, check if it's a csv file
    myfile = fullfile(VidTable.Path{f}, VidTable.File{f});
    
    dd = readtable(myfile);

    Fid = table(repmat(fid(f), size(dd,1), 1));
    Fid.Properties.VariableNames{'Var1'} = 'Fid';

    % rename the headers to something more easily coded/read
    dd.Properties.VariableNames{'FrameNumber'} = 'Frame';
    dd.Properties.VariableNames{'SpotID'}      = 'ID';

    logentry(['Loaded *' filelist{f} '* which contains ' num2str(length(unique((dd.ID)))) ' initial trackers.']);
    
    % Z data and remaining values are nonexistant (These can be added back if needed in a
    % later version
    dd.Z = [];
    dd.Orientation_ifMeaningful_ = [];
    dd.Length_ifMeaningful_ = [];
    dd.FitBackground_forFIONA_ = [];
    dd.GaussianSummedValue_forFIONA_ = [];
    dd.MeanBackground_FIONA_ = [];
    dd.SummedValue_forFIONA_ = [];

    % tack on the Fid value
    dd = [Fid dd];

    v = [v;dd];
end
warning('on', 'MATLAB:table:ModifiedVarnames');

% There should be a better way than this. I don't like how it's unhinged
% from the columnTitles.
v.Properties.VariableUnits = {'', '', '', 'pixels', 'pixels', 'pixels', 'Intensity-16-bit', 'pixels^2', '', 'pixels^2'};
    
        

    

    
