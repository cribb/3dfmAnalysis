function newdisp = rotate_to_vector(varargin)
% 3DFM function  
% Math 
% last modified 05/06/04
%  
% This function rotates a displacement dataset by angles theta and/or phi.  Used mainly
% to align a dataset from a force vector of variable angle, to the z-axis.
%  
%  newdisp = rotate_to_vector(disp,theta,phi);  
%   
%  where "disp" is a displacement matrix with each column holding a coordinates data, e.g. [x y z]
%        "theta" is the rotation angle in the zr-plane
%        "phi" is the rotation angle in the xy-plane
%
%  Notes:  
%   
%  - "disp" is the only required parameter.  Theta & phi will be computed automatically if not present
%  - rotate_to_vectors is smart enough to know if your data is 2D or 3D by the number of columns present
%    in the matrix you pass to it.
%   
%  05/06/04 - created, jcribb, from jkf 'transform' script.  
%   
%  
disp = varargin{1};

[rows cols] = size(disp);

if cols==2
    disp(:,3) = zeros(length(disp),1)
end

switch nargin
	case 1
        [theta, phi] = vector_angles(disp);    
    case 2
        theta = varargin{2}; 
        [foo, phi] = vector_angles(disp);
	case 3
        theta = varargin{2}; 
        phi = varargin{3};
end

x = disp(:,1);
y = disp(:,2);
z = disp(:,3);

% now do a transform so that the old xy plane lines up with the new one
z_1 = z;
x_1 = x .* cos(phi) - y .* sin(phi);
y_1 = x .* sin(phi) + y .* cos(phi);

% do a second transform to complete the deal
z_final = z_1.*cos(theta) - x_1.*sin(theta);
y_final = y_1;
x_final = z_1.*sin(theta) + x_1.*cos(theta);

newdisp(:,1) = x_final;
newdisp(:,2) = y_final;
newdisp(:,3) = z_final;