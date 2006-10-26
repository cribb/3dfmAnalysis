function [t, ct] = jeffrey_model_step(K, D1, D2, t0, tend);
% 3DFM function  
% Rheology
% last modified 26-Oct-2006 
%  
% This function returns a jeffrey rheological model step response for the
% provided parameters. 
%  
%  [K, D1, D2, R_square] = jeffrey_fit_step(t, y);  
%   
%  where "K"    is the spring constant in units of [N m^-1] 
%        "D1"   is the damper parallel to the spring in [N s m^-1] 
%        "D2"   is the damper in series with K & D1 (voight body) in [N s m^-1] 
%        "t0"   is the starting time
%        "tend" is the ending time
%        "t"    contains the time values for the input parameters.
%        "ct"   contains the step response values for the input parameters.
%
%


warning off MATLAB:divideByZero;

  t = t0 : (tend-t0)/512 : tend;

  ct = (1/K + (t-t1)/D2 - 1/K*exp(-K*(t-t1)/D1));

warning on MATLAB:divideByZero;
 
