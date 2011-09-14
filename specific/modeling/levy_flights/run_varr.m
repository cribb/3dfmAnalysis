% function outs = prep_varr_model(vn);
clear all;

% %%%%%%%%%%
% set up parameters for the physical model 
% %%%%%%%%%%
vortex_type = 'irrotational';

vn = 5;       % number of vortices on a side
vs = 10; % vortex spacing:  microns between vortices

ln = vn;      % number of ligands on a side
ls = vs;      % ligand spacing

% generate matrices that contain the 'vortex locations' (vl)
[vlx,vly] = meshgrid([0:vs:vn*vs-vs],[0:vs:vn*vs-vs]);
vl = [vlx(:) vly(:)];

gm = 0.1;  % power for each vortex

% tile gamma value out to the appropriate number of vortices
gamma = gm .* ones(size(vlx)); 

% Generate receptors' and ligands' locations (rll).
[rllx,rlly] = meshgrid([0:ls:ln*ls-ls]-ls/2,[0:ls:ln*ls-ls]);

% Right now ligands and receptors hide in the ligand variable.  Reduce the
% number of each by half and pull them into their own matrices.
q = sortrows([rllx(:) rlly(:)],2);
llx = q(1:2:end,1);  %   ligand locations in x
lly = q(1:2:end,2);  %                    in y
rlx = q(2:2:end,1);  % receptor locations in x
rly = q(2:2:end,2);  %                    in y
clear('q');

% Need to create a grid on which everything lies...
minx = min([vlx(:); llx(:); rlx(:)]);
miny = min([vly(:); lly(:); rly(:)]);
maxx = max([vlx(:); llx(:); rlx(:)]);
maxy = max([vly(:); lly(:); rly(:)]);
ranx = maxx - minx;
rany = maxy - miny;
bufx = ranx / 5; % a 10% buffer added to the boundary around the furthest points of interest
bufy = rany / 5;
gridx = ranx / 100;
gridy = rany / 100;

% the grid
x1 = (minx - bufx) : gridx : (maxx+bufx);
y1 = (miny - bufy) : gridy : (maxy+bufy);
[x,y] = meshgrid(x1, y1);


% generate, primarily for reference, the vector field along the x,y grid
% from which everything flows
[vx,vy] = vortex_vectors(x,y,vlx,vly,gamma,vortex_type);


% plot vector field background
h = figure;
quiver(x, y, vx, vy, 'Color', [0.8 0.8 0.8]);

% plot positions of vortices and receptors and initial position of ligands
figure(h);
    hold on;
        plot(  vlx(:), vly(:), 'bo', ...
               llx(:), lly(:), 'g.', ...
               rlx(:), rly(:), 'rx');
    hold off;   
    axis([minx-bufx, maxx+bufx, miny-bufy, maxy+bufy]);
    axis square;
    grid off;


% %%%%%%%
% Fluid parameters
% %%%%%%%
% construct a number of diffusing bead traces 
numpaths = length(llx);  % equal to the number of ligands we're tracking
viscosity = 0.001;       % [Pa s]
lig_radius = 250e-9;     % [m]
sampling_rate = 30;
time_step = 1/sampling_rate;       % [frames/sec]
duration = 100;        % [sec]
tempK = 300;           % [K]
dim = 2;
nPoints = duration .* sampling_rate;

p = sim_newt_steps(viscosity, lig_radius, sampling_rate, duration, tempK, dim, numpaths);

dxdiff = squeeze(p(:,1,:));
dydiff = squeeze(p(:,2,:));






% %%%%
% Model progression through time
% %%%%

% seed all positions with initial zero
newposx = zeros(nPoints,length(llx));  
newposy = zeros(nPoints,length(lly));

% Set the ligands' initial positions
newposx(1,:) = llx';
newposy(1,:) = lly';

% Step through time... for each time step
for t = 2:nPoints
    
    % for each ligand
    for k = 1:length(llx(:))        
        % generate velocities on each ligand from each vortex
        [lvx,lvy] = vortex_vectors(llx,lly,vlx,vly,gamma,vortex_type);

        % summed velocity vector for each ligand due to vortices
        vel_llx(1,k) = sum(lvx(:));
        vel_lly(1,k) = sum(lvy(:));
    end
    
    % add to the previous value the vortical flow vector and the diffusion
    newposx(t,:) = newposx(t-1,:) + (vel_llx .* time_step) + dxdiff(t);
    newposy(t,:) = newposy(t-1,:) + (vel_lly .* time_step) + dydiff(t);    
end

figure(h);
    hold on;
        plot(  newposx(:), newposy(:), 'g.');
    hold off;
