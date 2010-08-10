function [K, D1, D2, R_square] = jeffrey_step_fit(t, y, report)
% JEFFREY_STEP_FIT fits input data to a jeffrey rheological model's step response, provides fitting parameters and R^2 fitness value
%
% 3DFM function
% specific\rheology\models
% last modified 11/20/08 (krisford) 
%  
% This function fits input data to a jeffrey rheological 
% model's step response and provides fitting parameters
% as well as an R_square fitness value.
%  
%  [K, D1, D2, R_square] = jeffrey_fit_step(t, y, report);  
%   
%  where "t" contains the time values for the inputted data.
%        "y" contains the step response values for the inputted data.
%        "report" is 'y' or 'n', default 'y', for reporting results in plot
%                 and tabular form.
%        "K" is the spring constant in units of [N m^-1] 
%        "D1" is the damper parallel to the spring in [N s m^-1] 
%        "D2" is the damper in series with K & D1 (voight body) in [N s m^-1] 
%        "R_square" is the a measure of fitness.
%
% XXX Add a fitness structure in the future that contains resdiual analysis
%     instead of just Rsquare values that are not worth much.
%

    if nargin < 3 | isempty(report); report = 'y'; end

   % set parameters for the options structure sent to lsqcurvefit.
	options = optimset('MaxFunEvals', 20000*2, ...
                       'Diagnostics', 'off', ...
                       'TolFun', 1e-13, ...
                       'MaxIter', 2000, ...
                       'ShowStatusWindow', 'off');
 K= 0.7;
 D1 =0.07;
 D2 = 15;
	% initial guess
%     K  = 0.01;
%     D1 = 0.5;
%     D2 = 2;
%     
    % normalize t and y
    t = t - min(t);    
%     y = y - min(y);
    
    x0 = [K D1 D2];
	
	[fit, resnorm, residuals] = lsqcurvefit('jeffrey_step_fun', x0, t, y, 0, [], options);

    % standard deviation of measurements == rms of the residuals
	rms_residuals = rms(residuals);
	
	% compute R-square
	sse = resnorm;      % measure of the total deviation of the response
                        % values from the fit to the response values
	sst = sum((y - mean(y)).^2);
	R_square = 1 - sse/sst;
	
	K  = fit(1);
	D1 = fit(2);
	D2 = fit(3);
    
	tau = D1/K;
    t1 = 0;

    % go to town.  this is our fitting function
    yfit = (1/K + (t-t1)/D2 - 1/K*exp(-K*(t-t1)/D1));

    if findstr(report, 'y')
        fprintf('K = %g \t\t D1 = %g \t\t D2 = %g \t\t R^2 = %g\n', K, D1, D2, R_square);
       
        figure;
        plot(t, y, '.', t, yfit, 'r');        
    end
    
    fit_params = [K D1 D2];
    
    
