function v = get_moduli(file)
% 3DFM function  
% Rheology 
% last modified 10/20/2003 
%  
% This function computes viscoelastic moduli for 3dfm tracking files.
%  
%  v = get_moduli(file)
%   
%  where file is a filename that can include wildcards * or ? 
%       
%  
%  Notes:  
%   
%   
%   
%  10/16/03 - created; jcribb
%  10/18/03 - added multiple files option; jcribb
%  10/20/03 - added help info; jcribb
%  05/07/04 - modified for new load_vrpn_tracking function; jcribb
%  

tic;

files = dir(file);

% set desired frequency resolution
res  = 0.1;
T  = 298; %Kelvin;
kb = 1.3806503e-23; % Joules/Kelvin   http://physics.nist.gov/cgi-bin/cuu/Value?k
nm = 10^9;
R  = 0.5e-6; % meters
res = 1/(d.beadpos.time(2) - d.beadpos.time(1));
psdres = 1/(d.beadpos.time(end)-1/res);
sumpsd = zeros(upsample_rate/2*1/psdres+1,1);

fprintf('Working on %i file(s).\n', length(files));

for k = 1:length(files)
    tmp = load_vrpn_tracking(file, 'm', 'zero', 'yes', 'no');
    tmp = vrpn_psd(tmp);

    sumpsd = sumpsd + tmp.psd.r;

    track(k) = tmp;
end

f = track(1).psd.f;
r = sumpsd/length(files);

App = app(f, r);
w = 2*pi*f;

% [f,App] = sampleKKR(f, App);
% w = 2*pi*f;

fprintf('Computing KKR... please wait\n');
Ap    = evaluateKK(w, App, 'f');
Astar = Ap + j*App;
Gstar = 1./(Astar * 6*pi*R);
Gp    = real(Gstar);
Gpp   = -imag(Gstar);


	figure(1);
	loglog(f, Gp, f, Gpp);
	legend('storage', 'loss');
	title(['Storage and Loss Moduli for ' file]);
	xlabel('frequency (Hz)');
	ylabel('Shear Modulus (in Pa)');

beep;

v.f  = f;
v.psd = r;
v.Ap = Ap;
v.App= App;
v.Gp = Gp;
v.Gpp= Gpp;

toc;