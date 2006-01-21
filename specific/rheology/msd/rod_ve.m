function ve = ve(d, L, r);
% 3DFM function  
% Rheology 
% last modified 10/06/05 (jcribb)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
% The output structure of ve contains four members: raw (contains data for 
% each individual tracker/bead), mean (contains means across trackers/beads), and 
% error (contains standard error (stdev/sqrt(N) about the mean value, and N (the
% number of trackers/beads in the dataset.
%
%  [v] = ve(d, L, r);  
%   
%  where "d" is the output structure of msd.
%        "L" is in rod length in [m]
%        "r" is the rod radius in [m]
%  Notes:  
%  - The bead algorithm came from Mason 2000 Rheol Acta paper.
%  

k = 1.38e-23;
T = 298;

figure; 
set(gcf, 'Units', 'Normalized');
set(gcf, 'Position', [0.1 0.1 0.8 0.8]);

for D_type = 1:3
    
    clear msd;
    
    switch D_type
        case 1
            dtype = 'parallel';
          	msd = d.msd_p;
            shape_constant = (2   * pi * L  ) / ( log( L / (2*r) ) - 0.20 );
        case 2
            dtype = 'normal';
          	msd = d.msd_n;
            shape_constant = (4   * pi * L  ) / ( log( L / (2*r) ) + 0.84 );    
        case 3
            dtype = 'radial';
          	msd = d.msd_r;
            shape_constant = (1/3 * pi * L^3) / ( log( L / (2*r) ) - 0.66 );
    end    

	tau = d.tau;
	N = d.n(1:end-1); % corresponds to the number of trackers (rods)
	
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

    % Compute D and ratios.. Store in output structure.
    
    % make frequencies
    f = 1 ./ tau;
	w = f/(2*pi);

%  <<original method>>    
	gstar = (k .* T) ./ (shape_constant .* msd .* MYgamma);  	

    gp = gstar .* cos(pi/2 .* alpha);
	gpp= gstar .* sin(pi/2 .* alpha);
	np = gpp .* tau;
	npp= gp  .* tau;

%   trying to use visc here instead of G.. i don't like that j*w
%     nstar = (k*T) / (shape_factor * msd);
%     np = nstar .* cos(pi/2
	
	% setting up axis transforms for the figures plotted below.  You cannot plot
	% errorbars on a loglog plot, it seems, so we have to set them up here.
	logtau = log10(tau);
	logmsd = log10(msd);
	mean_logtau = nanmean(logtau');
	mean_logf = nanmean(log10(f)');
	mean_logw = nanmean(log10(w)');
	
	loggp  = log10(gp);
	loggpp = log10(gpp);
	mean_loggp = nanmean(loggp');
	mean_loggpp= nanmean(loggpp');
	ste_loggp  = nanstd(logtau') ./ sqrt(N');
	ste_loggpp = nanstd(logmsd') ./ sqrt(N');
	
	lognp = log10(np);
	lognpp= log10(npp);
	mean_lognp = nanmean(lognp');
	mean_lognpp= nanmean(lognpp');
	ste_lognp = nanstd(lognp,0,2) ./ sqrt(N');
	ste_lognpp= nanstd(lognpp,0,2) ./ sqrt(N');
	    
    switch D_type
        case 1
            col = 1;
        case 2
            col = 2;
        case 3
            col = 3;
    end
        
		subplot(2, 3, col)
        hold on;
		errorbar(mean_logw, real(mean_loggp), real(ste_loggp), 'b');
		errorbar(mean_logw, real(mean_loggpp), real(ste_loggpp), 'r');
        hold off;
        title(['MSD for ' dtype ' direction']);
        xlabel('log_{10}(\omega) [rad/s]');
		ylabel('log_{10}(modulus) [Pa]');
		h = legend('G''(\omega)', '', 'G''''(\omega)', '', 0);
		grid on;
		pretty_plot;
		
		subplot(2, 3, col + 3)
        hold on;
		errorbar(mean_logw, real(mean_lognp), real(ste_lognp), 'b');
		errorbar(mean_logw, real(mean_lognpp), real(ste_lognpp), 'r');
        hold off;
        title(['MSD for ' dtype ' direction']);
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
	
	v.mean.f = nanmean(f')';
	v.mean.tau = nanmean(tau')';
	v.mean.msd = nanmean(msd')';
	v.mean.alpha = nanmean(alpha')';
	v.mean.gamma = nanmean(MYgamma')';
	v.mean.gstar = nanmean(gstar')';
	v.mean.gp = nanmean(gp')';
	v.mean.gpp = nanmean(gpp')';
	v.mean.np = nanmean(np')';
	v.mean.npp = nanmean(npp')';
	
	v.error.f = (nanstd(f') ./ sqrt(N'))';
	v.error.tau = (nanstd(tau') ./ sqrt(N'))';
	v.error.msd = (nanstd(msd') ./ sqrt(N'))';
	v.error.alpha = (nanstd(alpha') ./ sqrt(N'))';
	v.error.gamma = (nanstd(MYgamma') ./ sqrt(N'))';
	v.error.gstar = (nanstd(gstar') ./ sqrt(N'))';
	v.error.gp = (nanstd(gp') ./ sqrt(N'))';
	v.error.gpp = (nanstd(gpp') ./ sqrt(N'))';
	v.error.np = (nanstd(np') ./ sqrt(N'))';
	v.error.npp = (nanstd(npp') ./ sqrt(N'))';

    switch D_type
        case 1
            ve.parallel = v;
        case 2
            ve.normal   = v;
        case 3
            ve.radial   = v;
	end
end

ve.n = N;

