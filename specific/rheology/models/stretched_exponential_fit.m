function [x_zero, tau, h, R_square] = stretched_exponential_fit(t, x, report)
% STRETCHED_EXPONENTIAL_FIT Fits input data to a Cross type rheological model that fits material's apparent viscosity as a function of shear rate
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford)

    % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 30000*2, ...
                       'Diagnostics', 'on', ...
                       'TolFun', 1e-26, ...
                       'MaxIter', 20000, ...
                       'ShowStatusWindow', 'on');

	% initial guess
	x_zero = 1;
	tau    = 1;
	h      = 0.5;

    % normalize t and x
    t = t - min(t);    
    x = x - min(x);
    
    init_cond = [x_zero tau h];
    
	[fit, resnorm, residuals] = lsqcurvefit('stretched_exp_fun', init_cond, t, x);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((x - mean(x)).^2);
	R_square = 1 - sse/sst;
	    
	x_zero = fit(1);
	tau    = fit(2);
	h      = fit(3);

    % go to town.  this is our fitting function
	xfit = x_zero .* exp( - (t/tau) .^ 1/h );
    
    if findstr(report, 'y')
        figure;
        plot(t, x, '.'); 
        figure;
        plot(t, x, '.', t, xfit, 'r');
    end
    
%     fit_params = [k0 k1 gamma0 gamma1];
    
    return;

