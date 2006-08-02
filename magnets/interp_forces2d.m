function force_map_interp = interp_forces2d(xpos, ypos, force_map)
% 3DFM function  
% Magnetics
% last modified 07/31/06 (jcribb)
%  
% Interpolates forces in 2d when given 2d forcemap dataset. 
%
%   force_map_interp = interp_forces2d(xpos, ypos, force_map)
%
% where  force_map_interp is the interpolated force_map
%        xpos,ypos are vectors containing x,y grid values
%        force_map is the input forcemap
%


    % to do the surface, we have to remap some matrices
    sx = repmat(xpos, 1, length(ypos))'; 
    sx = reshape(sx, length(xpos)*length(ypos), 1);
    sy = repmat(ypos, 1, length(xpos)); 
    sy = reshape(sy, length(xpos)*length(ypos), 1);    
    sF = reshape(force_map, (length(xpos)-1)*(length(ypos)-1), 1);

    idx = isfinite(sF);
    sx = sx(idx);
    sy = sy(idx);
    sF = sF(idx);

    [xi,yi] = meshgrid(xpos, ypos);
    zi = griddata(sx, sy, sF, xi, yi);
    force_map_interp = zi;
    
    return;
    
    
