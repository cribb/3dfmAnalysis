function TrackingTable = vst_initTrackingTable



ColumnNames = { 'Fid', 'Frame', 'ID', ...
                  'X', 'Y', 'Z', ...
                  'Xo', 'Yo', 'Zo', ...
                  'Sensitivity', 'CenterIntensity', ...
                  'ForegroundSize', 'RegionSize', 'Radius' };

ColumnTypes = {'categorical', 'uint32', 'categorical', ...
               'double', 'double', 'double', ...
               'double', 'double', 'double', ...
               'double', 'double', ...
               'double', 'double', 'double'};
           
TrackingTable = table('Size', [0, numel(ColumnNames)], ...
                      'VariableNames', ColumnNames, ...
                      'VariableTypes', ColumnTypes);
          
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




