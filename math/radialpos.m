function d = radialpos(tpos, origin, add2d);
% RADIAL3D
% 3DFM/LASER TRACKING ANALYSIS GUI
% A function heavily used by Laser Tracking Analysis GUI to compute radial
% distances (in plane as well as in 3D) from position coordinates.
% Usage: d = radialpos(tpos,add2d)
%     tpos: N x M matrix (M = 4 for 3D, M = 3 for 2D) matrix contaning timestamps in the first column
%             and position coordinates in rest of the columns
%     origin: [1 x M-1] vector containing the coordinates of the point
%             respect to which the radial distances are to be computed.
%             Defaulted to the coordinates of the first point
%     add2d: A flag indicating whether displacement in 2D (XY plane) are also to be computed
%             Only considered when the tpos is N x 4 matrix. Defaulted to 1
%     d: N x 4 matrix with columns t-x-y-xy(r) for 2D case
%      : N x 5 matrix with columns t-x-y-z-xyz(r) for 3D case when add2d = 0
%      : N x 6 matrix with columns t-x-y-z-xy-xyz(r) for 3D case when add2d = 1
% Created By: Kalpit Desai, 28 July 2006
if nargin < 2 | isempty(origin),     origin = tpos(1,2:end); end
if nargin < 3 | isempty(add2d),     add2d = 1; end
M = size(tpos,2);
d(:,1:M) = tpos(:,1:M);
% Before computing the radial vectors, translate the coordinate frame to
% the new origin. It is much more efficient to subtract offset from each
% column one by one than making a huge matrix using repmat and then using
% matrix subtraction.
for c = 2:M
    tpos(:,M) = tpos(:,M) - origin(M-1);
end
if M == 4 & add2d == 1
    d(:,M+1) = sqrt(tpos(:,2).^2 + tpos(:,3).^2);
end
d(:,end+1) = sqrt(sum(tpos(:,2:end).^2,2));