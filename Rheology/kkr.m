function v = kkr(file, bead_radius)
% 3dfm function
%
% This function computes the Kramers-Kronig Relation on the bead position
% vectors (normally the imaginary compliance for rheology datasets)
% for all gathered w frequencies.
%
% <struct> = kkr(file, bead_radius)
%
% bead radius in meters
% file of load_matlab_tracking 


% First, we need to load our dataset.  Do this using load_matlab_tracking, 
% with a rectangular windowing on the PSD
stage_res = 1000;
psd_res = 0.05;
window = 'rectangle';
d = load_matlab_tracking(file, stage_res, psd_res, window, 'm');

% Now, we need to condition the PSD's we get, so that there's
% not as much frequency resolution in the higher decades
[w psd] = sampleKKR(d.psd.f, d.psd.xyz);

% The next step is to get the Rheology from this dataset
App   = App(w, psd);
Ap    = evaluateKK(w, App);
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