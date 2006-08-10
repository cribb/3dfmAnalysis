% mldivide(q,p) -- q divided from the left into p
function r = mldivide(q,p)
if isscalar(q)
   r = quat(vector(p)/q);
else
   r = recip(quat(q))*p;
end
