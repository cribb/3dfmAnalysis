% Driven rheology
% 
% This matlab script will construct and save a .mat file that contains the
% input signals used to drive the magnets during a history dependence
% experiment.

% HARDWARE.  setup constants that describe the physical hardware used 
% to drive the experiment.  Variables in this section define the number 
% of coils in the 3dfm pole geometry, the number of DAQ Analog-Out 
% channels on the DAQ board, the identity of the DAQ board, etc...

% DAQid = 'daqtest';
DAQid = 'PCI-6733';
nDACout = 3;
DAQ_sampling_rate = 1000;  % [Hz]
amplitude_oscillation = 10;  % microns
microns_per_volt = 10;
test_frequency = 1;
start_time = 0;
end_time = 10;
xyoffset = 5;
Nrepeat = 0;
channels = [0:nDACout-1]';
Vrange = [-10 10];

% initialize stage to known position
x = 5;
y = 5;
z = 10;
zerodaq([x y z 0 0 0 0 0]);

% input('Adjust stage to the starting z-plane and press <ENTER>.');

% INITIAL MATH:  precondition the output matrix to all zeros and define the
% time vector that will give normal mortals an idea of what's going on.
t = [start_time : 1/DAQ_sampling_rate : end_time - 1/DAQ_sampling_rate]';
x = amplitude_oscillation / microns_per_volt * cos(2 * pi * test_frequency * t) + xyoffset;
y = zeros(size(x)) + xyoffset;

% SET UP z-STEPS 
z_steps_um = [100:-10:0];
step_times = [0:5:end_time];
z_steps_volts = z_steps_um / microns_per_volt;

% SETUP z-steps OUTPUT MATRIX:  This section defines the output matrix that will be
% sent to DAQ board according to the experimental details defined above.
z = zeros(size(t));
for k = 1 : length(z_steps_um)-1
	idx = find(t >= step_times(k) & t < step_times(k+1));
	z(idx) = z_steps_volts(k);
end

% initialize signal
signal = [x y z];

% Start experiment.  Call DACoperator. Call pulnix software. etc..
DACoperator(signal, Nrepeat, DAQid, channels, DAQ_sampling_rate, Vrange);

pause(end_time);
zerodaq([5 5 10 0 0 0 0 0]);