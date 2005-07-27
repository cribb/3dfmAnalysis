function v = laser_membranestep(tracking_log_file, magnet_log_file, dominant_pole)

% handle argument list
% if (nargin < 5) | isempty(viscosity);      viscosity = 1.6;       end;
if (nargin < 4) | isempty(bead_radius);    bead_radius = 0.5e-6;  end;
if (nargin < 3) | isempty(dominant_pole);  dominant_pole = 4;     end;

% first, load the datastreams
d = load_vrpn_tracking(tracking_log_file, 'm');
m = load(magnet_log_file);
m = m.magnets;

% easier time variables
beadtime = d.beadpos.time;
magtime = m.time;

% merge the two-column timestamps for magnet timestamps
% into one column... matlab gives us enough precision to keep us happy.
magtime = magtime(:,1) + magtime(:,2) * 1e-6;

% determine the minimum time recorded by either of these 
% files and use that as t-zero
mintime = min([beadtime ; magtime]);
maxtime = max([beadtime ; magtime]);

% compute radial vector for bead position
r = magnitude(d.beadpos.x, d.beadpos.y, d.beadpos.z);

    % code for single plot with secondary y-axis 
    figure;
    [ax, h1, h2] = plotyy(beadtime - mintime, r * 1e6, magtime - mintime, m.analogs(:,dominant_pole), 'plot', 'stairs');
    title('laser tracking - Relaxation Time');
    xlabel('time [s]');
    set(get(ax(1),'Ylabel'),'String','radial displacement [\mum]');
	set(get(ax(2),'Ylabel'),'String','dominant coil [V]');
    pretty_plot;
    
warning off MATLAB:polyfit:RepeatedPointsOrRescale

count = 1;

% Start processing the magnet log entries and create force table.
for k = 1 : ( length(magtime) - 1 );

    % for how long do we need to ignore points due to dysynchrony?
    buffer = 0; % seconds
    
    idx = find(beadtime >= (magtime(k) + buffer) & beadtime < (magtime(k+1) - buffer));
    
    N = length(idx);
    
    % how many laser points do we want to require for fitting?
    % just going to guess for now
    thresh = 100;
    
    if (N > thresh) & (m.analogs(k, dominant_pole) > 0)
        
        % perform fitting routine
        [k0,k1,gamma0,gamma1,R_square] = membrane_step_response(beadtime(idx) - mintime, r(idx));
        
        tau_table(count, 1) = min(beadtime(idx)) - mintime;
        tau_table(count, 2) = max(beadtime(idx)) - mintime;
        tau_table(count, 3) = N;
        tau_table(count, 4) = m.analogs(k, dominant_pole);   % reporting voltage
        tau_table(count, 5:8) = [k0,k1,gamma0,gamma1];
        tau_table(count, 9) = R_square;

        count = count + 1;

    end
end

v = tau_table;

