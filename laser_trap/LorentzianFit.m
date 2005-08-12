function spring_k = LorentzianFit(freq, psd, eta, a)

if nargin < 4 | isempty(a)
	a = .5e-6;          % bead radius in m
end

if nargin < 3 | isempty(eta)
	eta = .026;         % viscosity in Pa s
end

% physical constants
T = 298;
K = 1.3807e-23;
gamma = 6*pi*eta*a;

% set parameters for the options structure sent to lsqcurvefit.
options = optimset('MaxFunEvals', 20000, ...
                   'Diagnostics', 'off', ...
                   'TolFun', 1e-120, ...
                   'TolX', 1e-60, ...
                   'MaxIter', 200000, ...
                   'ShowStatusWindow', 'on');


% fc = k/(2*pi*gamma)
fc = 30;  % inital guess for frequency cutoff

x0 = [fc]; % building the input vector

log_index = [30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000 2000];

logsamp_freq = freq(log_index);
logsamp_psd  = psd(log_index);

[fit, resnorm, residuals] = lsqcurvefit('LorentzianFit_fun',x0,logsamp_freq,logsamp_psd,0,[],options);

% get outputted fitting values
fc = fit(1);

% use fitted values to estimate equation previously used in fit
fit_psd = (K*T) ./ (gamma*(pi^2)*(fc^2 + logsamp_freq.^2));

%%%%%%%%%%%%%%%%%%%%%%%%  figure error value  %%%%%%%%%%%%%%%%%%%%%%%%%%%
rms_residuals = rms(residuals);

sse = resnorm;      % measure of the total deviation of the response values from the fit to the response values

sst = sum((psd - mean(psd)).^2);

% R square means the fit explains ___% of the total variation in the data about the average.
R_square = 1 - sse/sst;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use fc to determine the spring constant of the trap
% spring_k = fc/(2*pi*gamma);

spring_k = ((2*K*T)/(pi*fit_psd(1)*fc)) * 1e6;  %'pN/um'

figure;
loglog(freq, psd, '.', logsamp_freq, logsamp_psd, '*k', logsamp_freq, fit_psd, 'r');
title('fitting the cutoff freq');
xlabel('Freq (Hz)');
ylabel('nm/rt(Hz)');

