function g = gmatrix(p,d)
% GMATRIX Returns g matrix for a list of n pole position vectors
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)
%
% g = gmatrix(p) -- returns the g matrix for a list
% of n pole position vectors p, one vector per row.
% If d is given, a TeX matrix-formatted string with 
% d digits of frational precision is returned instead 
% of the matrix itself.  The symmetric g matrix is 
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
        g(j,:,k) = ans*(u(j,:)/r(j) + u(k,:)/r(k));
    end
end

if nargin == 2
    % construct the TeK formatting string
    fmt1 = sprintf('%%s[%%.%1df,%%.%1df,%%.%1df]&', d, d, d);
    fmt2 = sprintf('%%s[%%.%1df,%%.%1df,%%.%1df]\\\\cr\\n  ', d, d, d);
    s = sprintf('%s\n  ', '\left(\matrix{');
    % fill in the matrix elements
    for j = 1:n
        for k = 1:n
            if k<n
                s = sprintf(fmt1, s, g(j,1,k), g(j,2,k), g(j,3,k));
            else
                s = sprintf(fmt2, s, g(j,1,k), g(j,2,k), g(j,3,k));
            end
        end
    end
    
    s = sprintf('%s}\\right)\n',s);
    g = s;
end

return

    
