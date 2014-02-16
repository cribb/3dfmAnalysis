function outs = pan_sim_run(filepath, systemid, plate_type)
    
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
    
    metadata = pan_load_metadata(filepath, systemid, plate_type);

    fps = round(metadata.instr.fps_imagingmode);
    duration = metadata.instr.seconds;
    num_passes = size(metadata.instr.offsets,1);
    num_wells = length(metadata.plate.well_map);
    fileroot = metadata.instr.experiment;
    MCUs = [metadata.mcuparams.well metadata.mcuparams.pass metadata.mcuparams.mcu];
    num_solns = length(metadata.plate.solution);
    
    for p = 1:num_passes
        for w = 1:num_wells            
            all_traj = [];
            for s = 1:num_solns
                mywell = str2num(metadata.plate.well_map{w});

                myfilename = [fileroot '_video_pass' num2str(p) '_well' num2str(mywell) '_TRACKED'];

                mcuIDX  = find(MCUs(:,1) == mywell & ...
                               MCUs(:,2) == p);
                if size(mcuIDX,1) > 1
                    error('Too many MCUs defined in MCU file');
                end
                myMCU = MCUs(mcuIDX,3);

                sim.bead_radius = metadata.plate.bead.diameter(1,w)/2 * 1e-6;
                sim.viscosity = str2double(metadata.plate.solution(s).viscosity{w,1});
                sim.rad_confined = str2double(metadata.plate.solution(s).confinement_radius{w,1})*1e-6;
                sim.alpha = str2double(metadata.plate.solution(s).alpha{w,1});
                sim.modulus = str2double(metadata.plate.solution(s).modulus{w,1});
                sim.frame_rate = fps;
                sim.duration = duration;
                sim.tempK = str2double(metadata.plate.solution(s).temperature{w,1})+273;
                sim.field_width = str2double(metadata.plate.simulation.fov_width{w,1});
                sim.field_height = str2double(metadata.plate.simulation.fov_height{w,1});
                sim.xdrift_vel = str2double(metadata.plate.simulation.drift_velocity_x{w,1}) * 1e-6 / sim.frame_rate;
                sim.ydrift_vel = str2double(metadata.plate.simulation.drift_velocity_y{w,1}) * 1e-6 / sim.frame_rate;
               [sim.calib_um, ~] = pan_MCU2um(myMCU, systemid, mywell);

                [traj, simout] = sim_video_diff_expt([], sim);
                
                if ~isempty(all_traj)
                    traj(:,ID) = traj(:,ID) + max(all_traj(:,ID));
                end
                all_traj = [all_traj ; traj]; %#ok<AGROW>

                save_vrpnmatfile(myfilename, all_traj, 'pixels', 1);
                save_evtfile(myfilename, all_traj, 'pixels', sim.calib_um);
            end
        end        
    end

    % reload metadata to get filenames that were generated and send new
    % metadata as the output
    metadata = pan_load_metadata(filepath, systemid, plate_type);
    
    outs = metadata;
return;