function data =  noisechar(seconds, drive, range)
% A stand-alone function used to test the noise on MCL stage sensor outputs
% Last modified by: kvdesai
% Usage:
%   data =  noisechar(seconds, drive, range)
%   Where,
%   seconds = desired duration of the data acquisition
%   drive = a 1x3 vector specifying the constant voltage that is to be put
%            on [x y z] channels of the stage
%   range = a number specifying bipolar range of the analog input board (ADC). 
%           e.g. providing 5 = range, sets the range to be -5 to +5 volts.
%           Reducing the range increases the resolution of ADC board.
%           However, 'drive' signals should be within this range.  

AOname = 'PCI-6733';   %id = 1
AIname = 'PCI-6052E';  %id = 2
sampleRate = 1000000/104; %SEE BELOW FOR THE JUSTIFICATION OF THIS MAGIC NUMBER
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
Ochan = addchannel(AO, 0:3); % X==0, Y==1, Z==2 , dummy = 3-- added to make the clock happy
%Actually we are using only 3 channels 0,1,2 but it seems that the board is
%having some problems with configuring counters for odd no of channels
%so fourth channel, channel# 3 is added
% set(Ochan, 'OutputRange', [0 10]); % doesn't matter for pci-6733. unipolar range is not available

% set up the input
AI = analoginput('nidaq', AIid);
set(AI, 'InputType', 'Differential');

% VARIES FROM HERCULES TO BETTY
Ichan = addchannel(AI, 4:6); %3 stage channels: X = 4, Y = 5, Z = 6, all in MCL marked coordinates

set(AI, 'SampleRate', sampleRate);
actualRate = get(AI,'SampleRate'); %Useless! this is always giving the same value as SampleRate
window = round(actualRate*seconds); %though dosen't hurt, so leaving it in.
%For stage sensors, 1 volt converts to 10 Microns or 1 mv converts to 10 nm.
%We want to analyse noise in the order of nanometeres, or 0.1 mv
%So, we need the A/D board precision to be aprx. 50 microvolts.
%Referring to the user manual of PCI-6733, corresponding range to the
%closest precisioun (30.2 uv) is -1 to 1 volts.
set(AI.Channel, 'InputRange', [-range, + range]); % stage outputs must be unipolar
set(AI, 'SamplesPerTrigger', window);

%Now, put stage at three different positions and collect noise data on each
%of those positions.
% setVolts = [1, 2, 3];

putsample(AO,[drive ,0]);
start(AI);
dacIn.d = getdata(AI);

% Now plot the PSDs of the data just aquired and ask user if this data is
% good to be saved.
for j = 1:3
    %subtract the mean out and convert into nanometers from volts
    temp.d(:,j) = 10000*(dacIn(end).d(:,j));
end
[px idx fx] = noisepsd(temp.d(:,1),sampleRate,1);
[py idy fy] = noisepsd(temp.d(:,2),sampleRate,1);
[pz idz fz] = noisepsd(temp.d(:,3),sampleRate,1);

figure(100);
semilogx(fx,px,'.b-',fy,py,'.g-',fz,pz,'.r-');
xlabel('Hz');
ylabel('Nanometers^2/Hz');
title('Power Spectrum Density');
legend('X axis', 'Y axis', 'Z axis');
grid on
figure(101);
semilogx(fx,idx,'.b',fy,idy,'.g',fz,idz,'.r');
xlabel('Hz');
ylabel('Nanometers');
title('Cumulative displacement');
legend('X axis', 'Y axis', 'Z axis');
grid on
asksave = input('See plots and press [Y] if data is to be saved OR press [N] if you want to discard this data','s');

if(strncmpi(asksave,'y',1))
        
    info = input(['Type any information you \n', ...
            'want to be associated with this noise scan \n',...
            'Press Enter only when you are done\n'],'s');
    
    data.info.user_input = info;
    data.info.dateNtime = datestr(now,30);
    data.info.sampleRate = sampleRate;
    data.info.seconds = seconds;
    data.info.setVolts = setVolts;
    % data.info.driveStage = drive_stage;
    % data.quads = temp(:,1:4);
    data.stageSensor = dacIn(end).d(:,1:3);
