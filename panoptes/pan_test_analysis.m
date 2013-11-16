function outs = pan_test_analysis

    % TEST 1: simulate 10 trackers for every well in the plate and check 
    % that returned viscosity is equal to input viscosity
    fileroot = '.';
    wells = [1:96];
    passes = [1:5];

    mkdir('test1');
    cd('test1');
    
    simstruct.numpaths = 10;
    simstruct.viscosity = 1;     % [Pa s]
    simstruct.bead_radius = 0.5e-6;        % [m]
    simstruct.frame_rate = 54;             % [frames/s]
    simstruct.duration = 60;               % [s]
    simstruct.tempK = 300;                 % [K]
    simstruct.field_width = 648;           % [pixels]
    simstruct.field_height = 488;          % [pixels]
    simstruct.calib_um = 0.171;            % [um/pixel];
    simstruct.xdrift_vel = 0;              % [m/frame];
    simstruct.ydrift_vel = 0;              % [m/frame];

    test1 = pan_sim_newt_run(fileroot, wells, passes, simstruct);

    d = pan_process_PMExpt('.', 'panoptes', 'n');
    
    outs = d;
return
