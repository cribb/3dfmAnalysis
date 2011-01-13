function v = ve(d, bead_radius, freq_type, plot_results, nmin)
% VE computes the viscoelastic moduli from mean-square displacement data 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
% The output structure of ve contains four members: raw (contains data for 
% each individual tracker/bead), mean (contains means across trackers/beads), and 
% error (contains standard error (stdev/sqrt(N) about the mean value, and N (the
% number of trackers/beads in the dataset.
%
%  [v] = ve(d, bead_radius, freq_type, plot_results);  
%   
%  where "d" is the output structure of msd.
%        "bead_radius" is in [m].
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%        "plot_results" reports with a figure if 'y'. default is 'y'
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  

if (nargin < 5) || isempty(nmin)     
    nmin = 1;   
end

if (nargin < 3) || isempty(freq_type)
    freq_type = 'f';   
end

if (nargin < 2) || isempty(bead_radius)
    bead_radius = 0.5e-6; 
end

if (nargin < 1) || isempty(d)    
    error('no data struct found'); 
end

msd = d.msd;
tau = d.tau;

  N = d.n; % corresponds to the number of trackers at each tau
counts = d.ns; % corresponds to the number of estimates for each bead at each tau

%   pause;
  
% idx = find(N >= nmin);
% tau = tau(idx,:);
% msd = msd(idx,:);
%   N = N(idx,:);

meantau = nanmean(tau,2);
% meanmsd = nanmean(msd,2);

% meantau = trimmean(tau, 15, 2);
% meanmsd = trimmean(msd, 15, 2);

logtau = log10(tau);
logmsd = log10(msd);

numbeads = size(logmsd,2);

% weighted mean for logmsd
weights = counts ./ repmat(nansum(counts,2), 1, size(counts,2));

mean_logtau = nanmean(logtau');
mean_logmsd = nansum(weights .* logmsd, 2);

meanmsd = 10 .^ (mean_logmsd);

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ N);


% errmsd = nanstd(msd, [], 2) ./ sqrt(N);
% 
% errhmsd = meanmsd + errmsd;
% errlmsd = meanmsd - errmsd;

errhmsd = 10 .^ (mean_logmsd + msderr);
errlmsd = 10 .^ (mean_logmsd - msderr);


mygser  = gser(meantau, meanmsd, N, bead_radius);
maxgser = gser(meantau, errhmsd, N, bead_radius);
mingser = gser(meantau, errlmsd, N, bead_radius);

v = mygser;

v.error.f = abs(mygser.f - mingser.f);
v.error.w = abs(mygser.w - mingser.f);
v.error.tau = abs(mygser.tau - mingser.tau);
v.error.msd = abs(mygser.msd - mingser.msd);
v.error.alpha = abs(mygser.alpha - mingser.alpha);
v.error.gamma = abs(mygser.gamma - mingser.gamma);
v.error.gstar = abs(mygser.gstar - mingser.gstar);
v.error.gp = abs(mygser.gp - mingser.gp);
v.error.gpp = abs(mygser.gpp - mingser.gpp);
v.error.nstar = abs(mygser.nstar - mingser.nstar);
v.error.np = abs(mygser.np - mingser.np);
v.error.npp = abs(mygser.npp - mingser.npp);

v.n = N;

% assignin('base', 'msdjac', d);
% assignin('base', 'vejac', v);

  N = d.n; % corresponds to the number of trackers at each tau

%   pause;
  
idx = find(N >= nmin);
tau = tau(idx,:);
msd = msd(idx,:);
  N = N(idx,:);

tau = nanmean(tau,2);
msd = nanmean(msd,2);


% plot output
if (nargin < 4) || isempty(plot_results) || strncmp(plot_results,'y',1)  
    fig1 = figure; fig2 = figure;
    plot_ve(v, freq_type, fig1, 'Gg');
    plot_ve(v, freq_type, fig2, 'Nn');
end;

return;

function v = gser(tau, msd, N, bead_radius)
% [dydx, newx, newy] = windiff(y, x, window_size)
% [alpha, logtau, logmsd] = windiff(log10(msd), log10(tau), 1);

k = 1.3806e-23;
T = 298;

A = tau(1:end-1,:);
B = tau(2:end,:);
C = msd(1:end-1,:);
D = msd(2:end,:);

% alpha = log10(D./C)./log10(B./A);

timeblur_decade_fraction = .3;
[alpha, tau_evenspace, msd_evenspace] = getMSDSlope(msd, tau, timeblur_decade_fraction);

MYgamma = gamma(1 + abs(alpha));
% gamma = 0.457*(1+alpha).^2-1.36*(1+alpha)+1.9;

% because of the first-difference equation used to compute alpha, we have
% to delete the last row of f, tau, and msd values computed.

% msd = msd(1:end-1,:);
% tau = tau(1:end-1,:);
%   N =   N(1:end-1,:);

msd = msd(1:end-1,:);
tau = tau(1:end-1,:);
  N =   N(1:end-1,:);


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

v.f = f;
v.w = w;
v.tau = tau;
v.msd = msd;
v.alpha = alpha;
v.gamma = MYgamma;
v.gstar = gstar;
v.gp = gp;
v.gpp = gpp;
v.nstar = nstar;
v.np = np;
v.npp = npp;

return;