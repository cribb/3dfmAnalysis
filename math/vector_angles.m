function [theta,phi] = vector_angles(disp)
% 3DFM function  
% Math 
% last modified 05/06/04 
%  
% This function computes the rotational angle(s) theta (2D & 3D) and phi (3D).  
%  
%  [theta,phi] = vector_angles(disp);  
%   
%  where "disp" is a displacement matrix with each column holding a coordinates data, e.g. [x y z]
%  
%
%  Notes:  
%   
%  - vector_angles is smart enough to know if your data is 2D or 3D by the number of columns present
%    in the matrix you pass to it.
%  - For a good example, look at load_vrpn_tracking 
%   
%   
%  05/06/04 - created, jcribb, from jkf 'transform' script.  
%   
%  

[rows cols] = size(disp);

x = disp(:,1);
y = disp(:,2);

if cols==2
    z = zeros(size(x));
elseif cols==3
    z = disp(:,3);
else
    error('I don''t know  how to deal with more than 3-d displacements');
end

theta = atan2(sqrt(x.^2 + y.^2),z);
phi   = atan2(y,x);

% % 		figure; plot(atan2(sqrt(x.^2 + y.^2),z));
% % 		figure; plot(atan2(y,x));

theta = mean(theta);
phi = mean(phi);

