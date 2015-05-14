function outs = pan_sim_MCUfile(filepath, systemid, plate_type, value)

    if nargin < 4 || isempty(value)
        value = NaN;
    end
    
    if nargin < 3 || isempty(plate_type)
        plate_type = '96well';
    end

    if nargin < 2 || isempty(systemid)
        systemid = 'panoptes';
    end
    
    if nargin < 1 || isempty('filepath')
        filepath = '.';
    end
    
    video_tracking_constants;
    
    metadata_file = dir('*ExperimentConfig*.txt');
    layout_file   = dir('*WELL_LAYOUT*.csv');
    if ~isempty(metadata_file)
        metadata.instr = pan_read_wells_txtfile( metadata_file.name );
    else
        error('No ExperimentConfig file.');
    end
        
    % Read in the well layout file, if we have one
    if ~isempty(layout_file)
        metadata.plate = pan_read_well_layout( layout_file.name , plate_type );
    else
        error('No WELL_LAYOUT file.');
    end
    
    scales = metadata.instr.scales;
    offsets = metadata.instr.offsets;
    wells = str2num(cell2mat(metadata.plate.well_map));

    num_offsets = size(offsets,1);
    num_wells = length(wells);
    
    list_offsets = 1:num_offsets;
    
    
    CHANNELID = 1;
    LIMIT_LOW = 4;
    LIMIT_HIGH = 5;
        
    fid = fopen([metadata.instr.experiment '_MCUparams.txt'], 'w');
    fprintf(fid, 'well   pass   MCU param\n');
    
    for k = 1 : length(wells)
        for m = 1 : length(list_offsets)
            myoffset = list_offsets(m);
            mywell = wells(k);
            mychan = pan_get_channel_id(mywell);
            chanIDX = find(scales(:,CHANNELID) == mychan);
            
            mylimLOW = scales(chanIDX, LIMIT_LOW);
            mylimHIGH = scales(chanIDX, LIMIT_HIGH);
            
            myMCU = randi([mylimLOW mylimHIGH]);
            
            fprintf(fid, '%i %i %i\n', wells(k), list_offsets(m), myMCU);
        end
    end
    
    fclose(fid);
        
   outs = 0;
   
   return;