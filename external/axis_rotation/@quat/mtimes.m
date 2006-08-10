function r = mtimes(p,q)
if isscalar(p)
   r = quat(p*[q.r, q.v]);
elseif isscalar(q)
   r = quat([p.r, p.v]*q);
else
   r = quat([p.r*q.r-dot(p.v,q.v), p.r*q.v+p.v*q.r+cross(p.v,q.v)]);
end
