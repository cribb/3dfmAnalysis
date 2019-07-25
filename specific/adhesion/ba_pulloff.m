function ba_pulloff(h, filename, exptime)
% Prior to starting experiment, make sure the magnet is centered.  Lower
% the magnet to 0 and use the vertical micrometer to ensure the tips of the
% magnet will touch the top of a glass slide (to apply maximum force to
% bead).  Click on the apps tab and open image acquisition.  Use the
% horizontal micrometers to line up the magnet gap with the field of view.
% If done correctly, you will not see the tips of the magnets show up.  You
% may have to adjust the focus and increase the gain to see the gap with
% fluorescence.  Close image acquisition, then run the first two sections
% of this script.  Raise the motor back to 12mm by clicking the height box
% in the gui and typing the desired height.  Carefully place the sample
% under the magnet, making sure the magnet will not contact and edge of the
% chamber when it is lowered.  Close the gui, then reopen image acqusition.
% Find a region that has 20-40 beads.  Beads within a diameter from
% each other or an edge will probably not work well when tracking. Focus the region, then
% close image acquisition again.  Run the script.

if nargin < 1 || isempty(h)
    disp('No z-controller object. Connecting to z-motor now...');
    try
        h = ba_initz;
    catch
        error('No connection. Is motor connected and running?');
    end
    disp('Connected.');
end

if nargin < 2 || isempty(filename)
    error('Need filename.');
end

if nargin < 3 || isempty(exptime)
    exptime = 8; % [ms]
end

PSF_filename = 'D:\jcribb\src\3dfmAnalysis\specific\adhesion\psf\mag_10x_bead_24umdiaYG_stepsize_1um.psf.tif';
impsf = imread(PSF_filename);

Name = {'Lactose', 'Galactose', 'GalNAc', 'GlcNac', 'Sialic Acid', 'PEG20k'}';
Conc = {0.0365, 0.0365, 0.0365, 0.0365, 0.0365, 0.2}';
ConcUnits = {'mol/L', 'mol/L', 'mol/L', 'mol/L', 'mol/L', 'mass fraction'}';
Int25k = table(Name, Conc, ConcUnits);
clear Name Conc ConcUnits

Name = {'PEG20k'}';
Conc = {0.2}';
ConcUnits = {'mass fraction'}';
NoInt = table(Name, Conc, ConcUnits);
clear Name Conc ConcUnits

starting_height = 12;
abstime{1,1} = [];
framenumber{1,1} = [];
TotalFrames = 0;
motor_velocity = 0.2; % [mm/sec]

Nsec = starting_height/motor_velocity + 1;
Fps = 1 / (exptime/1000);
% NFrames = ceil(Fps * Nsec);
NFrames = 7625;

height = NaN(NFrames,1);
height(1,1) = starting_height;

imaqmex('feature', '-previewFullBitDepth', true);
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
vid.ReturnedColorspace = 'grayscale';
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = NFrames;

% Following code found in apps -> image acquisition
% More info here: http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html
src = getselectedsource(vid); 
src.ExposureMode = 'off'; 
src.FrameRateMode = 'off';
src.ShutterMode = 'manual';
src.Gain = 10;
src.Gamma = 1.15;
src.Brightness = 5.8594;
src.Shutter = exptime;

vidRes = vid.VideoResolution;
imagetype = 'uint16';

imageRes = fliplr(vidRes);

filename = [filename, '_', num2str(vidRes(1)), 'x', ...
                           num2str(vidRes(2)), 'x', ...
                           num2str(NFrames), '_uint16'];

f = figure;%('Visible', 'off');
pImage = imshow(uint16(zeros(imageRes)));
axis image
setappdata(pImage, 'UpdatePreviewWindowFcn', @ba_pulloffview)
p = preview(vid, pImage);
set(p, 'CDataMapping', 'scaled');


% ----------------
% Controlling the Hardware and running the experiment
%

pause(2);
logentry('Starting video...');
start(vid);
pause(2);

NFramesAvailable = 0;

% XXX TODO: Change bin filename to include frame width, height, depth, Nframes
binfilename = [filename,'.bin'];
if ~isempty(dir(binfilename))
    delete(vid);
    clear vid
    close(f)
    error('That file already exists. Change the filename and try again.');
end
fid = fopen(binfilename, 'w');

% set motor velocity to .2 mm/sec
h.SetVelParams(0, 0, 1, motor_velocity); 

% move from starting position in mm down to 0 mm
h.SetAbsMovePos(0, 0); 
pause(2);
logentry('Moving motor...');
h.MoveAbsolute(0, 1==0);


logentry('Triggering video collection...');
cnt = 0;
trigger(vid);

% start timer for video timestamps
t1=tic; 

