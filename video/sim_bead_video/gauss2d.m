function mat = gauss2d(mat, sigma, center)
gsize = size(mat);
for r=1:gsize(1)
    for c=1:gsize(2)
        mat(r,c) = gaussC(r,c, sigma, center);
    end
end