%     data.set1.stageSensor = dacIn(1).d(:,1:3);
%     data.set2.stageSensor = dacIn(2).d(:,1:3);
%     data.set3.stageSensor = dacIn(3).d(:,1:3);
    % data.sum(:,1) = data.quads(:,1) + data.quads(:,2) + data.quads(:,3) + data.quads(:,4);
    [filename, pathname] = uiputfile('*.mat', 'Save noise data as');
    
    fullname = horzcat(pathname,'\',filename);
    save(fullname,'data');
    disp(['The noise data is saved as ', fullname]);
else
    disp('Data was discarded...');
    data = [];
end
putsample(AO,[0 0 0 0]);%Return stage to the origin
stop(AO);
stop(AI);
delete(AI);
delete(AO);
clear AI;
clear AO;
daqreset;
disp('Finished cleaning up! Good bye!');
%From the visual C++ program - Laser Tracker (which has access
%to board parameter configuration that is deeper (lower level) than matlab has), 
%we know that when we ask board to provide sample rate of 10 KHz on 8
%channels, it actually gives rate of 9615 Hz per channel. 
%This is calculated from the raw numbers provided from the board as below.
%
%Board PCI-6052E operates in multiplexing mode, meaning that if multiple channels are
% configured to be scanned, then they will be sampled successively and not simultaneously. 
%For the discussion below, Sample Interval is the time between sampling of
%successive channels in one scan-sequence. Scan Interval is time
%between completion of one scan-sequence and start of the next scan-sequence
% Board gives:
%"Sample Time Base" = 1 
%   -> which corresponds to the clock frequency used for sample interval-> 1 MHz = 1 us resolution 
%"Sample Interval" = 13 -> 13 us sample inverval
%"Scan Time Base" = 1 -> 1 us resolution clock used for calculating scan-interval
%"Scan Interval" = 0  -> No delay between successive scan-sequences
%
%These numbers give total time for execution of one scan sequence with 8 channels as
%T = Nchannel*SampleInterval + ScanInterval = 8*13 + 0 = 104 microseconds
%This is the same as time between successive sampling of the same channel.
%So samle rate per channel = 1/T = 9615.38 Hz.
%
%It is surprising that when we ask board to give 10KHz sample rate through
%matlab, the matlab gives the data actually at 10 KHz rate, instead of 9615 Hz
%So matlab is either processing (interpolating etc) the raw data OR it is
%sampling the data at next higher sample rate (that is available from
%board) than the requested, and then just picks the data points separated
%at the interval corresponding to requested sampleRate.
%
%If we ask for the same sample rate that we know board can provide, then we
%are sure that matlab is not doing any processing with that raw data. So,
%we must use 9615 as our sample rate.
%
%Also, if the desired sampling rate is anything other than 10000 (for e.g. 20000), the magic
%number 9615 should be replaced by a new number, which can be calculated by
%hand or, can be found using VC++ program.

function [p, Id, f] = noisepsd(s,rate,res)
% s is a column vector containing samples
nw = fix(rate/(2*res))*2;
win = zeros(nw,1);
win = blackman(nw);

% switch window_type
% 	case 'blackman'
% 		win = blackman(nw);
% 	case 'rectangle'
% 		win = ones(nw,1);
% end
% 	
s = s - mean(s); %subtract out the mean
    % [Pxx,f]=pwelch(X, WINDOW,NOVERLAP,NFFT)
    % [p, f] = pwelch(s(:,1), blackman(nw), nw/2, nw, rate);  %original gbcode
    [p(:,1) f] = pwelch(s(:,1), win, nw/2, nw, rate);          %jac-hack
    Id(1,1) = sqrt(p(1,1)*f(1));
    for j = 2:length(p(:,1))
        Id(j,1) = sqrt(Id(j-1,1)^2 + p(j,1)*(f(j)-f(j-1)));%discrete integration
    end



