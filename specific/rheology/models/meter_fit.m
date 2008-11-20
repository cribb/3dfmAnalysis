function [eta_zero, eta_inf, alpha, sigma2, R_square, eta_apparent_fit] = meter_fit(sigma, eta_apparent, report)
% METER_FIT Fits input data to a Cross type rheological model that fits material's apparent viscosity as a function of shear rate
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford)
%  
% This function fits input data to a Cross type rheological model that fits
% a materials apparent viscosity as a function of shear rate. The fitting parameters
% as well as an R_square fitness value are provided as outputs.
%  
%  [eta_zero, eta_inf, lambda, m, n, R_square, eta_fit] = carreau_model_fit(gamma_dot, eta_apparent, report);  
%   
%  where "gamma_dot" contains the input shear rates [s^-1].
%        "eta_apparent" contains the apparent viscosity at the input shear rate.
%        "report" is 'y' or 'n', default 'y', for reporting results in plot
%                 and tabular form.
%        "eta_zero" is the spring constant in units of [N m^-1] 
%        "eta_inf" is the damper parallel to the spring in [N s m^-1] 
%        "lambda" is time constant for switch to thinning from non-thinning
%        regime
%        "m" is index that controls the width of the thinning regime
%        "n" is  related to the power law such that (n-1) is equal to
%        powerlaw slope.
%        "R_square" is the a measure of fitness.
%

    % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 100000, ...
                       'Diagnostics', 'on', ...
                       'TolFun', 1e-17, ...
                       'MaxIter', 500000, ...
                       'TolX', 1e-10, ...
                       'ShowStatusWindow', 'on');

	% initial guess
    sigma2   = 0.1;
    alpha    = 0.15;
    eta_zero = eta_apparent(1);
    eta_inf  = eta_apparent(end);

    init_cond = [sigma2 alpha eta_zero eta_inf];
    
	[fit, resnorm, residuals] = lsqcurvefit('meter_fun', init_cond, sigma, eta_apparent, [], [], options);
% 	[fit, resnorm, residuals] = lsqnonlin('meter_fun', init_cond, [], [], options, sigma, eta_apparent);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((eta_apparent - mean(eta_apparent)).^2);
	R_square = 1 - sse/sst;
	    
    sigma2   = fit(1);
    alpha    = fit(2);
	eta_zero = fit(3);
	eta_inf  = fit(4);
    
    % go to town.  this is our fitting function
    eta_apparent_fit = eta_inf + (eta_zero - eta_inf) ./ ( (1 + (sigma/sigma2).^(alpha-1)));
    
    if findstr(report, 'y')
        figure;
        loglog(sigma, eta_apparent, '.', sigma, eta_apparent_fit, 'r-');
    end
    
%     fit_params = [k0 k1 gamma0 gamma1];
    
    return;

