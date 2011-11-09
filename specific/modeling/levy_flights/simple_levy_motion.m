function vidtable = simple_levy_motion(savefile, gm, viscosity, calibum, report_yn)
tic;

if nargin < 1 || isempty(savefile)
    savefile = 'testfile.vrpn.evt.mat';
end

if nargin < 2 || isempty(gm)
    gm = 1e-12;  % power for each vortex
end

if nargin < 3 || isempty(viscosity)
    viscosity = 0.01;        % [Pa s]
end

if nargin < 4 || isempty(calibum)
    calibum = 0.152;  % [um/pixel]
end

if nargin < 5 || isempty(report_yn)
    report_yn = 'y';
end

% %%%%%%%%%%
% set up parameters for the physical model 
% %%%%%%%%%%
vortex_type = 'irrotational';

vn = 8;      % number of vortices on a side
vs = 10e-6;   % vortex spacing:  meters between vortices

tn = vn;      % number of tracers on a side
ts = vs;      % tracer spacing

% generate matrices that contain the 'vortex locations' (vl)

% % regular spacing
[vlx,vly] = meshgrid([0:vs:vn*vs-vs],[0:vs:vn*vs-vs]);

% % random spacing
vlx = rand(vn,vn) * (vs*vn);
vly = rand(vn,vn) * (vs*vn);

vlx = vlx(:);
vly = vly(:);

gm = 1e-12;  % power for each vortex

% tile gamma value out to the appropriate number of vortices
gamma = gm .* ones(size(vlx)); 

% Generate tracer locations (tl).

% % regular spacing
[tlx,tly] = meshgrid([0:ts:tn*ts-ts]-ts/2,[0:ts:tn*ts-ts]);

% % random spacing
tlx = rand(tn,tn) * (ts*tn);
tly = rand(tn,tn) * (ts*tn);

tlx = tlx(:);
tly = tly(:);

% Need to create a grid on which everything lies...
minx = min([vlx; tlx]);
miny = min([vly; tly]);
maxx = max([vlx; tlx]);
maxy = max([vly; tly]);
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

% %%%%%%%
% Fluid parameters
% %%%%%%%
% construct a number of diffusing bead traces 
numpaths = length(tlx);  % equal to the number of tracers we're tracking
viscosity = 0.01;       % [Pa s]
lig_radius = 250e-9;     % [m]
sampling_rate = 30;
time_step = 1/sampling_rate;       % [frames/sec]
duration = 100;        % [sec]
tempK = 300;           % [K]
dim = 2;
nPoints = duration .* sampling_rate;

dxydiff = sim_newt_steps(viscosity, lig_radius, sampling_rate, duration, tempK, dim, numpaths);

dxdiff = squeeze(dxydiff(:,1,:));
dydiff = squeeze(dxydiff(:,2,:));

% %%%%
% Model progression through time
% %%%%

% seed all positions with initial zero
new_tlx = zeros(nPoints,length(tlx));  
new_tly = zeros(nPoints,length(tly));

% Set the tracers' initial positions
new_tlx(1,:) = tlx';
new_tly(1,:) = tly';

% set up the video table with all the initial data
video_tracking_constants;
vidtable = zeros(length(tlx)*sampling_rate*duration,9);
vidtable(1:length(tlx),TIME)  = 0;
vidtable(1:length(tlx),ID)    = 0:length(tlx)-1;
vidtable(1:length(tlx),FRAME) = 1;
vidtable(1:length(tlx),X)     = tlx;
vidtable(1:length(tlx),Y)     = tly;
vidtable(1:length(tlx),[Z ROLL PITCH YAW]) = 0;

% Step through time... for each time step
for t = 2:nPoints

    % generate velocities on each tracer from each vortex
    % tvx = "tracer velocity in x"
    % tlx = "tracer location in x"
    % vlx = "vortex location in x"
    [tvx,tvy] = vortex_vectors(tlx,tly,vlx,vly,gamma,vortex_type);
    
    % for each tracer
    for k = 1:length(tvx(:))                
    
        % add to the previous value the vortical flow vector and the diffusion
        new_tlx(t,k) = new_tlx(t-1,k) + (tvx(k) .* time_step) + dxdiff(t,k);
        new_tly(t,k) = new_tly(t-1,k) + (tvy(k) .* time_step) + dydiff(t,k);    
        
        myrow = (t-1)*length(tlx)+k;
        
        vidtable(myrow, TIME)   = t*time_step;
        vidtable(myrow, ID)     = k-1;
        vidtable(myrow, FRAME)  = t; 
        vidtable(myrow, X)      = new_tlx(t,k);
        vidtable(myrow, Y)      = new_tly(t,k);
        vidtable(myrow, [Z ROLL PITCH YAW]) = 0;
    end    
    


%     tlx = newposx(t,:);
%     tly = newposy(t,:);
end

outfile = save_evtfile(savefile, vidtable, 'm', calibum);


% plot vector field background
h = figure;
quiver(x, y, vx, vy, 'Color', [0.8 0.8 0.8]);


% plot tracer histories
figure(h);
    hold on;
        plot(  new_tlx, new_tly, 'g.');
    hold off;
    
% plot positions of vortices
figure(h);
    hold on;
        plot(  vlx(:), vly(:), 'bo');
    hold off;   
    axis([minx-bufx, maxx+bufx, miny-bufy, maxy+bufy]);
    axis square;    
    grid off;
    
    
    toc    
    
return;
    
    