function v = cumvar(x,alg)
% 3DFM function  
% Math 
% last modified 04/08/04 
%  
% This function computes the cumulative variance for a vector x.
%  
%  v = cumvar(x, alg);  
%   
%  where "x" is any vector.
%        "alg" is desired algorithm, 'fast' or 'slow'
%  
%  Notes:  
%  - Useful in stochastic model analysis.
%  - 'fast' and 'slow' algorithms give slightly different results
%   
%  04/08/04 - created; jcribb  
%   
%  

if findstr(alg,'fast')
	%warning off MATLAB:divideByZero;
	
	N = [1:length(x)]';

    warning off;
        w = 1./(N-1);
        w(1) = 0;
    warning on;
    
	xn = (x - cummean(x)).^2;

	v =  w .* cumsum(xn);
    
elseif findstr(alg, 'slow')

    for k=1:length(x)    
        v(k) = var(x(1:k));
    end
    v=v';
    
else
    error('Must provide an algorithm.');
end