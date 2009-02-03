function y = carreau_chhabra_fun(init_cond, gamma_dot, eta_apparent)
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
    n        = init_cond(1);
    lambda   = init_cond(2);
    eta_zero = init_cond(3);

    % go to town.  this is our fitting function
    eta_apparent_fit = eta_zero  .* ( (1+ (lambda*gamma_dot).^2) .^ ((n-1)/2));
    
    weights = [1:length(eta_apparent)]';
    y = (eta_apparent_fit - eta_apparent) ./ eta_apparent_fit;
    
%     x = ((n-1)/m).*(log(eta_zero) + m.*log(lambda*gamma_dot));
    

