function v = get_viscs_txyz(txyz, bead_radius, sampling_rate, cutoff);
% GET_VISCS_TXYZ computes viscosity from [t x y z] coordinates passed to it (typically from load_video_tracking)  
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford) 
%  
% This function computes viscosity from [t x y z] coordinates passed to it
% (more often than not from load_video_tracking).
%  
%  v = get_viscs_txyz(txyz, bead_radius, frame_rate, cutoff);
%   
%  where "txyz" is a matrix of bead coordinates in [t x y z]
%        "bead_radius" is bead_radius in units of [m] 
%        "frame_rate" is the rate of the camera 
%        "cutoff" is the cutoff frequency for the psd-fit
%  



    xyz = txyz(:,2:4);
    r = magnitude(xyz);

    psd_res = 1;

    [psd f] = mypsd(r, sampling_rate, psd_res, 'rectangle');
    r_data = visc_ps(f, psd, bead_radius, cutoff);

    
    v.r   = r;
    v.psd = psd;
    v.freqs = f;
    v.slope = r_data.slope;
    v.icept = r_data.icept;
    v.visc  = r_data.visc ;
    
    
