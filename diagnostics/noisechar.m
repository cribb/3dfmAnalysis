function data =  noisechar(sampleRate, seconds, drive_stage)
% 3DFM function  
% Diagnostics 
% last modified 05/07/04 
%  
% This function configures input/ouput boards, channels, and voltage ranges
% It does NOT configure trigger types.
%
%  data = noisechar(sampleRate, seconds, drive_stage)
%   
%  where "sampleRate" is sampling_rate in [Hz]
%        "seconds"  is duration of collection in [sec] 
%        "drive_stage" is string containing stage_name
%
%  Notes:  
%   
%   
%  ??/??/02 - created;
%  05/07/04 - added documentation; jcribb  
%   
%  





%VARIES FROM HERCULES TO BETTY
AOname = 'PCI-6733';   %id = 1
AIname = 'PCI-6052E';  %id = 2

if nargin < 3
    drive_stage = 0;
end

% find the board ids that go with the names
hwinfo = daqhwinfo('nidaq');
AOid = -1;
AIid = -1;
for i=1:length(hwinfo.BoardNames)
  if strcmp(char(hwinfo.BoardNames(i)), AOname)
    AOid = i;
  end
  if strcmp(char(hwinfo.BoardNames(i)), AIname)
    AIid = i;
  end
end
if AOid < 0
  error('output board not found')
end
if AIid < 0
  error('input board not found')
end

% setup the output
AO = analogoutput('nidaq', AOid);
Ochan = addchannel(AO, 0:3); % X==0, Y==1, Z==2 , dummy = 3--this is correct
%Actually we are using only 3 channels 0,1,2 but it seems that the board is
%having some problems with configuring counters for odd no of channels
%so fourth channel, channel# 3 is added
set(Ochan, 'OutputRange', [0 10]); % doesn't matter for pci-6733. unipolar range is not available

if(drive_stage)
    % to set the stage at offset before bead is adjusted
    N = round(sampleRate * seconds);
    set(AO,'SampleRate',sampleRate);
    set(AO,'RepeatOutput',seconds);

    % create the pseudo noise of desired standard deviation and mean
    px = 0.002*sin(70*pi*(1:sampleRate)/sampleRate); %35 Hz drive on X
    py = 0.002*sin(50*pi*(1:sampleRate)/sampleRate); %25 Hz drive on Y
    pz = 0.002*sin(20*pi*(1:sampleRate)/sampleRate); %10 Hz drive on Z
    posData = [px' py' pz' zeros(sampleRate,1)];
    putdata(AO, posData); % send the data
    start(AO); % ready but not triggered
end

% set up the input
AI = analoginput('nidaq', AIid);
set(AI, 'InputType', 'Differential');

% VARIES FROM HERCULES TO BETTY
Ichan = addchannel(AI, 0:6); % 4 QPD channels + 3 stage channels
%Ichan = addchannel(AI, 7);
%---
set(AI, 'SampleRate', sampleRate);
actualRate = get(AI,'SampleRate');
window = round(actualRate*seconds);
set(AI.Channel, 'InputRange', [-10 10]); % what should this be
set(AI, 'SamplesPerTrigger', window);
start(AI);

temp = getdata(AI);

info = input(['Noise scan is done. Type any information you \n', ...
               'want to be associated with this noise scan \n',...
               'Press Enter only when you are done\n'],'s');
data.info.user_input = info;
data.info.dateNtime = datestr(now,30);
data.info.sampleRate = sampleRate;
data.info.seconds = seconds;
data.info.driveStage = drive_stage;
data.quads = temp(:,1:4);
data.stage = temp(:,5:7);
data.sum(:,1) = data.quads(:,1) + data.quads(:,2) + data.quads(:,3) + data.quads(:,4);

npath = 'D:\Data\Noise_characterisation';
filename = datestr(now,30);
fullname = horzcat(npath,'\',filename);
save(fullname,'data');
disp(['The data file is saved as ', fullname]);
stop(AO);
stop(AI);
delete(AI);
delete(AO);
clear AI;
clear AO;
daqreset;
