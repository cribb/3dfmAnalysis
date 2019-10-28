function m = ba_checkmetadata(m)

    % Order everything so it can be aggregated later
    m = orderfields(m, {'File', 'Bead', 'Substrate', 'Medium', 'Zmotor', 'Scope', 'Video', 'Results'});
    m.File = orderfields(m.File, {'Fid', 'SampleName', 'SampleInstance', 'Binfile', 'Binpath', 'Hostname', 'IncubationStartTime'});
    m.Bead = orderfields(m.Bead, {'Diameter', 'SurfaceChemistry', 'LotNumber', 'PointSpreadFunction', 'PointSpreadFunctionFilename'});    
    m.Substrate = orderfields(m.Substrate, {'Material', 'Size', 'SurfaceChemistry', 'Concentration_mgmL', 'LotNumber'});    
    m.Medium = orderfields(m.Medium, {'Name', 'ManufactureDate', 'Viscosity', 'Components', 'Buffer'});
    m.Zmotor = orderfields(m.Zmotor, {'StartingHeight', 'Velocity'});
    m.Scope = orderfields(m.Scope, {'Name', 'CodeName', 'Magnification', 'Magnifier', 'Calibum'});    
    m.Video = orderfields(m.Video, {'ExposureMode', 'FrameRateMode', 'ShutterMode', 'Gain', 'Gamma', 'Brightness', 'Format', 'Height', 'Width', 'Depth', 'ExposureTime'});
    m.Results = orderfields(m.Results, {'ElapsedTime', 'TimeHeightVidStatsTable', 'FirstFrame', 'LastFrame'});

end