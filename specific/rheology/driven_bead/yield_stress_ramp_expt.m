% Driven rheology
% 
% This matlab script will construct and save a .mat file that contains the
% input signals used to drive the magnets during a history dependence
% experiment.

% HARDWARE.  setup constants that describe the physical hardware used 
% to drive the experiment.  Variables in this section define the number 
% of coils in the 3dfm pole geometry, the number of DAQ Analog-Out 
% channels on the DAQ board, the identity of the DAQ board, etc...
DAQid = '';
nDACout = 8;
nCoils = 6;
DAQ_sampling_rate = 1000;  % [Hz]

% EXPERIMENTAL DESIGN:  setup constants that describe experimental design.  
% Variables in this section define the start and end times of the
% experiment, and any "crucial points" that define a change of state in the
% experiment's progression.  The pole geometry used is also defined here.
pole_geometry = 'pole4-flat';
ramp_start_voltage = 0;
ramp_rate = 0.5;  % volts per second
start_time = 0;
times_to_activate_ramps = [10 40];
times_to_deactivate_ramps = [20 50];
end_time = 70;

% INITIAL MATH:  precondition the output matrix to all zeros and define the
% time vector that will give normal mortals an idea of what's going on.
end_time = end_time - 1/DAQ_sampling_rate;
ramp_rate = ramp_rate / DAQ_sampling_rate;
t = [start_time : 1/DAQ_sampling_rate : end_time]';
signal = zeros(length(t), nDACout);

% Define which poles are going to be excited and in what way.
switch pole_geometry
    case 'pole4-flat'
        poles_to_excite_pos = 4;
        poles_to_excite_neg = [1 2 6];
    case 'pole1-flat'
        poles_to_excite_pos = 1;
        poles_to_excite_neg = [3 4 5];
    otherwise
        error(['Pole geometry ' pole_geometry ' not recognized.']);
end


% SETUP OUTPUT MATRIX:  This section defines the output matrix that will be
% sent to DAQ board according to the experimental details defined above.
for k = 1 : length(times_to_activate_ramps)   
	idx = find(t > times_to_activate_ramps(k) & t < times_to_deactivate_ramps(k));
    ramp_vector = cumsum(ramp_rate * ones(length(idx),1));
    signal(idx, poles_to_excite_pos) = repmat(ramp_vector, 1, length(poles_to_excite_pos));
	signal(idx, poles_to_excite_neg) = repmat(-ramp_vector / length(poles_to_excite_neg), 1, length(poles_to_excite_neg));
end

% Plot test output, for inspection before beginning experiment.
for k = 1:nCoils
    figure(1);
    subplot(nCoils,1,k);
    plot(t, signal(:,k), '.');
    title(['Coil ' num2str(k)]);
    ylabel('Voltage');
    axis([start_time end_time -5 5]);

    if k == nCoils
        xlabel('time (s)');
    end
end


% Start experiment.  Call DACoperator. Call pulnix software. etc..