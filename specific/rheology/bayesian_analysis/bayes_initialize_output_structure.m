function bout = bayes_initialize_output_structure(Nfiles)
    b.name                = [];
    b.filename            = [];
    b.min_frames          = [];
    b.bead_radius         = [];
    b.num_subtraj         = [];
    b.pass                = [];
    b.well                = [];
    b.area                = [];
    b.sens                = [];  
    b.trackerID           = [];
    b.model               = [];
    b.prob                = [];
    
    % "results" contains the output from the Monnier Bayesian code base,
    % specified as follows...
    b.results.errors      = double([]);
    b.results.mean_curve  = struct;
    b.results.timelags    = double([]);
    b.results.msd_params  = struct;
    b.results.MSD_vs_timelag = double([]);
    
    % "original_curve_msd" is in the format of outputted video_msd...
    b.original_curve_msd.trackerID = double([]);
    b.original_curve_msd.tau = double([]);
    b.original_curve_msd.msd = double([]);
    b.original_curve_msd.Nestimates = double([]);
    b.original_curve_msd.window = double([]);
    
    b.agg_data            = [];
    
    bout = repmat(b, Nfiles, 1);
return;