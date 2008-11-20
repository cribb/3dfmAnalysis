function v = kkr(file, bead_radius)
% KKR computes the Kramers-Kronig Relation on the bead position vectors   
%
% 3DFM function
% specific\rheology\kkr
% last modified 11/20/08 (krisford)
%
% This function computes the Kramers-Kronig Relation on the bead position
% vectors (normally the imaginary compliance for rheology datasets)
% for all gathered w frequencies.
%
% [v] = kkr(file, bead_radius)
%
% where:  file is the filename for 3dfm dataset (used by load_vrpn_tracking)
%         bead radius is in meters
%


% First, we need to load our dataset.  Do this using load_vrpn_tracking,
% then compute PSD with a rectangular window.
d = load_vrpn_tracking(file, 'm', 'zero', 'yes', 'no');
d = vrpn_psd(d, [], 'rectangle');

% Now, we need to condition the PSD's we get, so that there's
% not as much frequency resolution in the higher decades
[w psd] = sampleKKR(d.psd.f, d.psd.r);

% The next step is to get the Rheology from this dataset
App   = App(w, psd);
Ap    = evaluateKK(w, App, 'f');
Astar = Ap + j*App;
Gstar = 1./(Astar * 6*pi*bead_radius);
Gp    = real(Gstar);
Gpp   = imag(Gstar);

% Last we have to output our data
v = d;
v.rheo.w  = w;
v.rheo.Ap = Ap;
v.rheo.App= App;
v.rheo.Gp = Gp;
v.rheo.Gpp= Gpp;
v.rheo.visc= -Gpp./w;
