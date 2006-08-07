function force_map_interp = interp_forces2d(x_bins, y_bins, force_map)
% 3DFM function  
% Magnetics
% last modified 07/31/06 (jcribb)
%  
% Interpolates forces in 2d when given 2d forcemap dataset. 
%
%   force_map_interp = interp_forces2d(x_bins, y_bins, force_map)
%
% where  force_map_interp is the interpolated force_map
%        x_bins,y_bins are vectors containing x,y grid values
%        force_map is the input forcemap
%


    % to do the surface, we have to remap some matrices
    Lx = length(x_bins);
    Ly = length(y_bins);
    
    sx = repmat(x_bins, 1, Ly)'; 
    sx = reshape(sx, Lx*Ly, 1);
    sy = repmat(y_bins, 1, Lx); 
    sy = reshape(sy, Lx*Ly, 1);    
    sF = reshape(force_map, Lx*Ly, 1);

    idx = isfinite(sF);
    sx = sx(idx);
    sy = sy(idx);
    sF = sF(idx);

    [xi,yi] = meshgrid(x_bins, y_bins);
    zi = griddata(sx, sy, sF, xi, yi);

    force_map_interp = zi;
    
    return;
    
    
