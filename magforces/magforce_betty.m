function v = magforce_betty(file, frame_rate, order, viscosity, bead_radius)
% 3DFM function
% last modified 03/01/03
% 
% d = magforce_betty(file, frame_rate, order, viscosity, bead_radius);
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
% 04/07/03 - first version - jcribb

    
    % input data, and get its dimensions
    d = xlsread(file);
    [r c] = size(d);
    
    % establish x and y vectors, and sampling information
    image_plane     = d(:,3);
    tracking_number = d(:,2);
    x_position      = d(:,4);
    y_position      = d(:,5);
    t = image_plane * (1/frame_rate);

    fprintf('\nThere are %d beads tracked in this logfile\n',max(tracking_number));    
    fprintf('--------------------------------------------\n');
    
    figure(tracking_number(end)+1);
    close;
    
    for n = 1:max(tracking_number)
        figure(n);
        clf(n);

        % we only want data for bead(n)
        data = find(tracking_number == n);
        
        % call function and get forces for bead(n)
        s(n) = get_magforce(x_position(data), y_position(data), t(data), n, order, viscosity, bead_radius);
        
        % Composite figure with all beads displayed
        figure(max(tracking_number)+1);
        hold on;
        grid on;
        plot(s(n).distance*1e6,s(n).force*1e12);
        xlabel('microns from pole');
        ylabel('pN');
        pause(0.001);
    end
    
    % Let's leave the matlab stdout pretty
    fprintf('\n'); 

    v = mean_all_forces(s);
    
    % The output of this function is an array of structs containing force & distance
    % v = s;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = get_magforce(x, y, t, n, order, viscosity, bead_radius)
% get vector magnitudes and plot them, showing the 
% final index value on the plot (for ease of selection)

    c = sqrt(x.^2 + y.^2);
    
    fprintf('\nTracked Bead #%d: \n',n);
    
    figure(n);
    plot(c);    
    xlabel('Array Index');
    ylabel('distance from pole');
    text(length(c)*0.9,c(end),num2str(length(c)));
    
    % Select only the dataset section that we want to use
%     start_clip = input('enter the start clip index: ');
%     stop_clip  = input('enter the last  clip index: ');    

    start_clip = 1;
    stop_clip = length(c);
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
    t = t - t(start_clip);
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
    force = -(6 * pi * viscosity * bead_radius * (dcdt * 1e-6));
    
    c = c(2:end);
    force = force(2:end);
    
    % Plot new force curve
    figure(n);
    subplot(2,1,2);
    plot(c, force*1e12);
    title('Force Curve');
    xlabel('distance from pole (microns)');
    ylabel('force (pN)');
    grid on;
    
    % Output data in meters & Newtons
    v.distance = c*1e-6;
    v.force    = force;
    v.coeffs   = polyfit(v.distance, v.force, order) .* 1e12;
    v.tag      = ['These are data fitted by a polynomial of order ' ...
                  num2str(order) ...
                  '.   Units are meters & Newtons'];

%%%%%%%%%%%%%%%%%%%%%%%%5
function v = mean_all_forces(s)

     new_distances = [0 : 0.01 : 100] * 1e-6;  % meters from pole
     for k = 1:length(s)
           v(k,:)  = interp1(s(k).distance,s(k).force,new_distances,'linear','extrap');
     end
     v.force = v';
     v.distance = new_distances';
     %v = [new_distances' mean(v,1)'];
     
     