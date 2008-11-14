function data =  noisechar(sampleRate, seconds, channels, fit_Jacobian)
% NOISECHAR Configures input/output boards, channels, and voltage ranges
%
% 3DFM Function 
% Diagnostics
% last modified 11/14/08 (krisford) 
%  
% This function configures input/ouput boards, channels, and voltage ranges
% It does NOT configure trigger types.
%
%  data = noisechar(sampleRate, seconds, fit_Jacobian)
%   
%  where "sampleRate" is sampling_rate in [Hz]
%        "seconds"  is duration of collection in [sec] 
%        "channels" is 1 x N vector, specifying which channels do we need to scan
%            If not specified (left empty), this is [0,1,2,3,4,5,6,7] by default.                
%        "fit_Jacobian" is a flag telling if we need to fit a Jacobian
%            When selected, the QPD channels and Stage Channels should all be connected.
% 
  
dbstop if error
if nargin < 4 | isempty(fit_Jacobian)  fit_Jacobian = 0; end
if nargin < 3 | isempty(channels)  channels = [0:1:7]; end

AIname = 'PCI-6052E';  %id = 2
hwinfo = daqhwinfo('nidaq');
AIid = -1;
for i=1:length(hwinfo.BoardNames)  
  if strcmp(char(hwinfo.BoardNames(i)), AIname)
    AIid = i;
  end
end
if AIid < 0
  error('input board not found')
end

if(fit_Jacobian)
    AOname = 'PCI-6733';   %id = 1
    AOid = -1;
    for i=1:length(hwinfo.BoardNames)
        if strcmp(char(hwinfo.BoardNames(i)), AOname)
            AOid = i;
        end        
    end
    if AOid < 0
        error('Jacobian estimation was requested but output board not found')
    end
    
    stage_offset_um = 50;
    volts_per_um = 0.1;
    NoiseAmp_um = 0.05; %100 nm peak to peak
    jrate = 10000;%sample rate for jacobian estimation
    stage_offset_V = stage_offset_um*volts_per_um;
    
    % setup the output for jacobian estimation
    AOj = analogoutput('nidaq', AOid);
    Ochan = addchannel(AOj, 0:3); % X==0, Y==1, Z==2 , dummy = 3--this is correct
    %Actually we are using only 3 channels 0,1,2 but it seems that the board is
    %having some problems with configuring counters for odd no of channels
    %so fourth channel, channel# 3 is added
    set(Ochan, 'OutputRange', [-10 10]); % doesn't matter for pci-6733. unipolar range is not available
    set(AOj, 'TriggerType', 'Manual'); % 
    set(AOj,'SampleRate',jrate);
    set(AOj,'RepeatOutput',1); %collect Jacobian data for 1 second.
    % to set the stage at offset before bead is adjusted
    putsample(AOj, [stage_offset_V, stage_offset_V, stage_offset_V, 0]);
    
    % setup the input only for jacobian estimation
    AIj = analoginput('nidaq', AIid);
    addchannel(AIj, [0:1:6]); %4 QPD channels 3 stage channels
    set(AIj, 'InputType', 'Differential');
    jrate = setverify(AIj,'SampleRate',jrate);
    set(AIj.Channel, 'InputRange', [0 10]); % No signal can go negative
    set(AIj, 'TriggerType', 'Manual');    
    set(AIj, 'SamplesPerTrigger', jrate*1); % 1 second worth of data
    t = [0:1:sampleRate]*1/sampleRate;    
    
    % create the pseudo noise of desired standard deviation and mean
    px = NoiseAmp_um*sin(2*pi*89*t)'; 
    py = NoiseAmp_um*sin(2*pi*83*t)'; 
    pz = NoiseAmp_um*sin(2*pi*73*t)'; 
    posData = volts_per_um*[px py pz zeros(size(px))];
    putdata(AOj, posData); % send the data
    
    start(AOj); % ready but not triggered
    start(AIj);
    trigger(AOj);
    trigger(AIj);
    
    jacData = getdata(AIj); 
    
    jacData = jacData - repmat(mean(jacData), size(jacData,1), 1);
    jacqpd = jacData(:,1:4);
    jacstage = jacData(:,5:7);
    poly = buildpoly(jacqpd,2);
    JacQtoS = jacstage \ poly;
    % Jacobian estimate is complete. Now Clean up
    stop(AIj)  %breaks if not put in parenthesis
    delete(AIj) %warns that file AIj not found if not put in brackets
    clear AIj
    
    stop(AOj)
    delete (AOj)
    clear AOj
end
% set up the input
AI = analoginput('nidaq', AIid);
set(AI, 'InputType', 'Differential');
addchannel(AI, channels);
sampleRate = setverify(AI, 'SampleRate', sampleRate);

set(AI.Channel, 'InputRange', [-5 5]); 

set(AI, 'TriggerType', 'Manual');
N = round(sampleRate*seconds);
set(AI, 'SamplesPerTrigger', N);

start(AI); %ready but not triggered
trigger(AI);

temp = getdata(AI);

data.info.dateNtime = datestr(now,30);
data.info.sampleRate = sampleRate;
data.info.seconds = seconds;
data.info.fit_Jacobian = fit_Jacobian;
data.info.channels = channels
data.volts = temp;

if (fit_Jacobian)
    data.JacQtoS = JacQtoS;
%     data.pos = buildpoly(data.quads,2) * data.JacQtoS';
end
% npath = 'D:\Data\Noise_characterisation';
% filename = datestr(now,30);
% fullname = horzcat(npath,'\',filename);
% save(fullname,'data');
% disp(['The data file is saved as ', fullname]);

stop(AI);
delete(AI);
clear AI;

daqreset;

figure;
[p f] = mypsd(data.volts-repmat(mean(data.volts),size(data.volts,1),1),sampleRate,1);
loglog (f,p,'.-');
ylabel('Volt^2/Hz');
xlabel('Hz');
info = input(['Noise scan is done. Type any information you \n', ...
               'want to be associated with this noise scan \n',...
               'Press Enter only when you are done\n'],'s');
data.info.user_input = info;
title(data.info.user_input(1:min(end,35)));
for c = 1:length(channels)
    str_mat(c,:) = num2str(channels(c));
end
legend(str_mat,2);
pretty_plot;
set(gca,'Tag',data.info.user_input);
assignin('base','p',p);
assignin('base','f',f);
dbclear if error
%--------------------------------------------------------
function A = buildpoly(q,order) % from gb the great, and tested by me.
% q is a NxM matrix, here M = 4 for QPD
A = [ ones(size(q,1), 1) ]; % Nx1 vector all ones
nQ = ones(1, size(q,2));% 1xM vector all ones
for o = 1:order
    Ap = A; %inherit all low order terms from the last order 
    for i = 1:size(q,2) % repeat M times
        Ac = Ap(:,nQ(i):end); 
        nQ(i) = size(A,2) + 1;
        A = [ A, repmat(q(:,i),1,size(Ac,2)).*Ac ];
    end
end
