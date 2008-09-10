function x = carreau_model_fun(init_cond, gamma_dot, eta_apparent)
% 3DFM function  
% Rheology
% last modified 2008.03.19
%  
% This is the fitting function for cross_model_fit. 
%  
%  x = carreau_model_fun(init_cond, gamma_dot, eta_apparent);
%   
%  where "init_cond" contains the parameters passed from lsqcurvefit.
%        "gamma_dot" contains the input shear rates [s^-1].
%        "eta_apparent" contains the apparent viscosity at the input shear rate.
%        "x" contains the fitted parameter values for init_cond. 
%


    % set guesses for fitting parameters
    m        = init_cond(1);
    n        = init_cond(2);
    lambda   = init_cond(3);
    eta_zero = init_cond(4);
    eta_inf  = init_cond(5);

    % go to town.  this is our fitting function
    x = (eta_zero - eta_inf) .* ( (1+lambda*gamma_dot) .^ ((n-1)/m)) + eta_inf;
    
    

