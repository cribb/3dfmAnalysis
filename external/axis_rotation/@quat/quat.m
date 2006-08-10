function q = quat(x)
% q = quat(x) -- returns a quaternion q constructed from argument x.
% Acceptable classes for x are
%   real numbers: q = <x, 0, 0, 0>,
%   3-vectors (row or column): q = <0, x> or <0, x'>,
%   4-vectors (row or column): q = <x> or <x'>,
%    no argument: q = <0, 0, 0, 0>.

if nargin > 1
   error('Too many arguments.')
end
if nargin == 0
   q.r = 0;
   q.v = [0,0,0];
elseif isa(x, 'quat')
   q = x;
   return
elseif ndims(x) > 2
   error('Argument cannot be a quat.')
else
   s = size(x);
   if s == [1,1]
      q.r = x;
      q.v = [0,0,0];
   elseif s == [1,3]
      q.r = 0;
      q.v = x;
   elseif s == [1,4]
      q.r = x(1);
      q.v = x(2:4);
   elseif s == [3,1]
      q.r = 0;
      q.v = x';
   elseif s == [4,1]
      q.r = x(1);
      q.v = x(2:4)';
   else
      error('Argument cannot be a quat.')
   end
end
q = class(q, 'quat');

   
   
   