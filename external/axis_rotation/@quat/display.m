function display(q)
% display(q) -- display function for quaternions.  Format: <q1, q2, q3, q4>;
% if symbolic, the format is [q1, q2, q3, q4].

% print the literal actual parameter q, or "ans" if q is null.
var = inputname(1);
if isempty(var)
   fprintf('\nans = \n');
else
   fprintf('\n%s = ', var);
end

vector(q);
if isa(ans, 'sym')
    disp(ans);
else
    q =ans.*(abs(ans)>eps);
    fprintf('<%g, %g, %g, %g>\n\n', q(1), q(2), q(3), q(4));
end
