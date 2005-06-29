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

% [dydx, newx, newy] = windiff(y, x, window_size)
% [alpha, logtau, logmsd] = windiff(log10(msd), log10(tau), 1);
A = tau(1:end-1,:);
B = tau(2:end,:);
C = msd(1:end-1,:);
D = msd(2:end,:);
alpha = log10(D./C)./log10(B./A);
gamma = gamma(1 + alpha);
% gamma = 0.457*(1+alpha).^2-1.36*(1+alpha)+1.9;

% because of the first-difference equation used to compute alpha, we have
% to delete the last row of f, tau, and msd values computed.
msd = msd(1:end-1,:);
tau = tau(1:end-1,:);
gstar = (2*k*T) ./ (3 * pi * bead_radius .* msd .* gamma);

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
ste_loggp  = std(logtau,0,2) ./ sqrt(cols(gp));
ste_loggpp = std(logmsd,0,2) ./ sqrt(cols(gpp));

lognp = log10(np);
lognpp= log10(npp);
mean_lognp = mean(lognp,2);
mean_lognpp= mean(lognpp,2);
ste_lognp = std(lognp,0,2) ./ sqrt(cols(np));
ste_lognpp= std(lognp,0,2) ./ sqrt(cols(npp));

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

v.f = f;
v.tau = tau;
v.msd = msd;
v.alpha = alpha;
v.gamma = gamma;
v.gstar = gstar;
v.gp = gp;
v.gpp=gpp;
v.np = np;
v.npp = npp;


