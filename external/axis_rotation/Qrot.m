function v = Qrot(u, Q)
% v = Qrot(u, Q) -- rotate vector list u by unit quat Q
% Each row of u is a vector of three columns.

s = size(u);
if length(s) > 2 | s(2) ~= 3
   error('improper vector list');
end
for i = 1:length(u(:,1))
   Q*quat(u(i,:))*Q';
   v(i,:) = vect(ans);
end
