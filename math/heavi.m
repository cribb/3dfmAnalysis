function v = heavi(t,a)
% 3DFM function  
% Math 
% last modified 09/01/04 
%  
% This function outputs a Heaviside function vector that can be used for
% constructing step response curves for linear systems/models.
%  
%  Ht = heavi(time, activation_time);  
%   
%  where "time" is a vector of time points used in response curve
%        "activation_time" is the delay time for activating the step.
%		
%  
%  Notes:  
%   
%  - heavi(t, 0) will output a unit step with input at time 0.
%  - heavi(t, 5) will output a unit step with input activation at time 5.
%   
%   
%  09/01/04 - created, jcribb.
%
%   
% 


foo = find((t-a) >= 0);
bar = find((t-a) <  0);

v = zeros(1,length(t));

v(foo) = 1;
v(bar) = 0;
