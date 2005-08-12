function v = laser_trap_calibration(file, eta, a)

if nargin < 3 | isempty(a)
	a = .5e-6;          % bead radius in m
end

if nargin < 2 | isempty(eta)
	eta = .026;         % viscosity in Pa s
end

% physical constants
T = 298;
K = 1.3807e-23;
gamma = 6*pi*eta*a;

% load dataset
d = load_lasertrap_tracking(file, [0 0 0]);


kx = LorentzianFit(d.psd.f, d.psd.x, eta, a);
ky = LorentzianFit(d.psd.f, d.psd.y, eta, a);
kz = LorentzianFit(d.psd.f, d.psd.z, eta, a);

v = [kx ky kz];