% Check and store the motor position every 100 ms until it reaches zero. 
pause(4/Fps);
while(vid.FramesAvailable > 0)
    cnt = cnt + 1;
    height(cnt) = h.GetPosition_Position(0); 
    
    NFramesAvailable(cnt,1) = vid.FramesAvailable;
    [data, ~, meta] = getdata(vid, NFramesAvailable(cnt,1));    
    
    abstime{cnt,1} = vertcat(meta(:).AbsTime);
    framenumber{cnt,1} = meta(:).FrameNumber;

%     TotalFrames = TotalFrames + NFramesAvailable;   
    [rows, cols, rgb, frames] = size(data);


    if cnt == 1
        firstframe = data(:,:,1,1);
    end
        
    fwrite(fid, data, imagetype);

    if ~mod(cnt,5)
        drawnow;
    end

end

lastframe = data(:,:,1,end);

elapsed_time = toc(t1);

logentry('Stopping video collection...');
stop(vid);
pause(1);
    
% Quickly move the ThorLabs z-motor to the starting height
ba_movez(h, starting_height, 'fast')

% Close the video .bin file
fclose(fid);

height(cnt+1:end) = [];
NFramesCollected = sum(NFramesAvailable);
AbsFrameNumber = cumsum(NFramesAvailable);

logentry(['Total Frame count: ' num2str(NFramesCollected)]);

% The z-position of the Thorlabs motor is not queried at every frame, so to
% put the measurements on the same "clock", I'm going to interpolate motor
% position between the frame clusters grabbed from the vid object and
% combine time and z-position into a single table.
interp_heights(:,1) = interp1(AbsFrameNumber, height, 0:NFramesCollected-1);
time = cellfun(@(x)seconds(days(datenum(x))), abstime, 'UniformOutput', false);
time = vertcat(time{:});

Fid = randi(2^50,1,1);
[~,host] = system('hostname');

[a,b] = regexpi(filename,'(\d*)_B-([a-zA-Z0-9]*)_S-([a-zA-Z0-9]*)_([a-zA-Z0-9]*)_(\d*)x(\d*)x(\d*)_(\w*)', 'match', 'tokens');
b = b{1};
SampleInstance = b{1};
BeadChemistry = b{2};
SubstrateChemistry = b{3};
MediumName = b{4};

m.File.Fid = Fid;
m.File.SampleName = filename;
m.File.SampleInstance = SampleInstance;
m.File.Binfile = binfilename; 
m.File.Binpath = pwd;
m.File.Hostname = strip(host);
switch MediumName
    case 'NoInt'
        m.File.IncubationStartTime = '07/18/2019 12:15 pm';
    case 'Int'
        m.File.IncubationStartTime = '07/18/2019 12:30 pm';
end

m.Bead.Diameter = 24;
m.Bead.SurfaceChemistry = BeadChemistry;
m.Bead.PointSpreadFunction = impsf;
m.Bead.PointSpreadFunctionFilename = PSF_filename;

m.Substrate.SurfaceChemistry = SubstrateChemistry;
m.Substrate.Size = '50x75x1 mm';

m.Medium.Name = MediumName;
m.Medium.ManufactureDate = '07-10-2019';   
switch m.Medium.Name
    case 'Int'
        % 07.11.2019 Data (SNA, WGA, PEG beads on BSM-slides)
        m.Medium.Viscosity = 0.0605;  
        m.Medium.Components = Int25k;
    case 'NoInt'
        % 07.11.2019 Data (SNA, WGA, PEG beads on BSM-slides)
        m.Medium.Viscosity = 0.0527;  
        m.Medium.Components = NoInt;
    otherwise
        logentry('Unknown Case for Medium.');
end    
m.Medium.Buffer = 'PBS';


m.Zmotor.StartingHeight = starting_height;
m.Zmotor.Velocity = motor_velocity;

m.Scope.Name = 'Olympus IX-71';
m.Scope.CodeName = 'Ixion';
m.Scope.Magnification = 10;
m.Scope.Magnifier = 1;
m.Scope.Calibum = 0.346;

m.Video.ExposureMode = src.ExposureMode; 
m.Video.FrameRateMode = src.FrameRateMode;
m.Video.ShutterMode = src.ShutterMode;
m.Video.Gain = src.Gain;
m.Video.Gamma = src.Gamma;
m.Video.Brightness = src.Brightness;
m.Video.Format = vid.VideoFormat;
m.Video.Height = 768;
m.Video.Width = 1024;
m.Video.Depth = 16;
m.Video.ExposureTime = src.Shutter;

m.Results.ElapsedTime = elapsed_time;
m.Results.TimeHeightVidStatsTable = table(time, interp_heights);
m.Results.FirstFrame = firstframe;
m.Results.LastFrame = lastframe;


save([filename, '.meta.mat'], '-STRUCT', 'm');

delete(vid);
clear vid

close(f)
logentry('Done!');

return


% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ba_pulloff: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return