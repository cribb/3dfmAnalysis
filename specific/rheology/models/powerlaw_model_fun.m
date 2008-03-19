function eta_out = powerlaw_model_fun(init_cond, gamma_dot, eta_apparent)
% 3DFM function  
% Rheology
% last modified 2008.03.19
%  
% This is the fitting function for cross_model_fit. 
%  
%  eta_out = powerlaw_model_fun(init_cond, gamma_dot, eta_apparent);
%   
%  where "init_cond" contains the parameters passed from lsqcurvefit.
%        "gamma_dot" contains the input shear rates [s^-1].
%        "eta_apparent" contains the apparent viscosity at the input shear rate.
%        "eta_out" contains the fitted parameter values for init_cond. 
%


    % set guesses for fitting parameters
    K = init_cond(1);
    n = init_cond(2);

    % go to town.  this is our fitting function
   eta_out = K * gamma_dot.^(n-1);
    
    
%     x = x_zero .* exp( - (t./tau) .^ (1./h) );

