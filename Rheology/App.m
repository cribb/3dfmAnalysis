function v = App(w, psd)
% This function computes the imaginary compliance from the PSD
% given to it.
%
% v = App(w, psd)
%
% where w is a vector of frequencies, omega, in rad/sec
% and psd is the vector containing the PSD for frequencies, w
%
% Notes:  f(Hz) = w / 2*pi
%         a''(w) = (w * psd) / (4 * kb * T)
% 
% created 10/30/02


	temp = 298; %Kelvin;
	const_boltzmann = 1.3806503e-23; %http://physics.nist.gov/cgi-bin/cuu/Value?k

	App= (psd .* w) / (4 * const_boltzmann * temp);
	
	v=App;
