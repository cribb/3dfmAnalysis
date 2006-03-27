close all;
clear all;

% sucrose molar concentration
sucrose_molar_conc = 2;
bead_diameter = 1e-6;
% temperature
T = [20 : 0.5 : 85];

% duration of experiment (observation time)
t = [1e-5 : 1e-4 : 1e-1]';

% first get the sucrose viscosities as these are dependent on temperature
for k = 1:length(T); 
    visc(k) = sucrose_viscosity(sucrose_molar_conc, T(k), 'C');
end;

% compute diffusion coefficients and then mean-square displacements
k = 1.38e-23;  % [J/K] Boltzmann Constant
D = (k * T) ./ (6 * pi * visc * bead_diameter/2);
rms_disp = sqrt(2 * D' * t');

figure;
plot(T, visc*1000);
xlabel('Temperature (^oC)');
ylabel('Viscosity (cP)');
title([num2str(sucrose_molar_conc) 'M sucrose- Dep. of Visc. on Temp']);
pretty_plot;

figure; 
imagesc(t*1e3, T, rms_disp*1e9);
colormap(flipud(hot(64)));
colorbar;
set(gca, 'YDir', 'normal');
xlabel('observation time (msec)');
ylabel('Temperature (^oC)');
title([num2str(sucrose_molar_conc) 'M sucrose- theo mean displacements (nm)']);
pretty_plot;
hold on;
[C,h] = contour(t*1e3, T, rms_disp*1e9, [4 16], 'k');
clabel(C);
hold off;
