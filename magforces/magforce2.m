function v = magforce_betty(file, frame_rate, order, viscosity, bead_radius)
% 3DFM function
% last modified 03/01/03
% 
% d = magforce(file, frame_rate, order, viscosity, bead_radius);
%
% where "file" is the .xls file containing distance and time data from metamorph
%       "frame_rate" is the frame rate of the video
%		"order" is the desired polynomial fit (order)
%       "viscosity" is the viscosity of the test solution in Pa sec
%       "bead_radius" is the bead radius in meters
%
% This function reads in a Metamorph *.log file previously saved as a 
% Excel Spreadsheet and outputs a force vs. distance curve
%
% 03/01/03 - first version - jcribb

    clc;

    % input data, and get its dimensions
    d = xlsread(file);
    [r c] = size(d);
    
    % establish x and y vectors, and sampling information
    image_plane     = d(:,1);
    tracking_number = d(:,2);
    x_position      = d(:,3);
    y_position      = d(:,4);
    t = image_plane * (1/frame_rate);

    fprintf('\nThere are %d beads tracked in this logfile\n\n',tracking_number(end));    
    for n = 1:tracking_number(end)
        figure(n);
        clf;

        data = find(tracking_number == n);
        s(n) = get_magforce2(x_position(data), y_position(data), t(data), n, order, viscosity, bead_radius);
    end
    
    v = s;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function v = get_magforce(x, y, t, n, order, viscosity, bead_radius)
    % get vector magnitudes and plot them, showing the 
    % final index value on the plot (for ease of selection)
    c = sqrt(x.^2 + y.^2);
    
    fprintf('\nTracked Bead #%d: \n',n);
        
    figure(n);
    plot(c);    
    text(length(c)*0.9,c(end),num2str(length(c)));
    
    % Select only the dataset section that we want to use
    start_clip = input('enter the start clip index: ');
    stop_clip  = input('enter the last  clip index: ');    
    len = start_clip:stop_clip;
    t = t(len);
    x = x(len);
    y = y(len);
    
    % Consider the stop_clip position to be the final
    % position of the bead (when velocity == 0).  We also 
    % assume that the final position of the bead is right 
    % against the pole.  Because of these assumptions, we
    % consider the final position (stop_clip) to be ZERO
    % microns from the pole tip.
    x = x - x(stop_clip);
    y = y - y(stop_clip);
    
    % get new vector magnitudes
    c = sqrt(x.^2 + y.^2);

    % plot new vector magnitudes
    figure(n);
    subplot(2,1,1);
    plot(t,c,'b.');
    hold on;
    
    % fit the vector magnitudes to a polynomial and
    % construct new array with polynomial values in them
    p = polyfit(t, c, order);
    c = polyval(p, t);

    % plot polynomial fit on top of vector magnitudes
    figure(n);
    plot(t, c,'r', 'LineWidth', 2);
    legend('position data', 'polyfit');
    title('Position vs. time');
    xlabel('time to impact');
    ylabel('RMS distance');
    hold off;
    
    % The derivative of the position is the velocity
    dcdt = diff([0 ; c])./diff([0 ; t]);
    
    % Stokes' Law
    % Force = 6 * pi * viscosity * bead_radius * velocity of bead
    force = (6 * pi * viscosity * bead_radius * (dcdt * 1e-6));

    c = c(2:end);
    force = force(2:end);
    
    % Plot new force curve
    figure(n);
    subplot(2,1,2);
    plot(c, -force*1e12);
    title('Force Curve');
    xlabel('distance from pole (microns)');
    ylabel('force (pN)');
    grid on;
    
    % Output data in meters & Newtons
    v.distance = c*1e-6;
    v.force    = force;
    v.tag      = ['These are data fitted by a ' ...
                   num2str(order) ...
                   ' polynomial.  Units are meters & newtons'];
