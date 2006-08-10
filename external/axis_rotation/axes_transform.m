function [rdata,q] = axes_transform(Mv,data);
% 3DFM function
% 
% Transform the axis so that given master vector is aligned to Z axis, and 
% apply that rotation to given data vectors.
% 
% Mv: 1x3 vector, the master vector to be aligned to z axis
% data: N x 3 matrix, the data vectors to which the same rotation is to be applied.
% rdata: N x 3 matrix, the data vector rotated as required
% q: 1x4 quaternion used for the rotation
%
% created: Jan 2006, kvdesai

if nargin < 1 % in test mode
    Mv = [-2,5,-1];%Rotate axis so that this vector is aligned to z axis    
%     data = rand(100,3);% Other vectors in the data.
data = Mv;
end

% Angles are to be the counter clockwise rotation (Right hand screw)
%First align to Y axis and then align to Z axis.

%Rotation about z axis, 
%phi is the CCW angle that the Mv should be rotated by to be aligned with
%+ve Y axis
phi = atan(Mv(2)/Mv(1));
if Mv(1) >= 0
    phi = pi/2 - phi;
elseif Mv(1) < 0 
    phi = 3*pi/2 - phi;
else
    disp('what???');
end

%Rotation about x axis, theta
theta = atan(sqrt(sum(Mv(1:2).^2))/Mv(3));

qz = quat([cos(phi/2),0,0,sin(phi/2)]);
qx = quat([cos(theta/2),sin(theta/2),0,0]);

q = qx*qz;

M = Qrot(Mv,q) % check that X and Y components of M are zero
rdata = Qrot(data,q);
% keyboard