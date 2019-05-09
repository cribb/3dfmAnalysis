function ba_collect_psf(outputFileName, exptime)

% Make h a global variable so it can be used outside the main
% function. Useful when you do event handling and sequential           
global h; 

% Initialize GUI for motor control
fpos=get(0,'DefaultFigurePosition');
fpos(3)=650; % Figure width
fpos(4)= 450;% Figure height
f = figure('Position', fpos,'Menu','None','Name','APT GUI');

% Create ActiveX Controller
% !regsvr64 /s C:\Program Files (x86)\Thorlabs\APT\APT Server\MG17Motor.ocx
h = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
h.StartCtrl;
SN = 83829797; %Set Serial number
set(h,'HWSerialNum', SN);
h.Identify; 
pause(5); 

% Start camera
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
vid.ReturnedColorspace = 'grayscale';

myprops.vid = propinfo(vid)

% Following code found in apps -> image acquisition
src = getselectedsource(vid); 
src.ExposureMode = 'off'; 
src.FrameRateMode = 'off';
src.ShutterMode = 'manual';
% src.FrameRate = 60;
src.Gain = 10;
src.Gamma=1.15;
src.Brightness=5.8594;
pause(0.1);


% myprops.shutter = propinfo(src,'Shutter')
pause(0.1);

src.Shutter = exptime;

myprops.shutterpost = propinfo(src,'Shutter')
trigconf = triggerconfig(vid)
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = Inf;
% preview(vid);
pause(.2)

% Controlling the Hardware

% Initialize vector for height and time at each frame
nSteps = 300;
stepsize = 0.001; % [mm]
ztvector = zeros(nSteps,2); 
imgstack = uint16(zeros(768,1024,nSteps));
height = 0;

% Set method/mode for jogging instead of continuous motion
h.SetJogStepSize(0,stepsize);
h.SetJogVelParams(0,1,5,2);
max_intensity = NaN(300,1);

% Loop occurs until motor position reaches 0
for i = 1:nSteps
    %take snapshot and save image matrix into imgstack
    [pic, data]=getsnapshot(vid); 
    
    max_intensity(i,1) = max(pic(:));
    fprintf('pos = %i, max_intensity = %i \n', i, max_intensity(i,1));
    imgstack(:,:,i) = pic;
    
    % Get position of motor and store in ztvector
    height = h.GetPosition_Position(0); 
    ztvector(i,1) = height;
       
    % Jog the position of the motor by one step (up)
    h.MoveJog(0,1); %1 raises magnet, 2 lowers magnet    
    pause(1);
    
    % Saving data as a TIF stack 
    imwrite(imgstack(:, :, i), outputFileName, 'WriteMode', 'append');

end
xlswrite([outputFileName '.xlsx'],ztvector)



