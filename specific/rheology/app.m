function v = App(w, psd)
% 3DFM function
% Rheology
% last modified 07/28/03
%
% This function computes the imaginary compliance 
% from the PSD passed to it.
%
% v = App(w, psd)
%
% where w is a vector of frequencies, omega, in rad/sec
% and psd is the vector containing the PSD for frequencies, w
%
% Notes:  f(Hz) = w / 2*pi
%         a''(w) = (w * psd) / (4 * kb * T)
% 
% 10/30/02 - created
% 07/28/03 - expanded comments and help information


	temp = 298; % Kelvin;
	const_boltzmann = 1.3806503e-23; %http://physics.nist.gov/cgi-bin/cuu/Value?k

	App = (psd .* w) / (4 * const_boltzmann * temp);
	
	v = App;

