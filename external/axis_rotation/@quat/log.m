% Q = log(P) returns quat Q, the natrual logarithm of quat P.
% If P is a unit quat, Q will be a pure vector quat.
function Q = log(P)
% Geometrically, the rotation vectors (logs) doubly cover R^3.
% We choose the convention that phi >= 0, i.e., the length of
% the rotation vectors are positive.  This allows them to be
% treated as radii pointing in any direction.
p = norm(P);
if p == 0
   Q = quat(-inf);
else
   U = P/p;
   sinphi = norm(U.v);
   phi = atan2(sinphi,U.r);
   u = U.v/sinphi;
   Q = quat([log(p), phi*u]);
end
