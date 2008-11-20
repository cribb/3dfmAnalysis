function y = kkint(zeta, omega, omega_table, app_table)
% KKINT Called by quad to get a single value of the function we integrate for Kramers-Kronig   
%
% 3DFM function
% specific\rheology\kkr
% last modified 11/20/08 (krisford)
%
% This function is called by quad to get a single value of the function 
% we integrate for Kramers-Kronig.
%
% y = kkint(zeta, omega, omega_table, app_table)
%
% Zeta is the current value of the integration variable. 
% omega is the frequency we're evaluating the integral for. 
% omega_table is the vector of values of omega for which app
% 	has been tabulated. 
% app_table is the tabulated values of app.
%


app_zeta = interp1(omega_table, app_table, zeta);

y = (2/pi) * (zeta .* app_zeta) ./ (zeta.^2 - omega.^2);
