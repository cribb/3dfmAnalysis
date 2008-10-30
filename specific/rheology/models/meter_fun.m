function y = meter_model_fun(init_cond, sigma, eta_apparent)
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
    sigma2   = init_cond(1);
    alpha    = init_cond(2);
    eta_zero = init_cond(3);
    eta_inf  = init_cond(4);

    % go to town.  this is our fitting function
    eta_apparent_fit = eta_inf + (eta_zero - eta_inf) ./ ( (1 + (sigma/sigma2).^(alpha-1)));
    y = eta_apparent_fit;
    
%     weights = [1:length(eta_apparent)]';
%     y = (eta_apparent_fit - eta_apparent) ./ eta_apparent_fit;
    
%     x = ((n-1)/m).*(log(eta_zero) + m.*log(lambda*gamma_dot));
    

