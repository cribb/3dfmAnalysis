function [K, n, R_square] = powerlaw_model_fit(gamma_dot, eta_apparent, report)
% POWERLAW_MODEL_FIT Fits input data to a Cross type rheological model that fits material's apparent viscosity as a function of shear rate
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford)
%  
% This function fits input data to a Cross type rheological model that fits
% a materials apparent viscosity as a function of shear rate. The fitting parameters
% as well as an R_square fitness value are provided as outputs.
%  
%  [K, n, R_square] = powerlaw_model_fit(gamma_dot, eta_apparent, report);
%   
%  where "gamma_dot" contains the input shear rates [s^-1].
%        "eta_apparent" contains the apparent viscosity at the input shear rate.
%        "report" is 'y' or 'n', default 'y', for reporting results in plot
%                 and tabular form.
%        "K" is the consistency index
%        "n" is the power law slope 
%        "R_square" is the a measure of fitness.
%
    % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 1000000, ...
                       'Diagnostics', 'on', ...
                       'TolFun', 1e-30, ...
                       'MaxIter', 20000, ...
                       'TolX', 1e-8, ...
                       'ShowStatusWindow', 'on');

	% initial guess
    K = 10;
    n  = 0;
    
    init_cond = [K n];
    
	[fit, resnorm, residuals] = lsqcurvefit('powerlaw_model_fun', init_cond, gamma_dot, eta_apparent);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((eta_apparent - mean(eta_apparent)).^2);
	R_square = 1 - sse/sst;
	    
	K = fit(1);
	n = fit(2);

    % go to town.  this is our fitting function
    eta_apparent_fit = K * gamma_dot.^(n-1);
    
    if findstr(report, 'y')
%         figure;
%         loglog(gamma_dot, eta_apparent, '.'); 
        figure;
        loglog(gamma_dot, eta_apparent, '.', gamma_dot, eta_apparent_fit, 'r-');
    end
    
%     fit_params = [k0 k1 gamma0 gamma1];
    
    return;

