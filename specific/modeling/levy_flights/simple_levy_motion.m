% function outs = prep_varr_model(vn);
clear all;

% %%%%%%%%%%
% set up parameters for the physical model 
% %%%%%%%%%%
vortex_type = 'irrotational';

vn = 1;       % number of vortices on a side
vs = 1e-6;      % vortex spacing:  meters between vortices

tn = vn;      % number of tracers on a side
ts = vs;      % tracer spacing

% generate matrices that contain the 'vortex locations' (vl)
[vlx,vly] = meshgrid([0:vs:vn*vs-vs],[0:vs:vn*vs-vs]);
vl = [vlx(:) vly(:)];

gm = 2e-11;  % power for each vortex

% tile gamma value out to the appropriate number of vortices
gamma = gm .* ones(size(vlx)); 

% Generate receptor and tracer locations (rtl).
[rtlx,rtly] = meshgrid([0:ts:tn*ts-ts]-ts/3,[0:ts:tn*ts-ts]);

% Right now tracers and receptors hide in the tracer variable.  Reduce the
% number of each by half and pull them into their own matrices.
q = sortrows([rtlx(:) rtly(:)],2);
tlx = q(1:2:end,1);  %   tracer locations in x
tly = q(1:2:end,2);  %                    in y
clear('q');

% Need to create a grid on which everything lies...
minx = min([vlx(:); tlx(:)]);
miny = min([vly(:); tly(:)]);
maxx = max([vlx(:); tlx(:)]);
maxy = max([vly(:); tly(:)]);
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

% plot positions of vortices and receptors and initial position of tracers
figure(h);
    hold on;
        plot(  vlx(:), vly(:), 'bo', ...
               tlx(:), tly(:), 'g.');
    xxxx    hold off;   
    axis([minx-bufx, maxx+bufx, miny-bufy, maxy+bufy]);
    axis square;
    grid off;


% %%%%%%%
% Fluid parameters
% %%%%%%%
% construct a number of diffusing bead traces 
numpaths = length(tlx);  % equal to the number of tracers we're tracking
viscosity = 0.001002;       % [Pa s]
lig_radius = 500e-9;     % [m]
sampling_rate = 1000;
time_step = 1/sampling_rate;       % [frames/sec]
duration = 10;        % [sec]
tempK = 300;           % [K]
dim = 2;
nPoints = duration .* sampling_rate;
time = [0:time_step:duration-time_step];

p = sim_newt_steps(viscosity, lig_radius, sampling_rate, duration, tempK, dim, numpaths);

dxdiff = squeeze(p(:,1,:));
dydiff = squeeze(p(:,2,:));

% %%%%
% Model progression through time
% %%%%

% seed all positions with initial zero
newposx = zeros(nPoints,length(tlx));  
newposy = zeros(nPoints,length(tly));

% Set the tracers' initial positions
newposx(1,:) = tlx';
newposy(1,:) = tly';

% generate velocities on each tracer from each vortex
[lvx,lvy] = vortex_vectors(tlx,tly,vlx,vly,gamma,vortex_type);

% Step through time... for each time step
for t = 2:nPoints
    
    % for each tracer
    for k = 1:length(tlx(:))        
        % summed velocity vector for each tracer due to vortices
        vel_tlx(1,k) = sum(lvx(:));
        vel_tly(1,k) = sum(lvy(:));
    end
    
    % add to the previous value the vortical flow vector and the diffusion
    newposx(t,:) = newposx(t-1,:) + (vel_tlx .* time_step);% + dxdiff(t,:);
    newposy(t,:) = newposy(t-1,:) + (vel_tly .* time_step);% + dydiff(t,:);    
end

figure(h);
    hold on;
        plot(  newposx(:), newposy(:), 'g.');
    hold off;
