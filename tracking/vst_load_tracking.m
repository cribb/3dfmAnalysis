function TrackingTable = vst_load_tracking(VidTable)
% VST_LOAD_TRACKING Loads csv-format datasets from Video Spot Tracker v8+
%
% CISMM function
% Tracking
%  
% Loads and aggregates tracking from a dataset defined by the input, VidTable
% 
%  TrackingTable = vst_load_tracking(VidTable) 
%   
% 'VidTable' is a specifically formatted Matlab table. Use 'mk_video_table'
% function for help in generating this.
%

filelist = VidTable.TrackingFiles;

% pre-initialize the output so Matlab doesn't have a cow.
TrackingTable = table;

% Matlab disapproves some of the column-headings in Spot Tracker's 
% csv-outfile. This turns off the warning.

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

fid = VidTable.Fid;

for f = 1:length(fid)    
    
    % Handle the incoming data for whatever type it is...
    % First, check if the tracking file exists
    if isempty(VidTable.TrackingFiles{f})
        logentry(['No tracking file found for fid: ' num2str(fid(f))]);
        continue
    end
    

    myfile = fullfile(VidTable.Path{f}, VidTable.TrackingFiles{f});
    

    if contains(myfile, '.evt.mat')
        dd = load_evtfile(myfile);
    elseif contains(myfile, '.vrpn.mat')
        error('Do not know how to do this yet.');
    elseif contains(myfile, '.csv')
        dd = readtable(myfile);
    else
        error('Not familiar with file type.')
    end
    
    Fid = table(repmat(fid(f), size(dd,1), 1));
    Fid.Properties.VariableNames{'Var1'} = 'Fid';

    % rename the headers to something more easily coded/read
    dd.Properties.VariableNames{'FrameNumber'} = 'Frame';
    dd.Properties.VariableNames{'SpotID'}      = 'ID';
    
%     logentry(['Loaded *' filelist{f} '* which contains ' num2str(length(unique((dd.ID)))) ' initial trackers.']);

    % Z data and remaining values are nonexistant (These can be added back if needed in a
    % later version
%     dd.Z = [];
    dd.Orientation_ifMeaningful_ = [];
    dd.Length_ifMeaningful_ = [];
    dd.FitBackground_forFIONA_ = [];
    dd.GaussianSummedValue_forFIONA_ = [];
    dd.MeanBackground_FIONA_ = [];
    dd.SummedValue_forFIONA_ = [];

    % Copy X and Y into "original" X and Y columns to Xo and Yo them use X and
    % Y as filtered and/or drift-corrected dataset. This creates a bifurcation 
    % in the plausible output (filter vs. unfiltered) and doubles the number of 
    % MSD computations needed if original MSDs are desired. Don't really see 
    % any other way around it, though.
    % 
    dd.Xo = dd.X;
    dd.Yo = dd.Y;
    dd.Zo = dd.Z;
    
    % tack on the Fid value
    dd = [Fid dd];

    TrackingTable = [TrackingTable;dd];
end
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

% Housekeeping on data: 
%
% (1) Categorize metadata/grouping variables
% TrackingTable.Fid = categorical(TrackingTable.Fid);
% TrackingTable.ID = categorical(TrackingTable.ID);
% TrackingTable.Frame = categorical(TrackingTable.Frame);
% TrackingTable.Radius = categorical(TrackingTable.Radius); % because this is technically a tracking parameter

% (2) convert CenterIntensity to an 8-bit value since Video Spot Tracker
% returns a 16-bit number by default for some odd reason.
TrackingTable.CenterIntensity = floor(TrackingTable.CenterIntensity * (2^8/2^16));

% (3) Set some Table properties
TrackingTable.Properties.Description = 'Table of trajectories for Video Spot Tracking data';

% (3) Set Variable Descriptions and Units for each table column (i.e. Variable)
TrackingTable.Properties.VariableDescriptions{'Fid'} = 'FileID (key)';
TrackingTable.Properties.VariableUnits{'Fid'} = '';

TrackingTable.Properties.VariableDescriptions{'Frame'} = 'Frame Number';
TrackingTable.Properties.VariableUnits{'Frame'} = '';

TrackingTable.Properties.VariableDescriptions{'ID'} = 'Trajectory ID';
TrackingTable.Properties.VariableUnits{'ID'} = '';

TrackingTable.Properties.VariableDescriptions{'X'} = 'x-location';
TrackingTable.Properties.VariableUnits{'X'} = 'pixels';

TrackingTable.Properties.VariableDescriptions{'Y'} = 'y-location';
TrackingTable.Properties.VariableUnits{'Y'} = 'pixels';

TrackingTable.Properties.VariableDescriptions{'Z'} = 'z-location';
TrackingTable.Properties.VariableUnits{'Z'} = 'step size';

TrackingTable.Properties.VariableDescriptions{'Xo'} = 'x-location, orig.';
TrackingTable.Properties.VariableUnits{'Xo'} = 'pixels';

TrackingTable.Properties.VariableDescriptions{'Yo'} = 'y-location, orig.';
TrackingTable.Properties.VariableUnits{'Yo'} = 'pixels';

TrackingTable.Properties.VariableDescriptions{'Zo'} = 'z-location, orig.';
TrackingTable.Properties.VariableUnits{'Zo'} = 'step size';

TrackingTable.Properties.VariableDescriptions{'Radius'} = 'Tracker radius';
TrackingTable.Properties.VariableUnits{'Radius'} = 'pixels';

TrackingTable.Properties.VariableDescriptions{'CenterIntensity'} = 'Intensity at Tracker center.';
TrackingTable.Properties.VariableUnits{'CenterIntensity'} = 'Intensity';

% TrackingTable.Properties.VariableDescriptions{'BkgdIntensity'} = 'Intensity of surrounding background.';
% TrackingTable.Properties.VariableUnits{'BkgdIntensity'} = 'Intensity';

TrackingTable.Properties.VariableDescriptions{'RegionSize'} = 'Size of Image region that exceeds threshold.';
TrackingTable.Properties.VariableUnits{'RegionSize'} = 'pixels^2';

TrackingTable.Properties.VariableDescriptions{'Sensitivity'} = 'A measure of signal-to-noise ratio for Tracker in image';
TrackingTable.Properties.VariableUnits{'Sensitivity'} = '';

TrackingTable.Properties.VariableDescriptions{'ForegroundSize'} = '';
TrackingTable.Properties.VariableUnits{'ForegroundSize'} = 'pixels^2';


% (3) This hacks the Xo and Yo columns to be next to the X and Y columns. 
TrackingTable = movevars(TrackingTable, {'Frame', 'ID', ...
                                         'X', 'Y', 'Z', 'Xo', 'Yo', 'Zo', ...
                                         'Sensitivity', 'CenterIntensity', ...
                                         'ForegroundSize', 'RegionSize', ...
                                         'Radius'}, ...
                                         'After', 'Fid');

return