function v = calcD(d)
% CALCD This function computes the diffusion coefficient from 3dfm data structure  
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford) 
%  
%  
%  v = get_viscs(d);
%   
%  where "d" can be a vector of motion, or a 3dfm data structure. 
%  
  


if ~isnumeric(d)
    r = magnitude(d.stage.xs, d.stage.ys, d.stage.zs);
    
    v = (diff(r).^2)./(2*diff(r));
else
    v = (diff(d).^2)./(2*diff(d));
end

