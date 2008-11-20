function v = get_file_viscs(filepath, bead_radius);
% GET_FILE_VISCS Computes viscosity from power spectra of bead positions for a list of 3dfm tracking datasets  
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford)
%  
% This function computes viscosity from power spectra of bead positions 
% for a list of 3dfm tracking datasets.
% 
%  
%  [v] = get_file_viscs(filepath, bead_radius); 
%   
%  where "filepath" is a directory containing dataset files
%        "bead_radius" is [something] in units of [units] 
%		 etc...  
%  
  

    files = dir(filelist);
    
    for k = 1:length(files)
        
        file = files(k).name;
        
        d = load_vrpn_tracking(file, 'm', 'zero', 'yes', 'no');
        d = vrpn_psd(d);

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
    
    
