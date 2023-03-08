function VelocityTable = vst_initVelocityTable


ColumnNames = { 'Fid', 'Frame', 'ID', ...
                  'Vx', 'Vy', 'Vz', ...
                  'Vr', 'Vtheta', 'Vclr' };

ColumnTypes = {'categorical', 'uint32', 'categorical', ...
               'double', 'double', 'double', ...
               'double', 'double', 'double' };
           
VelocityTable = table('Size', [0, numel(ColumnNames)], ...
                      'VariableNames', ColumnNames, ...
                      'VariableTypes', ColumnTypes);
          
VelocityTable.Properties.Description = 'Table of velocities for VST or trackpy trajectories';

% (3) Set Variable Descriptions and Units for each table column (i.e. Variable)
VelocityTable.Properties.VariableDescriptions{'Fid'} = 'FileID (key)';
VelocityTable.Properties.VariableUnits{'Fid'} = '';

VelocityTable.Properties.VariableDescriptions{'Frame'} = 'Frame Number';
VelocityTable.Properties.VariableUnits{'Frame'} = '';

VelocityTable.Properties.VariableDescriptions{'ID'} = 'Trajectory ID';
VelocityTable.Properties.VariableUnits{'ID'} = '';

VelocityTable.Properties.VariableDescriptions{'Vx'} = 'x-velocity';
VelocityTable.Properties.VariableUnits{'Vx'} = 'pixels/frame';

VelocityTable.Properties.VariableDescriptions{'Vz'} = 'y-velocity';
VelocityTable.Properties.VariableUnits{'Vy'} = 'pixels/frame';

VelocityTable.Properties.VariableDescriptions{'Vz'} = 'z-velocity';
VelocityTable.Properties.VariableUnits{'Vz'} = 'steps/frame';

VelocityTable.Properties.VariableDescriptions{'Vr'} = 'radial velocity';
VelocityTable.Properties.VariableUnits{'Vr'} = 'pixels/frame';

VelocityTable.Properties.VariableDescriptions{'Vtheta'} = 'direction of velocity'; 
VelocityTable.Properties.VariableUnits{'Vtheta'} = 'radians';

VelocityTable.Properties.VariableDescriptions{'Vclr'} = 'radial velocity, cast into colorspace';
VelocityTable.Properties.VariableUnits{'Vclr'} = 'steps/frame';


