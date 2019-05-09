clear all; close all; clc;
global h; % make h a global variable so it can be used outside the main
          % function. Useful when you do event handling and sequential           
fpos=get(0,'DefaultFigurePosition');
fpos(3)=650; % Figure width
fpos(4)= 450;% Figure height
f = figure('Position', fpos,'Menu','None','Name','APT GUI'); %Initialize GUI for motor control
%% Create ActiveX Controller
% !regsvr64 /s C:\Program Files (x86)\Thorlabs\APT\APT Server\MG17Motor.ocx
h = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
h.StartCtrl;
SN = 83829797; %Set Serial number
set(h,'HWSerialNum', SN);
h.Identify; 
pause(5); 
%% Start camera
vid = videoinput('pointgrey', 1,'F7_Raw16_1024x768_Mode2');
% propinfo(vid)
src = getselectedsource(vid); % Following code found in apps -> image acquisition
src.ExposureMode = 'auto'; 
src.FrameRate = 60;
src.Gain = 10;
src.Gamma=1.15;
src.Brightness=5.8594;
src.Shutter = 16;
vid.ReturnedColorspace = 'grayscale';
trigconf = triggerconfig(vid);
triggerconfig(vid, 'manual');
vid.FramesPerTrigger = Inf;
% preview(vid);
pause(.2)
%% Controlling the Hardware

ztvector=zeros(2,300); %Initialize vector for height and time at each frame
imgstack=uint16(zeros(768,1024,300));
height=0;
i=1;
stepsize=.001; %method for jogging instead of continuous motion
h.SetJogStepSize(0,stepsize);
h.SetJogVelParams(0,1,5,2);
max_intensity = NaN(300,1);
for i=1:300%loop occurs until motor position reaches 0
    [pic, data]=getsnapshot(vid); %take snapshot and save image matrix into imgstack
    max_intensity(i,1) = max(pic(:));
    fprintf('pos = %i, max_intensity = %i \n', i, max_intensity(i,1));
    imgstack(:,:,i)=pic;
    height=h.GetPosition_Position(0); %returns position of motor and stores in ztvector
    ztvector(1,i)=height;
    h.MoveJog(0,1); %1 raises magnet, 2 lowers magnet
    pause(1);
    i=i+1;
end
%% Saving data
outputFileName = '4.23.19_Zstack_psf2.tif';
for K=1:length(ztvector)
   imwrite(imgstack(:, :, K), outputFileName, 'WriteMode', 'append');
end
xlswrite('5_25_zstack3_mucus_501x502.xlsx',ztvector')
