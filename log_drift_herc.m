function log_drift(adc_collectSeconds, adc_sampleRate)
% Collect and log QPD and photodetector data for some number of seconds
% at some rate (samples per second). Saves data in a file w/ the date
% and time in the file name.
%
% Usage: log_drift(adc_collectSeconds, adc_sampleRate)
% log_drift(600, 100)
cd d:\data\log_drift

fprintf(1,'Collecting %g minutes of data at %g samples/second...\n',adc_collectSeconds/60,adc_sampleRate);
adc_samples = round(adc_collectSeconds * adc_sampleRate); % amt of time = 30 min
adc_channels = [0:4];

ai=analoginput('nidaq',2);
addchannel(ai,adc_channels);
set(ai,'SampleRate',adc_sampleRate); % freq
set(ai,'SamplesPerTrigger',adc_samples);      
ai.Channel.InputRange = [-10.0 10.0];

start(ai);
[z_intensity,d.t] = getdata(ai);

d.run_time=ai.SamplesPerTrigger/ai.SampleRate;

%get QPD data
d.q0 = z_intensity(:,1);              
d.q1 = z_intensity(:,2);
d.q2 = z_intensity(:,3);
d.q3 = z_intensity(:,4);

% terminated (grounded) BNC 
%d.null = z_intensity(:,5);

% get intensity from photodetector
%d.p = z_intensity(:,6);

% write data to mat file
d.fname = sprintf('QPD_laser_data_%ss_%s.mat',num2str(d.run_time),datestr(now));
d.fname = strrep(d.fname,' ','_');
d.fname = strrep(d.fname,':','');
save(d.fname,'d');
fprintf(1,'Data saved in file %s\n',d.fname);

%analyze_QPD_null_laser_fct(d);

beep