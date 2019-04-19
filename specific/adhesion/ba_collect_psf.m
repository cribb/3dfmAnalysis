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
vid = videoinput('qimaging', 1, 'MONO8_502x501'); % Connect to QImage camera
src = getselectedsource(vid); % Following code found in apps -> image acquisition
src.Exposure = .015; 
src.NormalizedGain = 1.3;
vid.ReturnedColorspace = 'grayscale';
triggerconfig(vid, 'immediate');
vid.FramesPerTrigger = Inf;
preview(vid);
pause(.2)
%% Controlling the Hardware
ztvector=zeros(2,300); %Initialize vector for height and time at each frame
imgstack=uint8(zeros(501,502,300));
height=0;
i=1;
stepsize=.001; %method for jogging instead of continuous motion
h.SetJogStepSize(0,stepsize);
h.SetJogVelParams(0,1,5,2);
for i=1:300%loop occurs until motor position reaches 0
    [pic, data]=getsnapshot(vid); %take snapshot and save image matrix into imgstack
    imgstack(:,:,i)=pic;
    height=h.GetPosition_Position(0); %returns position of motor and stores in ztvector
    ztvector(1,i)=height;
    h.MoveJog(0,1); %1 raises magnet, 2 lowers magnet
    pause(1);
    i=i+1;
end
%% Saving data
outputFileName = '5_25_zstack3_mucus_501x502.tif';
for K=1:length(ztvector)
   imwrite(imgstack(:, :, K), outputFileName, 'WriteMode', 'append');
end
xlswrite('5_25_zstack3_mucus_501x502.xlsx',ztvector')
