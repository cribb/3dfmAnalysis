function x = randwalk(len,p)
% 3DFM function  
% Math 
% last modified 06/20/03 
%  
% This function produces a discrete-time, discrete-space random walk.
%  
%  [v] = randwalk(len, p);  
%   
%  where "len" is the desired length of the output dataset
%        "p" is a bias parameter between 0 and 1 
%  
%  Notes:  
%  - output matrix is 2 columns, 1st column is time, 2nd column is position
%  - use parameter value of 0.5 for unbiased random walk (e.g. p = q = 0.5)
%   
%  05/06/04 - created; jcribb.  
%  

% randwalk(len,p)
% len = length of data vector,  p = bias (0 - 1) (e.g. p = q = 0.5)

% randomize state of random number generator
rand('state',sum(100*clock));

r = rand(len,1);

x(1) = 0;
for n=2:len
    if r(n) > p
        x(n) = x(n-1) - 1;
    else
        x(n) = x(n-1) + 1;
    end
end

x=x';
