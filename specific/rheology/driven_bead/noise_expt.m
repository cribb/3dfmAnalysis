% function v = shear_wave_MCL_controller(amplitude, freq, vel, testtype)
% v = shear_wave_MCL_controller(amplitude, freq, vel, testtype)
% testtype = 'vel' or 'freq'.. put in '[]' for parameters that are not relevant
% for the testtype you want.

% Driven rheology
% 
% This matlab script will construct and save a .mat file that contains the
% input signals used to drive the magnets during a history dependence
% experiment.

% HARDWARE.  setup constants that describe the physical hardware used 
% to drive the experiment.  Variables in this section define the number 
% of coils in the 3dfm pole geometry, the number of DAQ Analog-Out 
% channels on the DAQ board, the identity of the DAQ board, etc...
% tic

% daq constants
% DAQid = 'daqtest';
DAQid = 'PCI-6733';
nDACout = 3;
DAQ_sampling_rate = 10000;  % [Hz]
Nrepeat = 0;
channels = [0:nDACout-1]';
Vrange = [-10 10];

% stage constants
microns_per_volt = 10;
offset_volts = 5;
offset_microns = offset_volts * microns_per_volt;
% x0 = xyzoffset_microns;
% y0 = xyzoffset_microns;
% z0 = xyzoffset_microns;

% time constants
% test_frequency = freq;
start_time = 0;
end_time = 30;

% function (signal) constants
amplitude_in_microns = 10;  % microns
amplitude_in_volts   = amplitude_in_microns / microns_per_volt;
f = 2;
tau = 5;
phi = 0;

% INITIAL MATH:  precondition the output matrix to all zeros and define the
% time vector that will give normal mortals an idea of what's going on.
t = [start_time : 1/DAQ_sampling_rate : end_time - 1/DAQ_sampling_rate]';
x = amplitude_in_volts * exp(-t/tau) .* sin(2*pi*f*t + phi) + offset_volts;
y = zeros(size(x)) + offset_volts;
z = zeros(size(x)) + offset_volts;

% initialize signal
signal = [x y z];

% initialize stage to center
zerodaq([offset_volts offset_volts offset_volts 0 0 0 0 0]);

% Start experiment.  Call DACoperator. Call pulnix software. etc..
DACoperator(signal, Nrepeat, DAQid, channels, DAQ_sampling_rate, Vrange);

pause(end_time+0.5);

zerodaq([offset_volts offset_volts offset_volts 0 0 0 0 0]);

% daqreset;

v = 0;
