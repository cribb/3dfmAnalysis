function p = exp(q)
phi = norm(q.v);
if phi==0
   p = quat(exp(q.r));
else
   u = q.v/phi;
   p = exp(q.r)*quat([cos(phi), u*sin(phi)]);
end
