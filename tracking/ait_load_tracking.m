function TrackingTable = ait_load_tracking(VidTable)
% VST_LOAD_TRACKING Loads csv-format datasets from aitracker.net circa 2018.12
% CISMM function
% Tracking
%  
% Loads and aggregates tracking from a dataset defined by the input, VidTable
% 
%  TrackingTable = vst_load_tracking(VidTable) 
%   
% 'VidTable' is a specifically formatted Matlab table. Use 'a'
% function for help in generating this.
%

filelist = VidTable.TrackingFiles;

% pre-initialize the output so Matlab doesn't have a cow.
TrackingTable = table;

% Matlab disapproves some of the column-headings in Spot Tracker's 
% csv-outfile. This turns off the warning.

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

fid = 1:size(VidTable,1);
F = length(fid);
dcell = cell(F,1);
for f = 1:F
    
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
    dd.Properties.VariableNames{'t'} = 'Frame';
    dd.Properties.VariableNames{'particle'}      = 'ID';
    dd.Properties.VariableNames{'x'} = 'X';
    dd.Properties.VariableNames{'y'} = 'Y';
    dd.Properties.VariableNames{'z'} = 'Z';
    dd.Properties.VariableNames{'r'} = 'Radius';
    dd.Properties.VariableNames{'Ipeak'} = 'CenterIntensity';
    dd.Properties.VariableNames{'Ibg'} = 'BkgdIntensity';
    dd.Properties.VariableNames{'SNR'} = 'SNR';
    
%     logentry(['Loaded *' filelist{f} '* which contains ' num2str(length(unique((dd.ID)))) ' initial trackers.']);

    % Z data and remaining values are nonexistant (These can be added back if needed in a
    % later version
%     dd.Z = [];
%     dd.Orientation_ifMeaningful_ = [];
%     dd.Length_ifMeaningful_ = [];
%     dd.FitBackground_forFIONA_ = [];
%     dd.GaussianSummedValue_forFIONA_ = [];
%     dd.MeanBackground_FIONA_ = [];
%     dd.SummedValue_forFIONA_ = [];

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

    dcell{f,1} = dd;
%     TrackingTable = [TrackingTable;dd];
end
TrackingTable = vertcat(dcell{:});
clear dcell;
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
TrackingTable.Sensitivity = TrackingTable.SNR .^2;

% Housekeeping on data: 
%
% (1) Categorize metadata/grouping variables
% TrackingTable.Fid = categorical(TrackingTable.Fid);
% TrackingTable.ID = categorical(TrackingTable.ID);
% TrackingTable.Frame = categorical(TrackingTable.Frame);
% TrackingTable.Radius = categorical(TrackingTable.Radius); % because this is technically a tracking parameter

% (2) Set Variable Units for each table column
TrackingTable.Properties.VariableUnits{'Fid'} = '';
TrackingTable.Properties.VariableUnits{'Frame'} = '';
TrackingTable.Properties.VariableUnits{'ID'} = '';
TrackingTable.Properties.VariableUnits{'X'} = 'pixels';
TrackingTable.Properties.VariableUnits{'Y'} = 'pixels';
TrackingTable.Properties.VariableUnits{'Z'} = 'step size';
TrackingTable.Properties.VariableUnits{'Xo'} = 'pixels';
TrackingTable.Properties.VariableUnits{'Yo'} = 'pixels';
TrackingTable.Properties.VariableUnits{'Zo'} = 'step size';
TrackingTable.Properties.VariableUnits{'Radius'} = 'pixels';
TrackingTable.Properties.VariableUnits{'CenterIntensity'} = 'Intensity-8-bit';
TrackingTable.Properties.VariableUnits{'BkgdIntensity'} = 'Intensity-8-bit';
% TrackingTable.Properties.VariableUnits{'RegionSize'} = 'pixels^2';
TrackingTable.Properties.VariableUnits{'Sensitivity'} = '';
% TrackingTable.Properties.VariableUnits{'ForegroundSize'} = 'pixels^2';


% (3) This hacks the Xo and Yo columns to be next to the X and Y columns. 
TrackingTable = movevars(TrackingTable, 'Frame', 'After', 'Fid');
TrackingTable = movevars(TrackingTable, 'ID', 'After', 'Frame');
TrackingTable = movevars(TrackingTable, 'Radius', 'After', 'ID');
TrackingTable = movevars(TrackingTable, 'X', 'After', 'Radius');
TrackingTable = movevars(TrackingTable, 'Y', 'After', 'X');
TrackingTable = movevars(TrackingTable, 'Z', 'After', 'Y');
TrackingTable = movevars(TrackingTable, 'Xo', 'After', 'Z');
TrackingTable = movevars(TrackingTable, 'Yo', 'After', 'Xo');
TrackingTable = movevars(TrackingTable, 'Zo', 'After', 'Yo');
TrackingTable = movevars(TrackingTable, 'CenterIntensity', 'After', 'Zo');
TrackingTable = movevars(TrackingTable, 'BkgdIntensity', 'After', 'CenterIntensity');
TrackingTable = movevars(TrackingTable, 'Sensitivity', 'After', 'BkgdIntensity');