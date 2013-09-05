function out = confined_diffusion (viscosity, bead_radius, sampling_rate, duration, tempK, N_DIM, N_PARTICLES, rad_confined)

% MSD Simulator function
% yingzhou/desktop/MSD Bayes/Functions
% last modified 08/19/13 (yingzhou)
%
%CONFINED_DIFFUSION simulates a confined bead diffusion experiment for a bead with a confinement radius 'r' with the bead trapped in an infinite potential well.
%% This function outputs the stochastic displacement over time for a bead in
% an infinite potential trap for a temperature in Kelvin. The viscosity of the fluid, 
% the radius of the bead, the sampling_rate, and the duration of the data 
% collection are all needed for the approximation. 
%  
%
% SPACE_UNITS = 'm';     %units of space in 2-dimensions
% TIME_UNITS = 's';       %units of time
%  
%  [displacement] = sim_newt_fluid(viscosity, bead_radius, sampling_rate,
%                                  duration, temp, dim, numpaths, seed);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] (equivalent to frames per second) 
%        "duration" is in [s]
%        "tempK" is in [K]
%        "N_DIM" is the dimension of diffusion (usually 1D, 2D, 3D)
%        "N_PARTICLES" is the number of discrete particle paths you wish to
%        model
%        "rad_confined" is the radius of confinement in [m]
%  Notes:  
%   
       
N_TIME_STEPS = sampling_rate*duration;
SIZE = 1e-4; %m

k  = 1.3806e-23;
kT = k*tempK; %kBoltzman x T @ 300K
D  = kT/(6*pi*viscosity*bead_radius); %m^2/s (diffusion coefficient?)

dT = 1/sampling_rate; % s short frame interval - important for later (time interval)

p = sqrt(N_DIM * D * dT);

% Particle in a potential: settings the 'stiffness' of the energy potential
% Typical diameter of the trap (still in microns)

Ltrap = rad_confined*2; % µm
Ktrap = kT / Ltrap^2; % = thermal energy / trap size ^ 2

tracks = cell(N_PARTICLES, 1);

out = [];

for i_spot = 1 : N_PARTICLES

    % Time
    time = (0 : N_TIME_STEPS-1)' * dT;

    % Initial position-randomizes the offsets of the inital bead positions
    X0 = SIZE .* rand(1, N_DIM);

    % Energy potential:
    V = @(x) 0.5 * Ktrap * sum (x .^ 2); % Unused, just to show
    Fx = @(x) - Ktrap * (x - X0); % Is a vector
    
    % Position
    X = zeros(N_TIME_STEPS, N_DIM);

    % Init first step
    X(1, :) = X0;

    % Iterate
    for j = 2 : N_TIME_STEPS

        dxtrap = D/kT * Fx(X(j-1,:)) * dT; % ad hoc displacement
        dxbrownian = p * randn(1, N_DIM);

        X(j,:) = X(j-1,:) + dxtrap + dxbrownian;

    end
    
    
    X0 = repmat(X0, N_TIME_STEPS, 1); 
    
    X(:,:) = X(:,:)- X0;  %subtracts the randomized offsets from all displacement values so that the position at time=0 is (0,0)
    
%     % Stores the time and x, y displacements
%     tracks{i_spot} = [time X];

    out(:, :, i_spot) = [X]; %creates a 3-D matrix of x,y displacements for each bead ID
end


% 
% ma = msdanalyzer(N_DIM, 'µm', 's');
% ma = ma.addAll(tracks);
% 
% Plot trajectories
% [hps, ha] = ma.plotTracks;
% ma.labelPlotTracks(ha);

%save file to a format compatible with evt_GUI
% video_tracking_constants;
% 
% d = zeros(size(tracks,1)*length(tracks{1}), 9);
% 
% for i=1:size(tracks,1)
%     temp1 = tracks{i,1};
%     
%     d((i-1)*N_TIME_STEPS+1:N_TIME_STEPS*i,FRAME)=1:N_TIME_STEPS;  
%     d((i-1)*N_TIME_STEPS+1:N_TIME_STEPS*i,ID)=i;                     %inserts unique ID number for each tracker
%     d((i-1)*N_TIME_STEPS+1:N_TIME_STEPS*i,TIME)= time;
%     d((i-1)*N_TIME_STEPS+1:N_TIME_STEPS*i, X) = temp1(:,2);
%     d((i-1)*N_TIME_STEPS+1:N_TIME_STEPS*i, Y) = temp1(:,3);
%     
% end


    
%  tracking.spot3DSecUsecIndexFramenumXYZRPY = d;
%     
%     filename1 = strrep(filename, '.evt', '');
%     filename1 = strrep(filename1, '.mat', '');
%     outfile = [filename1 '.evt.mat'];
%     save(outfile, 'tracking');   
%     
% return;