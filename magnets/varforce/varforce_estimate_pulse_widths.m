function v = estimate_varforce_pulse_widths(voltages, viscosity, bead_radius, temp, maxforce, maxdist, noisefloor, snr)
% ESTIMATE_VARFORCE_PULSE_WIDTHS "needs description"
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%
%  <<not implemented yet>>
%
% estimate_varforce_pulse_widths 
%
%    v = estimate_varforce_pulse_widths(voltages, viscosity, bead_radius, temp, maxforce, maxdist, noisefloor, snr)v = varforce_run(analysis_params);
% 


% handle argument list
if nargin < 8 | isempty(snr); snr = 3; end;
if nargin < 7 | isempty(noisefloor); noisefloor = 16e-9; end;
if nargin < 6 | isempty(maxdist); maxdist = 35e-6; end;
if nargin < 5 | isempty(maxforce); maxforce = 800e-12; end;
if nargin < 4 | isempty(temp); temp = 298; end;
if nargin < 3 | isempty(bead_radius); bead_radius = 0.5e-6; end;
if nargin < 2 | isempty(viscosity); viscosity = 0.023; end;
if nargin < 1 | isempty(voltages); voltages = [0 1 2 3 4 5]; end;

tstep = 1/120;

% start churning through the math
const_boltzmann = 1.38e-23;
drag = 6 * pi * viscosity * bead_radius;

D = (const_boltzmann * temp) / drag;
x_noise = sqrt(4*D*tstep) % this is a signal-to-noise ratio of 1

min_force = maxforce / ((maxdist/noisefloor)^1);
min_dist = drag * min_force %% where is time here?????
% assume force is linear with voltage/current


v = min_force;
