function v = get_viscs(coord, bead_radius, frame_rate, cutoff);
% 3DFM function  
% Rheology 
% last modified 05/07/04 
%  
% This function computes viscosity from (x,y) coordinates passed to it
% (more often than not from load_video_tracking).
%  
%  v = get_viscs(coord, bead_radius, frame_rate, cutoff);
%   
%  where "coord" is a matrix of bead coordinates in (x,y)
%        "bead_radius" is bead_radius in units of [m] 
%        "frame_rate" is the rate of the camera 
%        "cutoff" is the cutoff frequency for the psd-fit
%  
%  Notes:  
%      
%   
%  09/03/03 - created; jcribb
%  05/07/04 - updated documentation; jcribb
%  
%
        
    x = coord(:,1) * calib;
    y = coord(:,2) * calib;
    
    r = magnitude(x,y);

    psd_res = 1 / (length(x) / 30);
    [psd.x f.x] = mypsd(x, frame_rate, psd_res, 'rectangle');
    [psd.y f.y] = mypsd(y, frame_rate, psd_res, 'rectangle');
    [psd.r f.r] = mypsd(r, frame_rate, psd_res, 'rectangle');
    
    
    x_data = visc_ps(f.x, psd.x, bead_radius, cutoff);
    y_data = visc_ps(f.y, psd.y, bead_radius, cutoff);
    r_data = visc_ps(f.r, psd.r, bead_radius, cutoff);

    
    v.xyr   = [x y r];
    v.psdxyr= [psd.x psd.y psd.r];
    v.freqs = f.r;
    v.slope = [ x_data.slope ; y_data.slope ; r_data.slope]';
    v.icept = [ x_data.icept ; y_data.icept ; r_data.icept]';
    v.visc  = [ x_data.visc  ; y_data.visc  ; r_data.visc ]';
    
    
