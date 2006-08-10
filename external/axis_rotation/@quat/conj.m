function p = conj(q)
% conj(q) -- returns the conjugate of quaternion q.

p = quat([q.r, -vect(q)]);
warning('Use Q'' for quaternion conjugate.');
