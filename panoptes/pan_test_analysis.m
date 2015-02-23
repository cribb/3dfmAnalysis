function outs = pan_test_analysis

    % TEST 1: simulate 10 trackers for every well in the plate and check 
    % that returned viscosity is equal to input viscosity
    filepath = '.';
    
    testname = 'test1';
    
    mkdir(testname);
    cd(testname);
    test1_EC_file = which('test1_ExperimentConfig.txt');
    test1_WL_file = which('test1_WELL_LAYOUT.csv');
    test1_MCU_file = which('test1_MCUparams.txt');
    
    copyfile(test1_EC_file, filepath);
    copyfile(test1_WL_file, filepath);
    copyfile(test1_MCU_file, filepath);
    
    test1 = pan_sim_run(filepath, 'panoptes', '96well');

    outs = pan_process_PMExpt('.', 'panoptes', 'n');
    
return
