function outs = pan_load_metadata(filepath, systemid, plate_type, tracking_style)
    if nargin < 4 || isempty(tracking_style)
        tracking_style = 'vst';
    end
    
    if nargin < 3 || isempty(plate_type)
        plate_type = '96well';
    end

    if nargin < 2 || isempty(systemid)
        systemid = 'monoptes';
    end
    
    if nargin < 1 || isempty('filepath')
        filepath = '.';
    end

    cd(filepath);

    filelist = dir(filepath);

    % dictionary for loading experiment metadata
    outs.files.wells     = dir('*ExperimentConfig*.txt');
    outs.files.layout    = dir('*WELL_LAYOUT*.csv');
    outs.files.MCUparams = dir('*MCUparams*.txt');
    outs.files.tracking.config_find = dir('*_find.cfg');
    outs.files.tracking.config_track = dir('*_track.cfg');
    
%     outs = check_file_inputs(outs);

    % if isempty(outs.files)
    %     % insufficient metadata
    %     return;
    % end

    % read in the intrument's parameters
    if ~isfield(outs, 'files')
        logentry('No metadata found.');
        return;
    end

    % read in the "wells.txt" file that contains the instrument configuration
    if ~isempty(outs.files.wells)
        outs.instr = pan_read_wells_txtfile( outs.files.wells.name );
        outs.instr.fps_bright = 1e6 ./ (outs.instr.OnTime_bright + outs.instr.OffTime);
        outs.instr.fps_fluo   = 1e6 ./ (outs.instr.OnTime_fluo + outs.instr.OffTime);
        
        switch outs.instr.video_mode
            case 0
                outs.instr.fps_imagingmode = outs.instr.fps_bright;
            case 1
                outs.instr.fps_imagingmode = outs.instr.fps_fluo;
            otherwise
                error('Unknown video mode type.');
        end
        
        % if the instrument is panoptes (rather than monoptes) then expand
        % the wellIDs that were defined in the wells.txt file
        if strfind(systemid,'panoptes')
            for k = 1:length(outs.instr.wells)
                new_well_list(k,1:12) = outs.instr.wells(k) + [0:11];
            end
            
            new_well_list = new_well_list';
            new_well_list = unique(new_well_list);
            outs.instr.wells = unique(new_well_list(:));
        end
        outs.instr.systemid = systemid;
    else
        
        error('No ExperimentConfig file.')
    end

    % Read in the well layout file, if we have one
    if ~isempty(outs.files.layout)
        outs.plate = pan_read_well_layout( outs.files.layout.name , plate_type );
        outs.plateT = pan_plate_metadata(outs.files.layout.name);
    else
        error('No WELL_LAYOUT file.');
    end

    % Read in the mcu parameters
    if ~isempty(outs.files.MCUparams)
        outs.mcuparams = pan_read_MCUparamsfile( outs.files.MCUparams.name );
    else
        error('No MCU parameter file.');
    end
    
    % Read in the tracking parameters, if they exist
    if ~isempty(outs.files.tracking.config_track)
        outs.vstparams = vst_loadcfg(outs.files.tracking.config_track.name);
    else
        warning('No tracking parameters defined.');
    end

    % Need to convert bead diameters from cell of strings to numerical
    % vector.  I'm sure there is an easier way to do this, something that
    % is not so awkward.  I wish I had time to figure it out.
    if isfield(outs.plate.bead, 'diameter')
        for k = 1:96
            this_diameter = str2num(outs.plate.bead.diameter{k});

            if ~isempty(this_diameter)
                bead_diameter(k,1) =  this_diameter;
            else
                bead_diameter(k,1) = NaN;           
            end
        end
        
        outs.plate.bead.diameter = bead_diameter;
    else
        error('No bead data defined.');
    end
    
    % other file lists
    outs.files.FLburst   = dir('*FLburst*');
    outs.files.mip       = dir('*.mip.pgm');
    outs.files.video        = dir('*video*.vrpn');
    outs.files.tracking.mat = dir('*_TRACKED.vrpn.mat');
    
    if contains(lower(tracking_style), 'vst')
        outs.files.tracking.csv = dir('*_TRACKED.csv');
    elseif contains(lower(tracking_style), 'ait')
        outs.files.tracking.csv = dir('*.tif.csv');
    else
        error('This tracking style is undefined.');
    end       

    outs.files.tracking.evt = dir('*.vrpn.evt.mat');

    if ~isempty(outs.files.tracking.csv)
        tmp = outs.files.tracking.csv;
    elseif ~isempty(outs.files.tracking.evt)
        tmp = outs.files.tracking.evt;
    else
        warning('There are no tracking or evt files to analyze.');
        return;
    end
    
    for k = 1:length(tmp)
        [well_(k) pass_(k)] = pan_wellpass(tmp(k).name);
    end

    outs.well_list = unique(well_)';
    outs.pass_list = unique(pass_)';  
return;





%--  SUBFUNCTIONS BELOW  --%

function outs = check_file_inputs(ins)

    if isempty(ins.files.wells) 
        logentry('No ExperimentConfig file.');
    end

    if isempty(ins.files.layout)
        logentry('No PlateLayout file.');
    end

    if isempty(ins.files.MCUparams)
        logentry('No MCUparams file.');
    end

    if isempty(ins.files.tracking.csv)
        logentry('No tracking data.');
    end   
    
    if isempty(ins.files.video)
        logentry('No video files.  Data can not be retracked (from this data directory).');
    end
    
    if isempty(ins.files.tracking.evt)
        logentry('No evt files.  Will need to filter tracking data first.');
        ins.flags.filter = 1;
    end
    
%     if isempty(ins.files.wells)     || ...
%        isempty(ins.files.layout)    || ...
%        isempty(ins.files.MCUparams) || ...
%        isempty(ins.files.tracking.csv)
%         outs = [];
%     else
%         outs = ins;
%     end;
    
    outs = ins;
    
    return;
