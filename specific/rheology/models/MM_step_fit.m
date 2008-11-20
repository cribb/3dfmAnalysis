function [K, D, R_square] = MM_step_fit(t, y, report)
% MM_STEP_FIT fits input data to jeffrey rheological model's step response and provides fitting parameters
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford)
%  
% This function fits input data to a jeffrey rheological 
% model's step response and provides fitting parameters
% as well as an R_square fitness value.
%  
%  [K, D, R_square] = MM_fit_step(t, y);  
%   
%  where "t" contains the time values for the inputted data.
%        "y" contains the step response values for the inputted data.
%        "report" is 'y' or 'n', default 'y', for reporting results in plot
%                 and tabular form.
%        "K" is the spring constant in units of [N m^-1] 
%        "D" is the damper parallel to the spring in [N s m^-1] 
%        "R_square" is the a measure of fitness.
%

% XXX Add a fitness structure in the future that contains resdiual analysis
%     instead of just an Rsquare value.. They are not worth much.
%

    if nargin < 3 | isempty(report); report = 'y'; end

   % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 20000*2, ...
                       'Diagnostics', 'off', ...
                       'TolFun', 1e-13, ...
                       'MaxIter', 2000, ...
                       'ShowStatusWindow', 'off');

	% initial guess
    K  = 1 / range(y);
    D = max(t) / 2;
    
    % normalize t and y
    t = t - min(t);    
    y = y - min(y);
    
    x0 = [K D];
	
	[fit, resnorm, residuals] = lsqcurvefit('MM_step_fun', x0, t, y, 0, [], options);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((y - mean(y)).^2);
	R_square = 1 - sse/sst;
	
	K = fit(1);
	D = fit(2);
    
	tau = D/K;
    t1 = 0;

    % go to town.  this is our fitting function
    yfit = 1/K + (t-t1)/D;
    
    if findstr(report, 'y')
        fprintf('K = %g \t\t D = %g \t\t R^2 = %g\n', K, D, R_square);
        
        figure;
        plot(t, y, '.', t, yfit, 'r');
    end
    
    fit_params = [K D];
    
    
