function smsd = sim_msd(numpaths, viscosity, bead_radius, sampling_rate, duration, temp, dim, window, make_plot)
% SIM_MSD computes the mean square displacements of an aggregate number of beads in a simulated Newtonian fluid for a temperature in K 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%
% This function computes the mean square displacements of an aggregate number of beads 
% in a simulated Newtonian fluid for a temperature in Kelvin and allows for the option
% of plotting MSD vs. window size (tau).
%
% [smsd] = sim_msd(numpaths, viscosity, bead_radius, sampling_rate, duration, temp, dim, window, make_plot)
%
% where "numpaths" is the number of beads in the fluid
%       "viscosity" is in [Pa sec]
%       "bead_radius" is in [m] 
%		"sampling_rate" is in [Hz] 
%       "duration" is in [s]
%       "temp" is in [K]
%       "dim" is the dimension of diffusion (usually 1D, 2D, 3D)
%       "window" is a vector containing window sizes of tau when computing MSD. 
%       "make_plot" gives the option of producing a plot of MSD versus tau.
%
% Notes: - For results that truly approximate the bulk response of the material,
%          you need lots of repeats and averaging.
%        - Use empty matrices to substitute default values.
%        - default viscosity = 0.00086 Pa sec
%        - default bead radius = 0.5e-6 m
%        - default sampling_rate = 120 Hz
%        - default duration = 10 sec
%        - default temp = 298 K
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%        - default make_plot = yes
%


% initializing arguments
if (nargin < 1) || isempty(numpaths) numpaths = 50; end;
if (nargin < 2) || isempty(viscosity) viscosity = 0.00086; end;
if (nargin < 3) || isempty(bead_radius) bead_radius = 0.5e-6; end;
if (nargin < 4) || isempty(sampling_rate)  sampling_rate = 120; end;
if (nargin < 5) || isempty(duration)  duration = 10; end;
if (nargin < 6) || isempty(temp) temp= 298; end;
if (nargin < 7) || isempty(dim) dim = 2; end;
if (nargin < 8) || isempty(window)  window = [1 2 5 10 20 50 100 200 500 1000 1001];  end;


t = [0 : 1/sampling_rate : duration - (1/sampling_rate)];

% for every bead
for k = 1 : numpaths;
    
    this_duration = ceil(duration) * abs(randn)/2;
    sim_disp = sim_newt_fluid(viscosity, bead_radius, sampling_rate, this_duration, temp, dim, 1);
    
    % call up the MSD program to compute the MSD for each bead
    [tau(:, k), mymsd(:, k)] = msd(t, sim_disp, window);

end;

% trim the data by removing window sizes that returned no data
sample_count = sum(~isnan(mymsd),2);
idx = find(sample_count > 0);
tau = tau(idx,:);
mymsd = mymsd(idx,:);
sample_count = sample_count(idx);

% output structure
smsd.tau = tau;
smsd.msd = mymsd;
smsd.n = sample_count;

% creation of the plot MSD vs. tau
if (nargin < 9) | isempty(make_plot) | findstr(make_plot,'y')  plot_msd(smsd); end;


