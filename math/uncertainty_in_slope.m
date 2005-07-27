function v = uncertainty_in_slope(x, y, fit)
% 3DFM function  
% Math 
% last modified 07/25/05
%  
% Computes the uncertainty of the slope in a linear fit.  Reference used
% for this computation is John Taylor's _An Introduction to Error
% Analysis_, Section 8.4, page 159. 1982.
%  
%  [v] = uncertainty_in_slope(x, y, fit);  
%   
%  where "v" is the uncertainty measurement.
%        "x" is a vector containing x-coordinates. 
%        "y" is a vector containing y-coordinates.
%		 "fit" is the fitting vector outputted by polyfit, or 
%              in the form [slope intercept].        
%  
%  07/25/05 - created. (jcribb)
%

    N = length(x);
    
    B = fit(1);
    A = fit(2);
    
    delta = N * sum(x.^2) - sum(x)^2;
    
    sy2 = 1/(N-2) * sum( (y - A - B*x) .^ 2);
    
    sB2 = N * sy2 / delta;
    
    v = sqrt(abs(sB2));
    
    