function v = randwalkCTDS(len, alpha, beta)
% 3DFM function  
% Math 
% last modified 05/06/04 
%  
% This function produces a continuous-time, discrete-space random walk.
%  
%  [v] = randwalkCTDS(len, alpha, beta);  
%   
%  where "len" is the desired length of the output dataset
%        "alpha" is a parameter between 0 and 1 
%		     "beta" is a parameter between 0 and 1
%  
%  Notes:  
%  - output matrix is 2 columns, 1st column is time, 2nd column is position
%  - use parameter value of 0.5 for unbiased random walk
%   
%  05/06/04 - created; jcribb.  
%  

% randomize state of random number generator
rand('state',sum(100*clock));

n = 0; t = 0;

R = rand(len,1);

T = -log(R) / (alpha + beta);

for a=2:len
    if R(a) < alpha
        n(a)=n(a-1)+1;
    else
        n(a)=n(a-1)-1;
    end
    t(a) = t(a-1) + T(a);
end

v = [t ; n]';

