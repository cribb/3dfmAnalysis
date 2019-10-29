function FileSummary = vst_summarize_files(TrackingSummary)

    % Identifying the trajectory groups
    TrackingSummary.Tmp = zeros(height(TrackingSummary),1);
    [g, FileSummary] = findgroups(TrackingSummary(:,{'Fid', 'Tmp'}));
    FileSummary.Tmp  = [];
    
    % Number of trajectories in each file (fid)
    FileSummary.Ntraj = splitapply(@(x)length(unique(x)), TrackingSummary.ID, g);
    FileSummary.Properties.VariableDescriptions{'Ntraj'} = 'Number of trajectories for File ID.';
    FileSummary.Properties.VariableUnits{'Ntraj'} = '[]';
   
    % calculating average trajectory lengths
    FileSummary.meantrajLength = splitapply(@mean, TrackingSummary.Length, g);
    FileSummary.Properties.VariableDescriptions{'meantrajLength'} = 'Mean trajectory length in frames for File ID.';
    FileSummary.Properties.VariableUnits{'meantrajLength'} = '[frames]';

    FileSummary.mediantrajLength = splitapply(@median, TrackingSummary.Length, g);
    FileSummary.Properties.VariableDescriptions{'mediantrajLength'} = 'Median trajectory length in frames for File ID';
    FileSummary.Properties.VariableUnits{'mediantrajLength'} = '[frames]';

    FileSummary.mintrajLength = splitapply(@min, TrackingSummary.Length, g);
    FileSummary.Properties.VariableDescriptions{'mintrajLength'} = 'Minimum trajectory length in frames for File ID.';
    FileSummary.Properties.VariableUnits{'mintrajLength'} = '[frames]';
    
    FileSummary.maxtrajLength = splitapply(@max, TrackingSummary.Length, g);
    FileSummary.Properties.VariableDescriptions{'maxtrajLength'} = 'Maximum trajectory length in frames for File ID.';
    FileSummary.Properties.VariableUnits{'maxtrajLength'} = '[frames]';
    
    FileSummary.mean_eedist = splitapply(@nanmean, TrackingSummary.EndDist, g);
    FileSummary.Properties.VariableDescriptions{'mean_eedist'} = 'Mean of trajectory end-to-end distances in pixels for this File ID.';
    FileSummary.Properties.VariableUnits{'mean_eedist'} = '[pixels]';
    
    FileSummary.stderr_eedist = splitapply(@stderr, TrackingSummary.EndDist, g);
    FileSummary.Properties.VariableDescriptions{'stderr_eedist'} = 'Standard error of trajectory end-to-end distances in pixels for this File ID.';
    FileSummary.Properties.VariableUnits{'stderr_eedist'} = '[pixels]';
    
    FileSummary.mean_eeangl = splitapply(@mean, TrackingSummary.EndAngl, g);
    FileSummary.Properties.VariableDescriptions{'mean_eeangl'} = 'Mean of trajectory end-to-end angles in radians for this File ID.';
    FileSummary.Properties.VariableUnits{'mean_eeangl'} = '[radians]';
    
    FileSummary.stderr_eeangl = splitapply(@stderr, TrackingSummary.EndAngl, g);
    FileSummary.Properties.VariableDescriptions{'stderr_eeangl'} = 'Mean of trajectory end-to-end angles in radians for this File ID.';
    FileSummary.Properties.VariableUnits{'stderr_eeangl'} = '[radians]';
    
    FileSummary.mean_sens = splitapply(@mean, TrackingSummary.MeanSens, g);    
    FileSummary.Properties.VariableDescriptions{'mean_sens'} = 'Mean of trajectory signal-to-noise values for this FileID.';
    FileSummary.Properties.VariableUnits{'mean_sens'} = '[]';

return