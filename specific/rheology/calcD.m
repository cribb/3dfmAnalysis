function v = calcD(d)
% 3DFM function  
% Rheology 
% last modified 05/07/04 
%  
% This function computes the diffusion coefficient from 3dfm 
% data structure.
%  
%  v = get_viscs(d);
%   
%  where "d" can be a vector of motion, or a 3dfm data structure. 
%  
%  Notes:  
%   
%   
%  05/07/03 - created; jcribb
%  05/07/04 - added documentation; jcribb
%     
%  


if ~isnumeric(d)
    r = magnitude(d.stage.xs, d.stage.ys, d.stage.zs);
    
    v = (diff(r).^2)./(2*diff(r));
else
    v = (diff(d).^2)./(2*diff(d));
end

