function [eta_zero, eta_inf, lambda, m, R_square] = cross_model_fit(gamma_dot, eta_apparent, report)
% CROSS_MODEL_FIT Fits input data to Cross type rheological model that fits material's apparent viscosity as a function of shear rate
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford)
%  
% This function fits input data to a Cross type rheological model that fits
% a materials apparent viscosity as a function of shear rate. The fitting parameters
% as well as an R_square fitness value are provided as outputs.
%  
%  [eta_zero, eta_inf, lambda, m, R_square] = cross_model_fit(gamma_dot, eta_apparent, report);  
%   
%  where "gamma_dot" contains the input shear rates [s^-1].
%        "eta_apparent" contains the apparent viscosity at the input shear rate.
%        "report" is 'y' or 'n', default 'y', for reporting results in plot
%                 and tabular form.
%        "eta_zero" is the spring constant in units of [N m^-1] 
%        "eta_inf" is the damper parallel to the spring in [N s m^-1] 
%        "lambda" is time constant for switch to thinning from non-thinning
%        regime
%        "m" is powerlaw slope of thinning regime
%        "R_square" is the a measure of fitness.
%

    % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 10000, ...
                       'Diagnostics', 'on', ...
                       'TolFun', 1e-12, ...
                       'MaxIter', 50000, ...
                       'TolX', 1e-7);

	% initial guess
    m        = -0.8;
    lambda   = 0.05;
    eta_zero = 10;
    eta_inf  = 0.01;

% % %     % normalize t and x
% % %     t = t - min(t);    
% % %     x = x - min(x);
    
    init_cond = [m lambda eta_zero eta_inf];
    
	[fit, resnorm, residuals] = lsqcurvefit('cross_model_fun', init_cond, gamma_dot, eta_apparent,[],[],options);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((eta_apparent - mean(eta_apparent)).^2);
	R_square = 1 - sse/sst;
	    
    m        = fit(1);
	lambda   = fit(2);
	eta_zero = fit(3);
	eta_inf  = fit(4);

    % go to town.  this is our fitting function
    eta_apparent_fit = (eta_zero - eta_inf) ./ (1+(lambda*gamma_dot).^ m) + eta_inf;
    
    if findstr(report, 'y')
        figure;
        loglog(gamma_dot, eta_apparent, '.', gamma_dot, eta_apparent_fit, 'r-');
    end
    
%     fit_params = [k0 k1 gamma0 gamma1];
    
    return;

