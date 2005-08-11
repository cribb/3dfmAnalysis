function v = load_lasertrap_tracking(filename, spring_constants);


d = load_vrpn_tracking(filename,'m','zero','yes');  %load in data set

%Set spring constants
if nargin < 2 | isempty(spring_constants)
	k_x = 40e-12/1e-6; % N/m            % 40; %244  %pN/um
	k_y = 40e-12/1e-6; % N/m            % 40; %244  %pn/um
	k_z = 10e-12/1e-6; % N/m            % 10; %90   %pN/um
else
    k_x = spring_constants(1);
    k_y = spring_constants(2);
    k_z = spring_constants(3);
end


%convert to center of trap coords. 
v.trapcentered.x = d.posError.x - d.posError.x(1);
v.trapcentered.y = d.posError.y - d.posError.y(1);
v.trapcentered.z = d.posError.z - d.posError.z(1);

%Convert QPD data to forces
v.forces.x = k_x * v.trapcentered.x;
v.forces.y = k_y * v.trapcentered.y;
v.forces.z = k_z * v.trapcentered.z;

v.position.x = d.beadpos.x;
v.position.y = d.beadpos.y;
v.position.z = d.beadpos.z;
v.time       = d.beadpos.time;

% % [px,fx] = mypsd(d.posError.x, 10000, 1, 'rectangle');
% % [py,fy] = mypsd(d.posError.y, 10000, 1, 'rectangle');
% % [pz,fz] = mypsd(d.posError.z, 10000, 1, 'rectangle');
% % 
% % figure(1);subplot(2,1,1),plot(d.beadpos.time,j.position.x)
% % title('X Position (microns) vs. Time (seconds)')
% % xlabel('seconds')
% % ylabel('microns')
% % subplot(2,1,2),plot(d.beadpos.time,j.forces.x)
% % title('X Position vs. Force')
% % xlabel('time')
% % ylabel('pN')
% % 
% % figure(2);subplot(2,1,1),plot(d.beadpos.time,j.position.y)
% % title('Y Position (microns) vs. Time (seconds)')
% % xlabel('seconds')
% % ylabel('microns')
% % subplot(2,1,2),plot(d.beadpos.time,j.forces.y)
% % title('Y Position vs. Force')
% % xlabel('time')
% % ylabel('pN')
% % 
% % figure(3);subplot(2,1,1),plot(d.beadpos.time,j.position.z)
% % title('Z Position (microns) vs. Time (seconds)')
% % xlabel('seconds')
% % ylabel('microns')
% % subplot(2,1,2),plot(d.beadpos.time,j.forces.z)
% % title('Z Position vs. Force')
% % xlabel('time')
% % ylabel('pN')
% % 
% % figure(4);plot(abs(j.position.x),j.forces.x)
% % title('X Force vs. Extension')
% % xlabel('Position (microns)')
% % ylabel('Force (pN)')
% % 
% % figure(5);plot(abs(j.position.y),j.forces.y)
% % title('Y Force vs. Extension')
% % xlabel('Position (microns)')
% % ylabel('Force (pN)')
% % 
% % figure(6);plot(abs(j.position.z),j.forces.z)
% % title('Z Force vs. Extension')
% % xlabel('Position (microns)')
% % ylabel('Force (pN)')
% % 
% % % figure(4);loglog(fx,px)
% % % title('X PSD')
% % % xlabel('log frequency (Hz)')
% % % ylabel('Power (um^2/Hz')
% % % 
% % % figure(5);loglog(fy,py)
% % % title('Y PSD')
% % % xlabel('log frequency (Hz)')
% % % ylabel('Power (um^2/Hz')
% % % 
% % % figure(6);loglog(fz,pz)
% % % title('Z PSD')
% % % xlabel('log frequency (Hz)')
% % % ylabel('Power (um^2/Hz')
% % 
% % figure;subplot(2,1,1),loglog(fx,px)
% % title('X PSD')
% % ylabel('Power (um^2/Hz')
% % subplot(2,1,2),loglog(fy,py)
% % title('Y PSD')
% % xlabel('log frequency (Hz)')
% % ylabel('Power (um^2/Hz)')
% % 
% % % subplot(3,1,3),loglog(fz,pz)
% % % title('Z PSD')
% % % xlabel('log frequency (Hz)')
% % % ylabel('Power (um^2/Hz')
% % 
% % 
