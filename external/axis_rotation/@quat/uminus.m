function p = uminus(q)
p = quat(q);
p.r = -p.r;
p.v = -p.v;