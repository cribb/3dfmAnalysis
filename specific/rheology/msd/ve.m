function v = ve(d, bead_radius);
% 3DFM function  
% Rheology 
% last modified 06/29/05 (jcribb)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
%  
%  [v] = ve(d, bead_radius);  
%   
%  where "d" is the output structure of msd.
%        "bead_radius" is in [m] 
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  

k = 1.38e-23;
T = 298;

msd = d.msd;
tau = d.tau;
N = d.n; % corresponds to the number of trackers (beads)

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
gstar = (2*k*T) ./ (3 * pi * bead_radius .* msd .* MYgamma);

f = 1 ./ tau;
w = f/(2*pi);

gp = gstar .* cos(pi/2 .* alpha);
gpp= gstar .* sin(pi/2 .* alpha);
np = gpp .* tau;
npp= gp  .* tau;

% setting up axis transforms for the figures plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set them up here.
logtau = log10(tau);
logmsd = log10(msd);
mean_logtau = mean(logtau,2);
mean_logf = mean(log10(f),2);
mean_logw = mean(log10(w),2);

loggp  = log10(gp);
loggpp = log10(gpp);
mean_loggp = mean(loggp,2);
mean_loggpp= mean(loggpp,2);
ste_loggp  = std(logtau,0,2) ./ sqrt(N);
ste_loggpp = std(logmsd,0,2) ./ sqrt(N);

lognp = log10(np);
lognpp= log10(npp);
mean_lognp = mean(lognp,2);
mean_lognpp= mean(lognpp,2);
ste_lognp = std(lognp,0,2) ./ sqrt(N);
ste_lognpp= std(lognpp,0,2) ./ sqrt(N);

	figure;
    hold on;
	errorbar(mean_logw, mean_loggp, ste_loggp, 'b');
	errorbar(mean_logw, mean_loggpp, ste_loggpp, 'r');
    hold off;
    xlabel('log_{10}(\omega) [rad/s]');
	ylabel('log_{10}(modulus) [Pa]');
	h = legend('G''(\omega)', '', 'G''''(\omega)', '', 0);
	grid on;
	pretty_plot;
	
	figure;
    hold on;
	errorbar(mean_logw, mean_lognp, ste_lognp, 'b');
	errorbar(mean_logw, mean_lognpp, ste_lognpp, 'r');
    hold off;
	xlabel('log_{10}(\omega) [rad/s]');
	ylabel('log_{10}(viscosity) [Pa sec]');
	legend('\eta''(\omega)', '', '\eta''''(\omega)', '', 0);
	grid on;
	pretty_plot;

v.raw.f = f;
v.raw.tau = tau;
v.raw.msd = msd;
v.raw.alpha = alpha;
v.raw.gamma = MYgamma;
v.raw.gstar = gstar;
v.raw.gp = gp;
v.raw.gpp=gpp;
v.raw.np = np;
v.raw.npp = npp;

v.mean.f = mean(f, 2);
v.mean.tau = mean(tau, 2);
v.mean.msd = mean(msd, 2);
v.mean.alpha = mean(alpha, 2);
v.mean.gamma = mean(MYgamma, 2);
v.mean.gstar = mean(gstar, 2);
v.mean.gp = mean(gp, 2);
v.mean.gpp = mean(gpp, 2);
v.mean.np = mean(np, 2);
v.mean.npp = mean(npp, 2);

v.error.f = std(f, 0, 2) ./ sqrt(N);
v.error.tau = std(tau,0,2) ./ sqrt(N);
v.error.msd = std(msd,0,2) ./ sqrt(N);
v.error.alpha = std(alpha,0,2) ./ sqrt(N);
v.error.gamma = std(MYgamma,0,2) ./ sqrt(N);
v.error.gstar = std(gstar,0,2) ./ sqrt(N);
v.error.gp = std(gp,0,2) ./ sqrt(N);
v.error.gpp = std(gpp,0,2) ./ sqrt(N);
v.error.np = std(np,0,2) ./ sqrt(N);
v.error.npp = std(npp,0,2) ./ sqrt(N);

v.n = d.n;

