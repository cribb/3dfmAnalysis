function v = magnitude(varargin)
% 3DFM function  
% Math 
% last modified 01/06/2004 
%  
% This function computes the magnitude of an n-component vector.
%  
%    mag = magnitude(varargin);  
%   
% where varargin is a vector or a list of component values  
%  
%   
%  10/30/02 - created by jcribb.  
%  01/06/04 - expanded to include vectors of length greater than 2
%  01/06/04 - added help documentation
%   
%  

squared_sum = 0;

if nargin > 1

    for k=1:nargin
        squared_sum = squared_sum + (varargin{k} .^ 2);
    end

    v = sqrt(squared_sum);
    
elseif nargin == 1
    
    v = sqrt(sum(varargin{1}.^2,2));
    
else
    error('You need at least one vector, or several scalar components for this function.');
end

