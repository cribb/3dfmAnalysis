function val = gauss2d(mat, sigma, center, max)
%Create 2d gaussian curves centered at specific points
%
%Inputs
%   -mat is a matrix that is the size of the final image
%   -sigma is the standard deviation of the 2d gaussian you want
%   -center is the point at which you want the curve centered at
%   -max is the fraction you want to scale your gaussian by (the maximum
%   value of the curve)

xc = center(1);
yc = center(2);

matsize = size(mat);

[x,y] = meshgrid(1:matsize(2),1:matsize(1)); 
%2 for number of columns (x), 1 for number of rows (y)

XC = repmat(xc, size(mat));
YC = repmat(yc, size(mat));

sigma = repmat(sigma, size(mat));

exponent = ((x-XC).^2 + (y-YC).^2)./(2*sigma);
val       = max.*(exp(-exponent)); 
end

%old gauss2d:
%gsize = size(mat);
%for r=1:gsize(1)
%    for c=1:gsize(2)
%        mat(r,c) = gaussC(r,c, sigma, center);
%    end
%end