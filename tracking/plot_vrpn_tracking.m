function plot_vrpn_tracking(d, plots)
% PLOT_VRPN_TRACKING common plots for 3DFM data.
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
%
% This function is a collection of common plots for the 3DFM.
%
% plot_vrpn_tracking(d, plots)
%
% where d is the typical 3DFM data structure from 'load_matlab_tracking'
% and plots is a string denoting which plots are desired.
%
% 'l'  Z-stage and Laser Fluctuations
% '3' for 3D stage motion
% 'p' for x,y,z power spectral densities (PSDs)
% 'n' for xyz displacement PSD
% 'x' for the x stage translation through time
% 'y' for the y stage translation through time
% 'z' for the z stage translation through time
% 'g' for shear moduli (storage and loss)
% 'v' for viscosity
% 'e' to append the QPD error signals onto 'x' 'y' 'z'
%


if (nargin < 2)
    plots = 'l3pnxyze';
end

if (d.info.orig.xyzunits == 'm')
    d.stageCom.x = d.stageCom.x * 1e-6;
    d.stageCom.y = d.stageCom.y * 1e-6;
    d.stageCom.z = d.stageCom.z * 1e-6;
    d.info.orig.xyzunits = 'um';
end

% subtract off the time-offset
d.stageCom.time = d.stageCom.time - d.stageCom.time(1,1);
% d.laser.time = d.laser.time - d.laser.time(1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Z-stage (for drift) and Laser Fluctuations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('l',plots))
    figure(1);
    subplot(2,1,1), plot(d.laser.time,d.laser.intensity)
    title('Laser Fluctuations');
    subplot(2,1,2), plot(d.stageCom.time,d.stageCom.z)
    title('Z Position');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stage motion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(findstr('3',plots))
    figure(2); plot3(d.stageCom.x, d.stageCom.y, d.stageCom.z);
    xl=xlabel('X Position (microns)');
        set(xl,'Rotation', -15); %Rotates the text 15 degrees
        set(xl,'Units','Normalized'); %Sets the axes ranges to lie between 0 and 1
        set(xl,'Position',[.38 -.06]); %Sets the position along the axis
    yl=ylabel('Y Position (microns)');
        set(yl,'Rotation', 17); %Rotates the text 15 degrees
        set(yl,'Units','Normalized'); %Sets the axes ranges to lie between 0 and 1
        set(yl,'Position',[.65 -.05]); %Sets the position along the axis
    zlabel('Z Position (microns)'); grid on;
    title('Bead Trace');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the Power Spectral Density for x, y, and z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(findstr('p',plots))
    figure(3);
    loglog(d.psd.f, [d.psd.x d.psd.y d.psd.z]);
    grid on;
    legend('X Displacement','Y Displacement', 'Z Displacement');
    xlabel('Hz');
    ylabel('dB');
    Title('PSD');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the net xyz displacement PSD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(findstr('n',plots))
    figure(4);
    loglog(d.psd.f, d.psd.xyz);
    grid on;
    legend('Displacement XYZ')
    xlabel('Hz');
    ylabel('dB');
    Title('PSD');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the x displacements through time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('x',plots))
	% Plot error signal on top of displacement if 'e' is in string
    if(findstr('e', plots))
    	figure(5);

		subplot(2,1,1);
		plot(d.stageCom.time, d.stageCom.x);
		title('X stage translation through time');
		xlabel('time (sec)');
		ylabel('x position (um)');

% 		subplot(2,1,2);
% 		plot(d.stageCom.time, d.error.x);
% 		title('X Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(5);
		
        plot(d.stageCom.time, d.stageCom.x);
		title('X stage translation through time');
		ylabel('X position');
		xlabel('time (sec)');
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the y displacements through time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('y',plots))
	% Plot error signal on top of displacement if 'e' is in string
    if(findstr('e', plots))
    	figure(6);

		subplot(2,1,1);
		plot(d.stageCom.time, d.stageCom.y);
		title('Y stage translation through time');
		xlabel('time (sec)');
		ylabel('y position (um)');

% 		subplot(2,1,2);
% 		plot(d.stageCom.time, d.error.y);
% 		title('Y Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(6);
		
        plot(d.stageCom.time, d.stageCom.y);
		title('Y stage translation through time');
		ylabel('y position');
		xlabel('time (sec)');
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the z displacements through time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('z',plots))

	% Plot error signal on top of displacement if 'e' is in string
    if(findstr('e', plots))
    	figure(7);

		subplot(2,1,1);
		plot(d.stageCom.time, d.stageCom.z);
		title('Z stage translation through time');
		xlabel('time (sec)');
		ylabel('z position (um)');

% 		subplot(2,1,2);
% 		plot(d.stageCom.time, d.error.z);
% 		title('Z Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(7);
		
        plot(d.stageCom.time, d.stageCom.z);
		title('Z stage translation through time');
		ylabel('z position');
		xlabel('time (sec)');
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the Storage and Loss Moduli 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('g',plots))

   	figure(8);
	plot(d.rheo.w/(2*pi), [-d.rheo.Gp' -d.rheo.Gpp']);
    legend('storage','loss');
    title('Complex Shear Modulus');
    xlabel('frequency (Hz)');
	ylabel('Shear Modulus (Pa)');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the z displacements through time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('g',plots))

   	figure(9);
	plot(d.rheo.w/(2*pi), d.rheo.visc);
    title('Viscosity Profile');
    xlabel('frequency (Hz)');
	ylabel('Dynamic Viscosity (Pa sec)');
    
end

