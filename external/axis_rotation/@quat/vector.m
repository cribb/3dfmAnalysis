function v = vector(q)
% vector(q) -- returns a 4-vector representation of quaternion q.

v = [q.r, q.v];