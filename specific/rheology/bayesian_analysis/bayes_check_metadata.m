function metadata = bayes_check_metadata(metadata)
    if ~isfield(metadata, 'num_subtraj');    
        logentry('N subtrajectories not specified. You need to set metadata.sub_traj. Exiting now....');
        error('');
    end
    
    if ~isfield(metadata, 'fps');    
        logentry('Frames-per-second not specified. You need to set metadata.fps. Exiting now....');
        error('');
    end
    
    if ~isfield(metadata, 'calibum');    
        logentry('Microscope calibrations not specified. You need to set metadata.calibum. Exiting now....');
        error('');
    end

    if ~isfield(metadata, 'bead_radius');    
        logentry('Bead diameters are not specified. You need to set metadata.bead_radius. Exiting now....');
        error('');
    end
    
    if ~isfield(metadata, 'filt');    
        logentry('Data filter not specified. Setting to defaults...');
        
        filt.min_frames = 1600;
        filt.xyzunits   = 'm';
        filt.calib_um   = metadata.calibum;                
    end

    if ~isfield(metadata, 'numtaus');    
        logentry('Number of time scales is not specified. Setting to default...');
        metadata.numtaus = 35;       
    end
    
    if ~isfield(metadata, 'sample_names');    
        logentry('Sample descriptors are not specified. You need to set metadata.sample_names. Exiting now....');
        error('');
    end
    
    if ~isfield(metadata, 'models');    
        logentry('Bayesian model types are not specified. Settinf to default...');
        metadata.models      = {'N', 'D', 'DA', 'DR', 'V'};
    end

    if ~isfield(metadata, 'refdata');    
        logentry('Reference dataset not specified. You need to set metadata.refdata. Exiting now....');
        error('');
    end

return;


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'bayes_check_metadata: '];
     
     fprintf('%s%s\n', headertext, txt);
return;