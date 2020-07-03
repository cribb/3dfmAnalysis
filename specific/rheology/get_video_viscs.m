function v = get_video_viscs(name, bead_radius_m, frame_rate, cutoff);
% GET_VIDEO_VISCS computes and reports viscosities on batches of beads  
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford)
%  
% This function computes and reports viscosities on batches of beads.
%  
%  [outputs] = get_video_viscs(name, bead_radius_m, frame_rate, cutoff);  
%   
%  where "name"          name of the file or files (wildcards may be used)
%        "bead_radius_m" radius of the bead in meters
%		 "frame_rate"    number of frames/second from the recording camera.
%        "cutoff"        cutoff frequency for use in the linear fit (good guess is ~Nyquist/2).
%
  
    video_tracking_constants;

    files = dir(name);
    count = 1;
    for k = 1:length(files)
        
        file = files(k).name;
        
        d = load_video_tracking(file, frame_rate, 'm', 0.152, 'relative', 'yes', 'matrix');

        for m = 0:get_beadmax(d)
            
            b = get_bead(d, m);

            min_time_step = min(diff(b(:,TIME)));
            
            interp_b = interp1(b(:,TIME), b, min_time_step:min_time_step:max(b(:,TIME)));

            r = magnitude(interp_b(:,X:Y));
            [psd f] = mypsd(r, 1/min_time_step, 1/floor(max(b(:,TIME))), 'rectangle');
            
            temp = visc_ps(f, psd, bead_radius_m, cutoff);
            visc(m+1,k) = temp.visc;
            slope(m+1,k) = temp.slope;
            
            new_grid = [0.02 : 1/200 : 60]';
            interp_psd = interp1(f, psd, new_grid);
            interp_f = interp1(f, f, new_grid);
            psdALL(:,count) = interp_psd(:);
            fALL = interp_f(:);
            count = count + 1;
        end
        
    end
    
    
    v.visc = visc;    
    v.slope = slope;
    v.psd = psdALL;
    v.f = fALL;
