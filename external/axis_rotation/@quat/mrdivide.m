% mrdivide(p,q) -- p divided by q on the right
function r = mrdivide(p,q)
if isscalar(q)
   r = quat(vector(p)/q);
else
   r = p*recip(quat(q));
end
