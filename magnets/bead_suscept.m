function v = bead_suscept(files, viscosity, bead_radius, calib_um, gradofBsquared, window_size)
% 3DFM function  
% Magnetics
% last modified 08/01/06 (jcribb)
%  
% Computes the bead-to-bead variability in force and bead susceptibility.
% Requires knowledge of the field gradient.
%
%   v = bead_suscept(files, viscosity, bead_radius, calib_um,gradofBsquared, window_size)
%                                       
%  where "files" containts a string for filename(s) (wildcards ok)
%        "viscosity" of the Newtonian calibrator fluid in [Pa s]
%        "bead_radius" in [m]
%        "calib_um" is the pixels to microns conversion in [microns/pixel]
%        "gradofBsquared" of a known magnet in [T/m]
%        "window_size" (tau) of the derivative
%
    format long g;
    
    mu0 = 4*pi*1e-7;    

    % set up variables for easy tracking of table's column headings
    video_tracking_constants;

    d = load_video_tracking(files, [], 'm', calib_um, 'relative', 'yes', 'table');
    
    N = length(unique(d(:,ID)));


    % for each beadID, compute it's velocity:magnitude, force:magnitude,
    % and then its susceptibility.     
    
    h = figure;
	for k = 0 : get_beadmax(d)

        temp = get_bead(d, k);

        [newxy,force] = forces2d(temp(:,TIME), temp(:,X:Y), viscosity, bead_radius, window_size);
    
        velocity = force ./ (6*pi*viscosity*bead_radius);

        chi = (-12*mu0*mean(force)) ./ (4*mu0*mean(force) - pi*(2*bead_radius)^3*gradofBsquared);

            figure(h); 
            hold on;
            plot(temp(:,TIME)-temp(1,TIME), magnitude(temp(:,X:Y) * 1e6), '-','LineWidth',2);
            xlabel('Time [s]');
            ylabel('Bead Position [\mum]');
            hold off;
            drawnow;
                    
        mforce(k+1) = mean(force);
        sforce(k+1) = std(force);
        mvel(k+1) = mean(velocity);
        outchi(k+1) = chi;

    end        
    pretty_plot;
    
        fprintf('Number of beads tracked = %d\n', N);
        fprintf('Average Velocity between beads [m/s] = %d\n', mean(mvel));
        fprintf('StDev of Velocity between beads [m/s] = %d\n', std(mvel));
        fprintf('Average Force between beads [N] = %d N\n', mean(mforce));
        fprintf('StDev of Force between beads [N] = %d N\n', std(mforce));
        fprintf('Mean Volumetric Susceptibility = %d\n', mean(outchi));
        fprintf('StDev of Volumetric Susceptibility = %d\n', std(outchi));
    
    v.mean_forces = mforce';
    v.std_forces = sforce';
    v.mean_velocity = mvel';
    v.chi = outchi';
    v.N = N;
    
    