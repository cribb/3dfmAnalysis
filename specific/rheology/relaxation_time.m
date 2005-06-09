function [tau,J] = relaxation_time(t, xt, n)
% 3DFM function  
% Rheology 
% last modified 06/09/2005 
%  
% This function computes n relaxation time constants for vector x(t).
%  
%  [outputs] = relaxation_time(t, xt, n);  
%   
%  where "t" is a vector for time or other independent variable
%        "xt" is a vector for dependent variable, like compliance
%		 "n" is the fit order (or, how many time constants do you want?)
%  
%  Notes:  
%   
%  - Be warned that computing more than 3 time constants takes minutes.
%  - Based on a Kelvin-Voight relaxation viscoelastic solid-model.  Because
%  it assumes 100% recovery, the input, xt, is nomalized by subtracting the
%  minimum value and then dividing by the maximum value.  This results in a
%  x(t) function whose initial value is one (and thus the sum of the
%  coefficients, J, is one) and final value is zero.  Scaling in this way
%  does not affect the value of the relaxation times.
%   
%  06/09/05 - created.  
%  

% set parameters for the options structure sent to lsqcurvefit.
options = optimset('MaxFunEvals', 4000*2*n, ...
                   'Diagnostics', 'off', ...
                   'TolFun', 1e-8, ...
                   'MaxIter', 1000, ...
                   'ShowStatusWindow', 'off');

% normalize recovery to start at 1 and end at 0
xt = xt - min(xt);
xt = xt / max(xt);

% design the fitting routine

% randomize state of random number generator
rand('state',sum(100000*clock));

% initial guess... let's use random numbers with no negatives.
J   = rand(1,n-1);    % the last J is constrained
tau = rand(1,n);

x0 = [J tau];  % x0 is a row vector with one less coefficient than 
               % time constants. (J is constrained such that sum(J) == 1)

[fit, resnorm, residuals] = lsqcurvefit('relaxtime_fun', x0, t, xt, [], [], options);


% HOW GOOD WAS THE FIT????

% residuals = data - fit ...difference between the response value and the
% predicted response value

% rms of the residuals
rms_residuals = rms(residuals);

% compute R-square
sse = resnorm;      % measure of the total deviation of the response
                    % values from the fit to the response values
sst = sum((xt - mean(xt)).^2);
R_square = 1 - sse/sst;

% Set up optimized output values for coefficients (J) and time constants
% (tau) by parsing the vector returned by lsqcurvefit...
foo = floor(length(x0)/2);
tau = fit(foo+1:end);
J = fit(1:foo);
J(length(tau)) = 1 - sum(J);

% rest of this stuff is for plotting fit vs data
for k = 1 : length(J)
    if ~exist('fit_xt')
        fit_xt = J(k)*exp(-t/tau(k));
    else
        fit_xt = fit_xt + J(k)*exp(-t/tau(k));
    end
end

figure(1);
subplot(2,2,1);
plot(t, xt, '.', t, fit_xt, 'ro');
subplot(2,2,2);
loglog(t, xt, '.', t, fit_xt, 'ro');
subplot(2,2,3);
plot(t, residuals, '.');
