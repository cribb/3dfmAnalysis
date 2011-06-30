function [eta_zero, lambda, n, R_square, eta_apparent_fit] = carreau_chhabra_fit(gamma_dot, eta_apparent, report)
% 3DFM function  
% Rheology
% last modified 2008.03.19
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
                       'TolX', 1e-10);

	% initial guess
    n        = 0.2;
    lambda   = 0.5;
    eta_zero = eta_apparent(1);
    
% % %     % normalize t and x
% % %     t = t - min(t);    
% % %     x = x - min(x);
    
    init_cond = [n lambda eta_zero];
    lower_bounds = [-2 0 1e-4];
    upper_bounds = [2 Inf Inf];
    
% 	[fit, resnorm, residuals] = lsqcurvefit('carreau_model_fun', init_cond, gamma_dot, eta_apparent, [], [], options);
	[fit, resnorm, residuals] = lsqnonlin('carreau_chhabra_fun', init_cond, lower_bounds, upper_bounds, options, gamma_dot, eta_apparent);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((eta_apparent - mean(eta_apparent)).^2);
	R_square = 1 - sse/sst;
	    
    n        = fit(1);
	lambda   = fit(2);
	eta_zero = fit(3);
    
    % go to town.  this is our fitting function
    eta_apparent_fit = eta_zero  .* ( (1+ (lambda*gamma_dot).^2) .^ ((n-1)/2));
    
    
    if findstr(report, 'y')
        figure;
        loglog(gamma_dot, eta_apparent, '.', gamma_dot, eta_apparent_fit, 'r-');
    end
    
%     fit_params = [k0 k1 gamma0 gamma1];
    
    return;

