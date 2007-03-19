function x = jeffrey_step_fun(x0, t, ct);
% 3DFM function  
% Rheology
% last modified 26-Oct-2006 
%  
% This is the fitting function for jeffrey_step_fit. 
%  
%  x = jeffrey_step_fun(x0, t, ct); 
%   
%  where "x0" contains the parameters passed from lsqcurvefit.
%        "t" contains the step response values for the inputted data.
%        "ct" contains the step response values for the inputted data. 
%        "x" contains the fitted parameter values for x0. 
%


K  = x0(1);
D1 = x0(2);
D2 = x0(3);

% must normalize for beginning of pull
t = t - t(1);
t1 = 0;

warning off MATLAB:divideByZero;

    x = (1/K + (t-t1)/D2 - 1/K*exp(-K*(t-t1)/D1));

warning on MATLAB:divideByZero;
 


