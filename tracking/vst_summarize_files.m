function FileSummary = vst_summarize_files(TrackingSummary)

    Fid = TrackingSummary.Fid;
    flist = unique(Fid);

    g = findgroups(Fid);
    glist = unique(g);
    
    file.Fid = flist;
    
    % Number of trajectories in each file (fid)
    file.Ntraj = splitapply(@(x)length(unique(x)), TrackingSummary.ID, g);
    
    % calculating average trajectory lengths
    file.meantrajLength = splitapply(@mean, TrackingSummary.Length, g);
    file.mintrajLength = splitapply(@min, TrackingSummary.Length, g);
    file.maxtrajLength = splitapply(@max, TrackingSummary.Length, g);
    file.mean_eedist = splitapply(@nanmean, TrackingSummary.EndDist, g);
    file.stderr_eedist = splitapply(@stderr, TrackingSummary.EndDist, g);
    file.mean_eeangl = splitapply(@mean, TrackingSummary.EndAngl, g);
    file.stderr_eeangl = splitapply(@stderr, TrackingSummary.EndAngl, g);

    FileSummary = struct2table(file);

    
return