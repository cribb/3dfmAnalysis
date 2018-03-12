function VidTable = pan_mk_video_table(filepath, systemid, plate_type)
% PAN_MK_VIDEO_TABLE Generates VidTable from a Panoptes dataset path
%
% Panoptes function 
% 
% When given a Panoptes dataset path, this function populates a VidTable, 
% which is a list of tracking datafiles and all metadata needed to display,
% convert units, and visualize the initial and image-projection
% video-frames, provided all that data exists in the path. The outputted
% VidTable is the subsequent input for pan_load_tracking,
% load_vst_tracking, etc.
% 
% VidTable = pan_sim_run(filepath, systemid, plate_type) 
%

mypath = fullfile(pwd, filepath);

metadata = pan_load_metadata(filepath, systemid, plate_type);

exptname = metadata.instr.experiment;

pass_list = 1:size(metadata.instr.offsets,1);
well_list = metadata.instr.wells;

fidmax = length(pass_list) * length(well_list);

% Initialize data types so Matlab doesn't complain
Tag  = cell(fidmax, 1);
Path = cell(fidmax, 1);
File = cell(fidmax, 1);
Pass = NaN(fidmax,1);
Well = NaN(fidmax,1);
Calibum = NaN(fidmax,1);
Fps = NaN(fidmax,1);
Width = NaN(fidmax,1);
Height = NaN(fidmax,1);
Firstframes = cell(fidmax,1);
Mips = cell(fidmax,1);

fid = 1;
for p = 1:length(pass_list)
    for w = 1:length(well_list)
        
        pass = pass_list(p);
        well = well_list(w);
        
        Path{fid,1} = mypath;
        
        % which files are the tracking files?
        basename_tracking = [exptname ...
                          '_video_pass' num2str(pass) ...
                          '_well' num2str(well) ...
                          '_TRACKED.csv'];
                      
        basename_tracking = dir(basename_tracking);
        
        if ~isempty(basename_tracking)
            File{fid,1} = basename_tracking.name;
        else
            File{fid,1} = '';
        end
        
        % Set the Tag (this is going to need better specification
        Tag{fid,1} = metadata.plate.solution.name{well};

        % calibum conversions
        MCUparam = metadata.mcuparams.mcu(metadata.mcuparams.well == well & ...
                                          metadata.mcuparams.pass == pass);
        [Calibum(fid,1), ~] = pan_MCU2um(MCUparam, systemid, well, metadata);

        Fps(fid,1) = metadata.instr.fps_fluo;
        
        
        % load the first frames
        basename_fframes = [exptname ...
                          '_FLburst_pass' num2str(pass) ...
                          '_well' num2str(well)];
                      
        fframe_name = [basename_fframes '\' 'frame0001.pgm'];
        
        if isdir(basename_fframes) && ~isempty(dir(fframe_name))
            Firstframes{fid,1} = imread(fframe_name);     
           % width/height of images
            [Width(fid,1), Height(fid,1)] = size(Firstframes{fid,1});
        else
            Firstframes{fid} = '';
            Width(fid,1) = NaN;
            Height(fid,1) = NaN;
        end        
        

        % load the mips
        basename_mips = [exptname ...
                          '_video_pass' num2str(pass) ...
                          '_well' num2str(well) ...
                          '.mip.pgm'];
                      
        basename_mips = dir(basename_mips);
        
        if ~isempty(basename_mips)
            Mips{fid,1} = imread(basename_mips.name);     
           
            % width/height of images
            [Height(fid,1), Width(fid,1)] = size(Mips{fid,1});
        else
            Mips{fid,1} = '';
            Width(fid,1) = NaN;
            Height(fid,1) = NaN;
        end 
                
        Pass(fid,1) = pass;
        Well(fid,1) = well;
        fid = fid + 1;
    end
end

Fid = (1:fid-1)';

VidTable = table(Fid, Path, File, Pass, Well, Tag, Fps, Calibum, Width, Height, Firstframes, Mips);
% v = table(Fid, Path, File, Pass, Well, Fps, Calibum, Width, Height, Firstframes, Mips);
