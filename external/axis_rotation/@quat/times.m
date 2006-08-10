function p = times(q,r)
p = quat(q);
r = quat(r);
p.r = p.r*r.r;
p.v = p.v.*r.v;