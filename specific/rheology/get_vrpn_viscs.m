function v = get_vrpn_viscs(file, bead_radius, frame_rate, calib_um, cutoff);
% 3DFM function  
% Rheology 
% last modified 05/07/04 
%  
% This function computes viscosity from *.vrpn.mat file 
% (3dfm data structure) passed to it.
%  
%  v = get_vrpn_viscs(file, bead_radius, frame_rate, calib_um, cutoff);
%   
%  where "file" is a *.mat filename containing video data converted from vrpn format
%        "bead_radius" is bead_radius in units of [m] 
%        "frame_rate" is the rate of the camera 
%        "calib_um" is calibration factor in um/pixel
%        "cutoff" is the cutoff frequency for the psd-fit
%  
%  Notes:  
%      
%   
%  11/04/03 - created from get_viscs; jcribb
%  05/07/04 - updated documentation; jcribb
%  
%


	v = load_video_tracking(file,frame_rate,[],0.3,'rectangle','m',calib_um);
    
    coord = [neutralize(v.video.x) neutralize(v.video.y)];
    
    data = visc_ps(v.psd.f, [v.psd.x v.psd.y v.psd.r], bead_radius, cutoff);

    % break
    
%     v.visc.slope = [ x_data.slope ; y_data.slope ; r_data.slope]';
%     v.visc.icept = [ x_data.icept ; y_data.icept ; r_data.icept]';
%     v.visc.visc  = [ x_data.visc  ; y_data.visc  ; r_data.visc ]';        

    v.visc.slope = [ data.slope ]';
    v.visc.icept = [ data.icept ]';
    v.visc.visc  = [ data.visc  ]';        

    
