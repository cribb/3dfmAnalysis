function new_program = condition_waveform(program, duration, mcl_sampling_rate);
% 3DFM function  
% Diagnostics 
% last modified 05/07/04 
%  
% This function conditions an input waveform, upsampling it to the
% desired sampling rate, and generating the proper number of repeats to
% satisfy the duration parameter.
%  
%  [new_program] = condition_waveform(program, duration, mcl_sampling_rate);  
%   
%  where "program" is [time,disp] matrix to be conditioned
%        "duration" is the desired end-time for the output waveform in [sec]
%        "mcl_sampling_rate" is desired Mad City Labs sampling rate
%  
%  Notes:  
%   
%   
%  12/02/03 - created; jcribb
%  05/07/04 - added documentation; jcribb
%   
%  


% mcl_sampling_rate = 200; % Hz
% program = [ 0 0 ; 1 0 ; 1.995 0 ; 2 1 ; 3 1 ; 3.995 1 ; 4 0];  % t(sec) d(um)
% duration = 10; % sec

[rows cols] = size(program);

program_rate       = (program(end, 1) - program(1,1)) / rows;
num_of_repeats     = duration / program(end,1);
num_of_data_points = mcl_sampling_rate * num_of_repeats;
mcl_period         = 1/mcl_sampling_rate;

new_times          = [0 : mcl_period : program(end,1)-mcl_period]';

if (program_rate < mcl_sampling_rate)
    new_displacements = interp1(program(:,1), program(:,2), new_times);
elseif (program_rate > mcl_sampling_rate)
    new_displacements = 0;
end


new_program = [new_times new_displacements];


