function r = minus(p, q)
r = quat(p);
q = quat(q);
r.r = r.r - q.r;
r.v = r.v - q.v;