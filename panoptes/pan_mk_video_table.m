function VidTable = pan_mk_video_table(filepath, systemid, plate_type, tracking_style)
% PAN_MK_VIDEO_TABLE Generates VidTable from a Panoptes dataset path
%
% Panoptes function 
% 
% When given a Panoptes dataset path, this function populates a VidTable, 
% which is a list of tracking datafiles and all metadata needed to display,
% convert units, and visualize the initial and image-projection
% video-frames, provided all that data exists in the path. The outputted
% VidTable is the subsequent input for pan_load_tracking,
% vst_load_tracking, etc.
% 
% VidTable = pan_mk_video_table(filepath, systemid, plate_type) 
%

if nargin < 4 || isempty(tracking_style)
    tracking_style = 'vst';
end

mypath = fullfile(pwd, filepath);

[~,host] = system('hostname');
host = strip(host);

metadata = pan_load_metadata(filepath, systemid, plate_type);

exptname = metadata.instr.experiment;

pass_list = 1:size(metadata.instr.offsets,1);
well_list = metadata.instr.wells;

fidmax = length(pass_list) * length(well_list);

% Initialize data types so Matlab doesn't complain
Hostname = repmat({host},fidmax,1);
SampleName  = cell(fidmax, 1);
SampleInstance = cell(fidmax,1);   % Well = NaN(fidmax,1);
FovID = cell(fidmax,1);        % Pass = NaN(fidmax,1);
VideoFiles = cell(fidmax, 1);
FirstFrameFiles = cell(fidmax, 1);
MipFiles = cell(fidmax, 1);
Path = cell(fidmax, 1);
TrackingFiles = cell(fidmax, 1);
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
        
        SampleInstance{fid,1} = ['well' num2str(well, '%02i')];
        FovID{fid,1} = ['pass' num2str(pass, '%02i')];
        
        Path{fid,1} = mypath;
        
        basename = [exptname ...
                    '_video_pass' num2str(pass) ...
                    '_well' num2str(well)];

        VideoFiles{fid,1} = basename;
        
        % which files are the tracking files?
        if contains(lower(tracking_style), 'vst')
            basename_tracking = [basename '_TRACKED.csv'];
        elseif contains(lower(tracking_style), 'ait')
            basename_tracking = [basename '.tif.csv'];
        else
            error('This tracking style is undefined.');
        end
        
        basename_tracking = dir(basename_tracking);
        
        if ~isempty(basename_tracking)
            TrackingFiles{fid,1} = basename_tracking.name;
        else
            TrackingFiles{fid,1} = '';
        end
        
        % Set the SampleName (XXX TODO this is going to need better specification)
        SampleName{fid,1} = metadata.plate.solution.name{well};

        % calibum conversions
        MCUparam = metadata.mcuparams.mcu(metadata.mcuparams.well == well & ...
                                          metadata.mcuparams.pass == pass);
        [Calibum(fid,1), ~] = pan_MCU2um(MCUparam, systemid, well, metadata);

        Fps(fid,1) = metadata.instr.fps_fluo;
        
        
        % load the first frames
%         basename_fframes = [exptname ...
%                           '_FLburst_pass' num2str(pass) ...
%                           '_well' num2str(well)];
%                       
%         fframe_name = [basename_fframes filesep 'frame0001.pgm'];
        basename_fframes = [exptname ...
                           '_video_pass' num2str(pass) ...
                           '_well' num2str(well)];
                      
        fframe_name = [basename_fframes '.0001.pgm'];   

        FirstFrameFiles{fid,1} = fframe_name;
        
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
                      
        mipname = dir(basename_mips);
        
        if ~isempty(mipname)
            Mips{fid,1} = imread(mipname.name);     
            MipFiles{fid,1} = mipname.name;           
            % width/height of images
            [Height(fid,1), Width(fid,1)] = size(Mips{fid,1});
        else
            Mips{fid,1} = '';
            MipFiles{fid,1} = '';
            Width(fid,1) = NaN;
            Height(fid,1) = NaN;
        end 
        

                
        Pass(fid,1) = pass;
        Well(fid,1) = well;
        fid = fid + 1;
    end
    
end

% Fid = (1:fid-1)'; % change this to random uint64
Fid = randi(2^50,fid-1,1);
% Fid = categorical(Fid);
SampleName = categorical(SampleName);
SampleInstance = categorical(SampleInstance);
FovID = categorical(FovID);

VidTable = table(Fid, SampleName, SampleInstance, FovID, Path, Hostname, VideoFiles, TrackingFiles, FirstFrameFiles, MipFiles, Width, Height, Fps, Calibum);

VidTable.Properties.Description = 'Table of files comprising Monoptes/Panoptes single-plate study';
VidTable.Properties.VariableDescriptions{'Fid'} = 'FileID (key)';
VidTable.Properties.VariableDescriptions{'SampleName'} = 'Sample name found in Well Layout';
VidTable.Properties.VariableDescriptions{'SampleInstance'} = 'ID/Number/Instance of Sample Name';
VidTable.Properties.VariableDescriptions{'FovID'} = 'Field-of-view ID/Number';
VidTable.Properties.VariableDescriptions{'Path'} = 'Path for File ID';
VidTable.Properties.VariableDescriptions{'Hostname'} = 'Systemname where File ID is loaded';
VidTable.Properties.VariableDescriptions{'VideoFiles'} = 'Orig. filename of video or path containing stack of images';
VidTable.Properties.VariableDescriptions{'TrackingFiles'} = 'Files containing trajectory/tracking data';
VidTable.Properties.VariableDescriptions{'FirstFrameFiles'} = 'First image filename for File ID';
VidTable.Properties.VariableDescriptions{'MipFiles'} = 'Max/min/mean Inensity Projection filename for File ID';

VidTable.Properties.VariableDescriptions{'Width'} = 'Horizontal video resolution';
VidTable.Properties.VariableUnits{'Width'} = 'pixels';

VidTable.Properties.VariableDescriptions{'Height'} = 'Vertical video resolution';
VidTable.Properties.VariableUnits{'Height'} = 'pixels';

VidTable.Properties.VariableDescriptions{'Fps'} = 'Frames per second for video';
VidTable.Properties.VariableUnits{'Fps'} = 'frames/sec';

VidTable.Properties.VariableDescriptions{'Calibum'} = 'Calibration scale for pixel size in microns';
VidTable.Properties.VariableUnits{'Calibum'} = 'um/pixel';


return