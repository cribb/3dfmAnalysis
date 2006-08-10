% ctranspose(q) -- returns the quaternion conjugate of q
function p = ctranspose(q)
p = quat([q.r, -q.v]);