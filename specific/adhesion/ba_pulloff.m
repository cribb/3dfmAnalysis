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


cnt = 1;
starting_height = 3;
abstime{1,1} = [];
framenumber{1,1} = [];
TotalFrames = 0;
motor_velocity = 0.2; % [mm/sec]

Nsec = starting_height/motor_velocity + 1;
Fps = 1 / (exptime/1000);
NFrames = Fps * Nsec;

height = NaN(NFrames,1);
height(1,1) = starting_height;

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

% preview(vid);

% ----------------
% Controlling the Hardware and running the experiment
%

pause(2);
logentry('Starting video...');
start(vid);
pause(2);

NFramesAvailable = 0;

fid = fopen('tempvid.bin', 'w');

% set motor velocity to .2 mm/sec
h.SetVelParams(0, 0, 1, motor_velocity); 

% move from starting position in mm down to 0 mm
h.SetAbsMovePos(0, 0); 
pause(2);
logentry('Moving motor...');
h.MoveAbsolute(0, 1==0);


logentry('Triggering video collection...');
trigger(vid);

% start timer for video timestamps
t1=tic; 

% Check and store the motor position every 100 ms until it reaches zero. 
pause(1/Fps);
while(vid.FramesAvailable > 0)
    cnt = cnt + 1;
    height(cnt) = h.GetPosition_Position(0); 
    
    NFramesAvailable(cnt,1) = vid.FramesAvailable;
    [data, ~, meta] = getdata(vid, NFramesAvailable(cnt,1));    
    
    abstime{cnt,1} = vertcat(meta(:).AbsTime);
    framenumber{cnt,1} = meta(:).FrameNumber;

%     TotalFrames = TotalFrames + NFramesAvailable;   
    [rows, cols, rgb, frames] = size(data);

    datatype = class(data);
    fwrite(fid, data, datatype);
    logentry(['Wrote ' num2str(NFramesAvailable(cnt,1)) ' frames.']);
end

elapsed_time = toc(t1);

logentry('Stopping video collection...');
stop(vid);
pause(1);
% 
% NFramesAvailable = vid.FramesAvailable;
% [data, ~, meta] = getdata(vid, NFramesAvailable);    
% logentry(['Wrote ' num2str(NFramesAvailable) ' final frames.']);
%     
% TotalFrames = TotalFrames + NFramesAvailable;   
% 
% datatype = class(data);
% fwrite(fid, data, datatype);
    
% Last two numbers describe acceleration and velocity [mm/sec]
h.SetVelParams(0, 0, 4, 2); 
h.SetAbsMovePos(0, starting_height); 
h.MoveAbsolute(0, 1==0);  


fclose(fid);

height(cnt+1:end) = [];
NFramesCollected = sum(NFramesAvailable);
AbsFrameNumber = cumsum(NFramesAvailable);

logentry(['Total Frame count: ' num2str(NFramesCollected)]);

interp_heights(:,1) = interp1(AbsFrameNumber, height, 0:NFramesCollected-1);


time = cellfun(@(x)seconds(days(datenum(x))), abstime, 'UniformOutput', false);
time = vertcat(time{:});

TimeHeightTable = table(time, interp_heights);

delete(vid);
clear vid

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
     
     return;    