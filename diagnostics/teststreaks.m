function data =  teststreaks(amp_um, f, Nseconds)
% TESTSTREAKS Test streaks on camera by moving MCL stage in circles
%
% 3DFM function  
% Diagnostics 
% last modified 11/14/08 (krisford)
%
% A stand-alone function used to test streaks on camera by moving MCL stage
% in circles. This lets us test various specifications and settings of the
% camera.
% Last modified 19 April 06 by: kvdesai
% Usage:
%   data =  teststreaks(radius_um, Hz, Nseconds)
%   Where,
%   radius_um = desired radius of circle in microns
%   Hz = Frequency of the circular motion
%   Nseconds = duration in number of seconds
AOname = 'PCI-6733';   %id = 1
AIname = 'PCI-6052E';  %id = 2
sampleRate = 10000; 
seconds = 1;
t = (0:1/sampleRate:seconds);
A = amp_um*0.1;
x = A*sin(2*pi*f*t)+5; y = A*cos(2*pi*f*t) + 5;
drive = [x',y'];
disp(['Sample rate to be used (Hz): ',num2str(sampleRate)]);
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
set(AO, 'SampleRate', sampleRate);
Ochan = addchannel(AO, 0:1); % X==0, Y==1
set(AO, 'RepeatOutput', Nseconds);
% set up the input
AI = analoginput('nidaq', AIid);
set(AI, 'InputType', 'Differential');


Ichan = addchannel(AI, 4:6); %3 stage channels: X = 4, Y = 5, Z=6(just in case) all in MCL marked coordinates

set(AI, 'SampleRate', sampleRate);
actualRate = get(AI,'SampleRate'); %
window = round(actualRate*seconds);
%For stage sensors, 1 volt converts to 10 Microns or 1 mv converts to 10 nm.
%We want to analyse noise in the order of nanometeres, or 0.1 mv
%So, we need the A/D board precision to be aprx. 50 microvolts.
%Referring to the user manual of PCI-6733, corresponding range to the
%closest precisioun (30.2 uv) is -1 to 1 volts.
set(AI.Channel, 'InputRange', [0 10]); % stage outputs must be unipolar
set(AI, 'SamplesPerTrigger', window);

%Now, put stage at three different positions and collect noise data on each
%of those positions.
% setVolts = [1, 2, 3];
putsample(AO,[5 5]); %put the stage at the center
% stage_current = getsample(AI);

disp('Stage was just told to go at the center.');
disp('If this is the first run, wait a couple of seconds and press any key to proceed');
input('If this is a re-try, then just press any key to proceed');
putdata(AO, drive);
start(AO);
start(AI);
dacIn = getdata(AI);
figure(100);
plot(drive(:,1)*10, drive(:,2)*10, '.-b', dacIn(:,1)*10, dacIn(:,2)*10, '.-r'); axis equal;
xlabel('X position [microns]');
ylabel('Y position [microns]');
legend('Commanded','Measured');

% asksave = input('See plots and press [Y] if data is to be saved OR press [N] if you want to discard this data','s');

    data.info.sampleRate = sampleRate;
    data.info.seconds = seconds;
    data.stageDrive = drive;
    data.stageSensor = dacIn(:,1:3);
% if(strncmpi(asksave,'y',1))
%         %     info = input(['Type any information you \n', ...
% %             'want to be associated with this noise scan \n',...
% %             'Press Enter only when you are done\n'],'s');
% %     
% 
%     [filename, pathname] = uiputfile('*.mat', 'Save streak data as');
%     
%     fullname = horzcat(pathname,'\',filename);
%     save(fullname,'data');
%     disp(['The noise data is saved as ', fullname]);
% else
%     disp('Data was discarded...'); 
% %     data = [];
% end
disp('Waiting for buffered drive to be complete..');
% putsample(AO,[0 0 0 0]);%Return stage to the origin DONT
wait(AO,seconds*Nseconds);
stop(AO);
stop(AI);
delete(AI);
delete(AO);
clear AI;
clear AO;
daqreset;
disp('Finished. Cleaned up! Good bye!');
