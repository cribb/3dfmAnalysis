function [J,tau,R_square] = relaxation_time(t, xt, n, plot_results)
% RELAXATION_TIME This function computes n relaxation time constants for vector x(t).   
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford) 
%  
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


if nargin < 4 | isempty(plot_results)
    logentry('Plotting results by default.');
    plot_results = 'on';
end

% set parameters for the options structure sent to lsqcurvefit.
options = optimset('MaxFunEvals', 20000*2*n, ...
                   'Diagnostics', 'off', ...
                   'TolFun', 1e-13, ...
                   'MaxIter', 2000 );

logentry(['Fitting for Kelvin-Voight, ' num2str(n) ' modes.']);

% normalize recovery to start at 1 and end at 0
if (length(xt) > 10) && sum(xt(1:5)) < sum(xt(end-5:end))
        xt = -xt;
        xt = xt - mean(xt(end-5:end));
elseif (length(xt)<10) && xt(1) < xt(end)
        xt = -xt;       
        xt = xt - xt(1);
end

xt = xt / max(xt);
t = t - min(t);

% design the fitting routine

% randomize state of random number generator
rand('state',sum(100000*clock));

% initial guess for J... because of normalization, the sum of amplitudes
% should be equal to one.
if n > 1
    J   = ones(1,n-1)/n;    % the last J is constrained
else
    J = 1;
end

% initial guesses for tau
if length(t) > 5   % need a minimum array length
    for k = 1:n
        switch k
            case 1
                fit = polyfit(t(1:3), xt(1:3), 1);
                tintercept = -fit(2) / fit(1);
                tau(1,k) = tintercept;
            otherwise
                tau(1,k) = 1.5*k*tau(1,1);
        end
    end
else
    J(1,1:n) = NaN;
    tau(1,1:n) = NaN;
end

x0 = [J tau];  % x0 is a row vector with one less coefficient than 
               % time constants. (J is constrained such that sum(J) == 1)

try
    [fit, resnorm, residuals, exitflag, output] = lsqcurvefit('relaxtime_fun', x0, t, xt, zeros(size(x0)), [], options);
    % [fit, resnorm, residuals] = lsqnonlin('relaxtime_fun', x0, zeros(size(x0)), [], options, t, xt);
catch
    J = NaN;
    tau = NaN;
    R_square = NaN;
    return;
end


% HOW GOOD WAS THE FIT????

% residuals = data - fit ...difference between the response value and the
% predicted response value

% standard deviation of measurements == rms of the residuals
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
if length(tau) > 1
    J(length(tau)) = 1 - sum(J);
end

% rest of this stuff is for plotting fit vs data
for k = 1 : length(J)
    if ~exist('fit_xt')
        fit_xt = J(k)*exp(-t/tau(k));
    else
        fit_xt = fit_xt + J(k)*exp(-t/tau(k));
    end
end

logentry(['Resulting relative J magnitudes: ' num2str(J), '.']);
logentry(['Resulting relaxation times (tau): ' num2str(tau) '.']);
logentry(['Goodness of fit: ' num2str(R_square) '.']);

if strcmp(plot_results, 'on')
    figure;
    plot(t, xt, '.', t, fit_xt, 'r');
    xlabel('time [s]');
    ylabel('normalized recovery');
    legend('data', 'fit');
end

%%%%
%% extraneous functions
%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'relaxation_time: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
