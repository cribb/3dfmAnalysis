function v = get_video_viscs(name, bead_radius, frame_rate, cutoff);

    files = dir(name);
    
    for k = 1:length(files)
        
        file = files(k).name;
        
        d = xlsread(file);
        
        x(:,k) = ( d(:,5) - d(1,5) ) * 1e-6;
        y(:,k) = ( d(:,6) - d(1,6) ) * 1e-6;
        
        [psd.x f.x] = mypsd(x(:,k), frame_rate, 0.1, 'rectangle');
        [psd.y f.y] = mypsd(y(:,k), frame_rate, 0.1, 'rectangle');
        
        x_data(k) = visc_ps(f.x, psd.x, bead_radius, cutoff);
        y_data(k) = visc_ps(f.y, psd.y, bead_radius, cutoff);
        
    end
    v.x     = x;
    v.y     = y;
    v.slope = [ x_data.slope ; y_data.slope ]';
    v.icept = [ x_data.icept ; y_data.icept ]';
    v.visc  = [ x_data.visc  ; y_data.visc  ]';
    
    