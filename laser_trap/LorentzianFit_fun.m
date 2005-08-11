function S = LorentzianFit_fun(x0, fx)

% input fitting parameters
fc = x0;

% constants
T = 298;
K = 1.3807e-23;
eta = .026;         % viscosity in Pa
a = .5e-6;          % bead radius in m
gamma = 6*pi*eta*a;

% fitting function
S = (K*T) ./ (gamma*(pi^2)*(fc^2 + fx.^2));



