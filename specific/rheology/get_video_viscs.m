function v = get_video_viscs(name, bead_radius_m, frame_rate, cutoff);
% 3DFM function  
% Rheology 
% last modified 03/11/2004
%  
% This function computes and reports viscosities on batches of beads.
%  
%  [outputs] = get_video_viscs(name, bead_radius_m, frame_rate, cutoff);  
%   
%  where "name"          name of the file or files (wildcards may be used)
%        "bead_radius_m" radius of the bead in meters
%		     "frame_rate"    number of frames/second from the recording camera.
%        "cutoff"        cutoff frequency for use in the linear fit (good guess is ~Nyquist/2).
%
%
%  Notes:  
%   
%  ??/??/?? - created by jcribb.  
%  03/11/04 - reworked to include multiple files
%   
%  
    files = dir(name);
    
    for k = 1:length(files)
        
        file = files(k).name;
        
        d = load_video_tracking(file, frame_rate, [], 0.1, 'rectangle', 'm', 0.104);

        for m = 1:cols(d.video.r)
            
            r = d.video.r(:,m);
            
            temp = visc_ps(d.psd.f, d.psd.r(:,m), bead_radius_m, cutoff);
            data(m,k) = temp.visc;
        end
        
    end
    
    
    v = data;    
    
