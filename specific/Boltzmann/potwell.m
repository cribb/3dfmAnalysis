function j = potwell(txyz);
% drift must be subtracted from txyz beforehand
boltzmann_const = 1.380658e-17;     % N*um/K 
temperature     = 298;  
rate = 10000;                        % decimated data sampled 1/10 normal
psd_res = 1;
window = 'blackman';
BIN = 10E-3; % Bin size [um] for the histogram
FIT_PARABOLA = 0;

time = txyz(:,1);
x = txyz(:,2);
y = txyz(:,3);
z = txyz(:,4);

neutralize = 0;
if neutralize
    mod_x = x - mean(x);
    mod_y = y - mean(y);
    mod_z = z - mean(z);
else
    mod_x = x;
    mod_y = y;
    mod_z = z;
end
BIN = 10e-3; %10nm - bin size for the histogram 

x_disp = min(mod_x):BIN:max(mod_x);
y_disp = min(mod_y):BIN:max(mod_y);
z_disp = min(mod_z):BIN:max(mod_z);

freq_counts_x = hist(mod_x,x_disp);
freq_counts_y = hist(mod_y,y_disp);
freq_counts_z = hist(mod_z,z_disp);

%find non-zero values

nonzero_index_x = find(freq_counts_x > 50);
nonzero_index_y = find(freq_counts_y > 50);
nonzero_index_z = find(freq_counts_z > 50);

nonzero_x_bins = freq_counts_x(nonzero_index_x);
nonzero_y_bins = freq_counts_y(nonzero_index_y);
nonzero_z_bins = freq_counts_z(nonzero_index_z);

nonzero_x_disp = x_disp(nonzero_index_x);
nonzero_y_disp = y_disp(nonzero_index_y);
nonzero_z_disp = z_disp(nonzero_index_z);

h_x = nonzero_x_bins;    
h_y = nonzero_y_bins;
h_z = nonzero_z_bins;
%[10^-21 J] energy=-Kb*T*log(freq_counts); %=> can't take log of zero
energy_x=-boltzmann_const*temperature*log(h_x);            
energy_y=-boltzmann_const*temperature*log(h_y);
energy_z=-boltzmann_const*temperature*log(h_z);



if FIT_PARABOLA
    [p_x,sX] = polyfit(nonzero_x_disp,energy_x,2);
    [p_y,sY] = polyfit(nonzero_y_disp,energy_y,2);
    [p_z,sZ] = polyfit(nonzero_z_disp,energy_z,2);

    [po_x,deltaX] = polyval(p_x,nonzero_x_disp,sX);
    [po_y,deltaY] = polyval(p_y,nonzero_y_disp,sY);
    [po_z,deltaZ] = polyval(p_z,nonzero_z_disp,sZ);

    j.k_x = p_x(1)*2;


    j.k_y = p_y(1)*2;


    j.k_z = p_z(1)*2
    j.k_z_error = mean(deltaZ*2);
end

[px,fx] = mypsd(x, rate, psd_res, window);
[py,fy] = mypsd(y, rate, psd_res, window);
[pz,fz] = mypsd(z, rate, psd_res, window);
        


        figure; 
        %subplot(1,columns,sp);
        bar(nonzero_x_disp,h_x);
        title('x displacement distribution');
        xlabel('x displacement (\mum)');
        ylabel('frequency (counts)');

        figure; 
        %subplot(1,columns,sp);
        bar(nonzero_y_disp,h_y);
        title('y displacement distribution');
        xlabel('y displacement (\mum)');
        ylabel('frequency (counts)');

        figure; 
        %subplot(1,columns,sp);
        bar(nonzero_z_disp,h_z);
        title('z displacement distribution');
        xlabel('z displacement (\mum)');
        ylabel('frequency (counts)');
    
		figure; 
		%subplot(1,columns,sp);
% 		plot(nonzero_x_disp,energy_x,'b',nonzero_x_disp,po_x,'r');
        plot(nonzero_x_disp,energy_x,'b');
		title('X Energy of bead ');
		xlabel('x displacement (\mum)');
		ylabel('energy [10^{-21} J]');

        figure; 
		%subplot(1,columns,sp);
% 		plot(nonzero_y_disp,energy_y,'b',nonzero_y_disp,po_y,'r');
        plot(nonzero_y_disp,energy_y,'b');
        title('Y Energy of bead ');
		xlabel('y displacement (\mum)');
		ylabel('energy [10^{-21} J]');
        
        figure; 
		%subplot(1,columns,sp);
% 		plot(nonzero_z_disp,energy_z,'b',nonzero_z_disp,po_z,'r');
        plot(nonzero_z_disp,energy_z,'b');
        title('Z Energy of bead ');
		xlabel('z displacement (\mum)');
		ylabel('energy [10^{-21} J]');


        figure;subplot(3,1,1),plot(time,mod_x);
		title(['X Displacement vs. time']);
        subplot(3,1,2),plot(time,mod_y);
		title(['Y Displacement vs. time']);
		ylabel('bead displacement (\mum)');
        subplot(3,1,3),plot(time,mod_z);
		title(['Z Displacement vs. time']);
		xlabel('time (seconds)');
       
        
        grid on;figure;subplot(3,1,1),loglog(fx,px)
        title('X PSD')
        subplot(3,1,2),loglog(fy,py)
        title('Y PSD')
        ylabel('Power (\mum^2/Hz)')
        subplot(3,1,3),loglog(fz,pz)
        title('Z PSD')
        xlabel('log frequency (Hz)')
