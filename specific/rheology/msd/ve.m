function v = ve(d, bead_radius, freq_type, plot_results);
% 3DFM function  
% Rheology 
% last modified 01/25/07 (jcribb)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
% The output structure of ve contains four members: raw (contains data for 
% each individual tracker/bead), mean (contains means across trackers/beads), and 
% error (contains standard error (stdev/sqrt(N) about the mean value, and N (the
% number of trackers/beads in the dataset.
%
%  [v] = ve(d, bead_radius, freq_type);  
%   
%  where "d" is the output structure of msd.
%        "bead_radius" is in [m].
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  

if (nargin < 3) || isempty(freq_type)     
    freq_type = 'f';   
end

if (nargin < 2) || isempty(bead_radius)
    bead_radius = 0.5e-6; 
end

if (nargin < 1) || isempty(d)    
    error('no data struct found'); 
end

k = 1.3806e-23;
T = 298;

msd = d.msd;
tau = d.tau;
N = d.n(1:end-1); % corresponds to the number of trackers at each tau

% [dydx, newx, newy] = windiff(y, x, window_size)
% [alpha, logtau, logmsd] = windiff(log10(msd), log10(tau), 1);
A = tau(1:end-1,:);
B = tau(2:end,:);
C = msd(1:end-1,:);
D = msd(2:end,:);
alpha = log10(D./C)./log10(B./A);
MYgamma = gamma(1 + alpha);
% gamma = 0.457*(1+alpha).^2-1.36*(1+alpha)+1.9;

% because of the first-difference equation used to compute alpha, we have
% to delete the last row of f, tau, and msd values computed.
msd = msd(1:end-1,:);
tau = tau(1:end-1,:);

% get frequencies all worked out from timing (tau)
f = 1 ./ tau;
w = 2*pi*f;

% compute shear and viscosity
gstar = (2/3) * (k*T) ./ (pi * bead_radius .* msd .* MYgamma);
gp = gstar .* cos(pi/2 .* alpha);
gpp= gstar .* sin(pi/2 .* alpha);
nstar = gstar .* tau;
np = gpp .* tau;
npp= gp  .* tau;

%
% setup very detailed output structure
%

v.raw.f = f;
v.raw.w = w;
v.raw.tau = tau;
v.raw.msd = msd;
v.raw.alpha = alpha;
v.raw.gamma = MYgamma;
v.raw.gstar = gstar;
v.raw.gp = gp;
v.raw.gpp = gpp;
v.raw.nstar = nstar;
v.raw.np = np;
v.raw.npp = npp;

v.mean.f = nanmean(f')';
v.mean.w = nanmean(w')';
v.mean.tau = nanmean(tau')';
v.mean.msd = nanmean(msd')';
v.mean.alpha = nanmean(alpha')';
v.mean.gamma = nanmean(MYgamma')';
v.mean.gstar = nanmean(gstar')';
v.mean.gp = nanmean(gp')';
v.mean.gpp = nanmean(gpp')';
v.mean.nstar = nanmean(nstar')';
v.mean.np = nanmean(np')';
v.mean.npp = nanmean(npp')';

v.error.f = (nanstd(f') ./ sqrt(N'))';
v.error.w = (nanstd(w') ./ sqrt(N'))';
v.error.tau = (nanstd(tau') ./ sqrt(N'))';
v.error.msd = (nanstd(msd') ./ sqrt(N'))';
v.error.alpha = (nanstd(alpha') ./ sqrt(N'))';
v.error.gamma = (nanstd(MYgamma') ./ sqrt(N'))';
v.error.gstar = (nanstd(gstar') ./ sqrt(N'))';
v.error.gp = (nanstd(gp') ./ sqrt(N'))';
v.error.gpp = (nanstd(gpp') ./ sqrt(N'))';
v.error.nstar = (nanstd(nstar') ./ sqrt(N'))';
v.error.np = (nanstd(np') ./ sqrt(N'))';
v.error.npp = (nanstd(npp') ./ sqrt(N'))';

v.n = N;

% plot output
if (nargin < 4) || isempty(plot_results) || strncmp(plot_results,'y',1)  
    fig1 = figure; fig2 = figure;
    plot_ve(v, freq_type, fig1, 'Gg');
    plot_ve(v, freq_type, fig2, 'Nn');
end;
