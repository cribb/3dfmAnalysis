function f = fmatrix(p, d)
% f = fmatrix(p) -- returns the f matrix for a list
% of n pole position vectors p, one vector per row.
% If d is given, a TeX matrix-formatted string with
% d digits of fractional precision is returned instead
% of the matrix itself. The symmetric f matrix is
% structured as an (n x 3 x n) array where the middle
% index refers to the spatial axes, [x,y,z].
size(p);
n = ans(1);
for i = 1:n
    r(i) = norm(p(i,:));
    u(i,:) = p(i,:)/r(i);
end
for j = 1:n
    for k = 1:n
        2*u(j,:)*u(k,:)'/(r(j)*r(k))^2;
        f(j,:,k) = ans*(u(j,:)/r(j) + u(k,:)/r(k));
    end
end
if nargin == 2
    % construct the TeX formatting strings
    fmt1 = sprintf('%%s[%%.%1df,%%.%1df,%%.%1df]&', d, d, d);
    fmt2 = sprintf('%%s[%%.%1df,%%.%1df,%%.%1df]\\\\cr\\n ', d, d, d);
    s = sprintf ('%s\n ', '\left(\matrix{');
    % fill in the matrix elements
    for j = 1:n
        for k = 1:n
            if k < n
                s = sprintf(fmt1, s, f(j,1,k), f(j,2,k), f(j,3,k));
            else
                s = sprintf(fmt2, s, f(j,1,k), f(j,2,k), f(j,3,k));
            end
        end
    end
    s = sprintf('%s}\\right)\n', s);
    f =s;
end
return
% % Examples:
% fmatrix(tetra(1)) % unit tetrahedron
% fmatrix(tetra(1),2) % ... in TeX format
% fmatrix(hexa(1)) % unit FCC
% fmatrix(hexa(1),0) % ... in TeX format
% fmatrix(hexa(1.3195)) % 1.3195^5 = 4 => unit diagonals