function v = wlc(r, F)
% 

% set parameters for the options structure sent to lsqcurvefit.
options = optimset('MaxFunEvals', 40000, ...
                   'Diagnostics', 'off', ...
                   'TolFun', 1e-5, ...
                   'MaxIter', 4000, ...
                   'TolX', 1e-5, ...
                   'ShowStatusWindow', 'on');

% Physical constants for model               
T = 293;
k = 1.3807e-23;
               
% initial guess... let's use random numbers with no negatives.
Lp = 50e-9; % literature value for persistence length of DNA is ~50nm.
Lc = 12e-6; % First guess for contour length of DNA.
offset = 0;

x0 = [Lp Lc offset];  % x0 is a row vector containing all of the fitting parameters

[fit, resnorm, residuals] = lsqcurvefit('wlc_model_response_fun', x0, r, F, 0, 1, options);

Lp = exp(fit(1));
Lc = exp(fit(2));
offset = exp(fit(3));

% standard deviation of measurements == rms of the residuals
rms_residuals = rms(residuals);

% compute R-square
sse = resnorm;      % measure of the total deviation of the response
                    % values from the fit to the response values
sst = sum((F - mean(F)).^2);
R_square = 1 - sse/sst;

log_fit_F = log((k*T/Lp) * (.25*(1-(r+offset)/Lc).^-2 - .25 + (r+offset)/Lc));
fit_F = exp(log_fit_F);

    % plot fit results
	figure;
	plot(r, F, '.', r, fit_F, 'r');
	xlabel('radial displacement [m]');
	ylabel('Force [N]');
	legend('data', 'fit');

% setup outputs
v.Lp = Lp;
v.Lc = Lc;
v.offset = offset;

