function Jt = relaxtime_fun(x0, t)
% 3DFM function  
% Rheology 
% last modified 06/09/05 
%  
% This is the fitting function for the "relaxation_time" function.  Try
% "help relaxation_time" for more details.
%  
%  Jt = relaxtime_fun(x0, t);  
%   
%  where "x0" is vector of parameters awaiting optimization
%        "t" is time vector information for the fitting function, Jt 
%       "Jt" is the evaluation of fitting function on t with parameters x0.
%
%  Notes:     
%  - You probably don't want this function.  It is used by "relaxation_time". 
%   
%  06/09/05 - created; jcribb.


% set guesses for fitting parameters.  There are two types of 
% fitting parameters: coefficients and time constants.
% Because there is a constraint for the coefficients,
% the number of coefficients is one less the number of
% time constants.
foo = floor(length(x0)/2);  % this is equal to the index value
J   = x0(1:foo);
tau = x0(foo+1:end);

% go to town.  this is our fitting function
[rows cols] = size(J);
for k = 1 : cols
    if ~exist('Jt') & (cols == 1)
        Jt = exp(-t/tau(k));       
    elseif ~exist('Jt')
        Jt = J(k)*exp(-t/tau(k));        
    elseif (k > 1) & (k < cols)
        Jt = Jt + J(k)*exp(-t/tau(k));
    else
        Jlast = 1 - sum(J);
        Jt = Jt + (Jlast)*exp(-t/tau(cols));
    end
end


