function v = get_file_viscs(name, bead_radius);
    files = dir(name);
    
    for k = 1:length(files)
        
        file = files(k).name;
        
        d = load_vrpn_tracking(file, 1000, 0.3, 'rectangle', 'm');
        
        f(k,:)    = file;
        
        x(k) = visc_ps(d.psd.f, d.psd.x, bead_radius, 100);
        y(k) = visc_ps(d.psd.f, d.psd.y, bead_radius, 100);
        z(k) = visc_ps(d.psd.f, d.psd.z, bead_radius, 100);
        r(k) = visc_ps(d.psd.f, d.psd.r, bead_radius, 100);
        
    end
    
    v.files= f;
    v.slope = [ x.slope ; y.slope ; z.slope ; r.slope ]';
    v.icept = [ x.icept ; y.icept ; z.icept ; r.icept ]';
    v.visc  = [ x.visc  ; y.visc  ; z.visc  ; r.visc  ]';
    
    