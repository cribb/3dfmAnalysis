function [k0,k1,gamma0,gamma1,R_square] = membrane_step_response(t, y)

    % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 20000*2, ...
                       'Diagnostics', 'off', ...
                       'TolFun', 1e-13, ...
                       'MaxIter', 2000, ...
                       'ShowStatusWindow', 'off');

	% initial guess
	k0     = 10;
	k1     = 3;
	gamma0 = 200;
	gamma1 = 1000;

    % normalize t and y
    t = t - min(t);    
    y = y - min(y);
    
    x0 = [k0 k1 gamma0 gamma1];
	
	[fit, resnorm, residuals] = lsqcurvefit('membrane_step_response_fun', x0, t, y, 0, [], options);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((y - mean(y)).^2);
	R_square = 1 - sse/sst;
	
    
	k0     = fit(1);
	k1     = fit(2);
	gamma0 = fit(3);
	gamma1 = fit(4);
    
    fprintf('k0 = %g \t\t k1 = %g \t\t gamma0 = %g \t\t gamma1 = %g \n',k0, k1, gamma0, gamma1);
       
	tau = gamma1 * (k0 + k1) / (k0 * k1);
    
	% go to town.  this is our fitting function
	yfit = (1 / k0) * ( 1 - k1 / (k0 + k1) * exp(-t / tau)) + t/gamma0;

    figure;
    plot(t, y, '.'); 
    figure;
    plot(t, y, '.', t, yfit, 'r');
    
    fit_params = [k0 k1 gamma0 gamma1];