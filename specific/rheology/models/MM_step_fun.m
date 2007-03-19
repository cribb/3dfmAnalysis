function x = MM_step_fun(x0, t, ct);
% 3DFM function  
% Rheology
% last modified 26-Oct-2006 
%  
% This is the fitting function for MM_step_fit. 
%  
%  x = MM_step_fun(x0, t, ct); 
%   
%  where "x0" contains the parameters passed from lsqcurvefit.
%        "t" contains the step response values for the inputted data.
%        "ct" contains the step response values for the inputted data. 
%        "x" contains the fitted parameter values for x0. 
%


K = x0(1);
D = x0(2);

% must normalize for beginning of pull
t = t - t(1);
t1 = 0;

warning off MATLAB:divideByZero;

    x = 1/K + (t-t1)/D;

warning on MATLAB:divideByZero;
 


