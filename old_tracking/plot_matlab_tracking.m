function plot_matlab_tracking(d, plots)
% 3DFM function
% Last Modified on 8/12/02
%
% This function is a collection of common plots for the
% 3DFM microscope.
%
% plot_matlab_tracking(d, plots)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Z-stage (for drift) and Laser Fluctuations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(findstr('l',plots))
    figure(1);
    subplot(2,1,1), plot(d.stage.time,d.laser)
    title('Laser Fluctuations');
    subplot(2,1,2), plot(d.stage.time,d.stage.z)
    title('Z Position');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stage motion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(findstr('3',plots))
    figure(2); plot3(d.stage.x, d.stage.y, d.stage.z);
    xl=xlabel('X Position (microns)');
        %set(xl,'Rotation', -15); %Rotates the text 15 degrees
        %set(xl,'Units','Normalized'); %Sets the axes ranges to lie between 0 and 1
        %set(xl,'Position',[.38 -.06]); %Sets the position along the axis
    yl=ylabel('Y Position (microns)');
        %set(yl,'Rotation', 17); %Rotates the text 15 degrees
        %set(yl,'Units','Normalized'); %Sets the axes ranges to lie between 0 and 1
        %set(yl,'Position',[.65 -.05]); %Sets the position along the axis
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
		plot(d.stage.time, d.stage.x);
		title('X stage translation through time');
		xlabel('time (sec)');
		ylabel('x position (um)');

% 		subplot(2,1,2);
% 		plot(d.stage.time, d.error.x);
% 		title('X Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(5);
		
        plot(d.stage.time, d.stage.x);
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
		plot(d.stage.time, d.stage.y);
		title('Y stage translation through time');
		xlabel('time (sec)');
		ylabel('y position (um)');

% 		subplot(2,1,2);
% 		plot(d.stage.time, d.error.y);
% 		title('Y Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(6);
		
        plot(d.stage.time, d.stage.y);
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
		plot(d.stage.time, d.stage.z);
		title('Z stage translation through time');
		xlabel('time (sec)');
		ylabel('z position (um)');

% 		subplot(2,1,2);
% 		plot(d.stage.time, d.error.z);
% 		title('Z Error Signal, uncalibrated for bead');
% 		xlabel('time (sec)');
% 		ylabel('Error (Volts)');
	else
		figure(7);
		
        plot(d.stage.time, d.stage.z);
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

