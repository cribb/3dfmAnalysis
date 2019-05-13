function ba_pulloff(filename, exptime)
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


% clear all
% close all
% clc
% filename='2umPSbeads_fluidtop01_4.11.19';

if nargin < 2 || isempty(exptime)
    exptime = 4;
end

% This global variable serves as a handle to the Thorlabs z-motor
global h;           

%--- Create ActiveX Controller for the ThorLabs z-motor
% This section is mostly taken from Thorlabs APT Matlab Guide, located at:
% https://www.thorlabs.com/tutorials/APTProgramming.cfm (bottom link under
% "Matlab" section). More information can be found here: 
% http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html

% The z-motor GUI gets docked into a matlab figure that's explicitly 
% constructed using the Matlab's default figure properties (i.e. figure '0').
fpos=get(0,'DefaultFigurePosition');
fpos(3)=650; % Figure width
fpos(4)= 450;% Figure height
f = figure('Position', fpos, 'Menu', 'None', 'Name', 'APT GUI');

% Initialize Control GUI for Thorlabs z-motor control
% !regsvr64 /s C:\Program Files (x86)\Thorlabs\APT\APT Server\MG17Motor.ocx
h = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
h.StartCtrl;

% The serial number for the motor is 83829797. Must set it here and
% register/identify our connection to the motor.
set(h,'HWSerialNum', 83829797);
h.Identify; 
pause(5); 


%% Set video parameters, start camera
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
vid.ReturnedColorspace = 'grayscale';
myprops.vid = propinfo(vid);

% Following code found in apps -> image acquisition
src = getselectedsource(vid); 
src.ExposureMode = 'off'; 
src.FrameRateMode = 'off';
src.ShutterMode = 'manual';
src.Gain = 10;
src.Gamma=1.15;
src.Brightness=5.8594;
src.Shutter = exptime;

triggerconfig(vid, 'manual');
vid.FramesPerTrigger = Inf;
pause(2)
start(vid);
pause(2);


% Control the Z-motor and collect the video

% Initial height of magnet
height = 12; 

% set motor velocity to .2 mm/sec
h.SetVelParams(0,0,1,.2); 

% move from 8 mm position to 0 mm
h.SetAbsMovePos(0,0); 
pause(2)
h.MoveAbsolute(0,1==0);
trigger(vid);

% Start timer
t1=tic; 

% This loop runs until motor position reaches 0
while height > 0 
    
    height=h.GetPosition_Position(0); %returns position of motor and stores in ztvector
   
    pause(.1)
    %flushdata(vid)
   
end

if height<.001
    t2=toc(t1);
    % stoppreview(vid);
    stop(vid)
    pause(1)
%     h.MoveHome(0,0); %rehome the motor, then return to the 6mm position
%     pause(10)
    h.SetVelParams(0,0,4,2); %last two numbers describe acceleration and velocity (mm/sec)
    h.SetAbsMovePos(0,12); 
    h.MoveAbsolute(0,1==0);  
end
%% Saving data
[data time meta ] = getdata(vid);
time=zeros(length(data(1,1,1,:)),1);
for k=1:length(meta)

    time(k)=seconds(days(datenum(meta(k).AbsTime)));
end
save_bin_on_nvme(data,filename)
xlswrite([filename,'.xlsx'],time');


