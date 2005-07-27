function v = laser_forcecal(tracking_log_file, magnet_log_file, dominant_pole, bead_radius, viscosity)

% handle argument list
if (nargin < 5) | isempty(viscosity);      viscosity = 1.6;       end;
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

%     % code for separate subplots 
%     figure;
%     subplot(2, 1, 2);
%     stairs(magtime - mintime, m.analogs(:,dominant_pole), 'k-');
%     axis([0, maxtime - mintime, min(m.analogs(:,dominant_pole))*0.90, max(m.analogs(:,dominant_pole))*1.1]);
%     subplot(2, 1, 1); hold on;
%     plot(beadtime - mintime, r * 1e6, 'b-');
%     axis([0, maxtime - mintime, min(r * 1e6)*0.90, max(r * 1e6)*1.1]);

    % code for single plot with secondary y-axis 
    figure;
    [ax, h1, h2] = plotyy(beadtime - mintime, r * 1e6, magtime - mintime, m.analogs(:,dominant_pole), 'plot', 'stairs');
    title('Force Calibration, laser tracking');   
    xlabel('time [s]');
    set(get(ax(1),'Ylabel'),'String','radial displacement [\mum]');
	set(get(ax(2),'Ylabel'),'String','dominant coil [V]');
    pretty_plot;
    
warning off MATLAB:polyfit:RepeatedPointsOrRescale

count = 1;

% Start processing the magnet log entries and create force table.
for k = 1 : ( length(magtime) - 1 );

    % for how long do we need to ignore points due to disynchrony?
    buffer = 0.1; % seconds
    
    idx = find(beadtime >= (magtime(k) + buffer) & beadtime < (magtime(k+1) - buffer));
    
    N = length(idx);
    
    % how many laser points do we want to require for fitting?
    % just going to guess for now
    thresh = 100;
    
    if (N > thresh)
        
        fit = polyfit(beadtime(idx), r(idx), 1);
        bead_velocity = fit(1);
        
        force = 6 * pi * bead_radius * viscosity * bead_velocity;
        uncertainty_in_force = 6*pi*bead_radius * viscosity * uncertainty_in_slope(beadtime(idx), r(idx), fit);
        
        force_table(count, 1) = min(beadtime(idx)) - mintime;
        force_table(count, 2) = max(beadtime(idx)) - mintime;
        force_table(count, 3) = N;
        force_table(count, 4) = m.analogs(k, dominant_pole);   % reporting voltage
        force_table(count, 5) = force;
        force_table(count, 6) = uncertainty_in_slope(beadtime(idx), r(idx), fit) / bead_velocity;

        count = count + 1;

        % code for separate subplots
        % plot(beadtime(idx) - mintime, polyval(fit, beadtime(idx)) * 1e6, 'r-');
        
        hold on; 
            plot(beadtime(idx) - mintime, polyval(fit, beadtime(idx)) * 1e6, 'r-');
        hold off;    
    end
end

v = force_table;

