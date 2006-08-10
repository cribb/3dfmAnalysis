function p = mpower(q,r)
if ~isscalar(r)
   error('exponent is not a scalar');
end
p = quat(1);
if isequal(r, floor(r)) % r is an integer
   if r < 0
      q = recip(q);
      r = -r;
   end
   for i = 1:r
      p = p*q;
   end
else
   error('non integer powers not implemented');
end

   
      