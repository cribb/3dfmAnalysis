function plot_ve(v, freq_type)
% 3DFM function  
% Rheology 
% last modified 01/25/07 (jcribb)
%  
% plot_ve plots the viscoelastic moduli using the ve output structure.
%
%  plot_ve(v, freq_type);  
%   
%  where "v" is the output structure of ve.
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%  


% pull out the variables we need for the plot from the ve data structure.
f   = v.raw.f;
w   = v.raw.w;
tau = v.raw.tau;
msd = v.raw.msd;
gp  = v.raw.gp;
gpp = v.raw.gpp;
np  = v.raw.np;
npp = v.raw.npp;
N   = v.n;

% setting up axis transforms for the figures plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set them up here.
logtau = log10(tau);
logf   = log10(f);
logw   = log10(w);

logmsd = log10(msd);
loggp  = log10(gp);
loggpp = log10(gpp);

mean_logf  = nanmean(logf');
mean_logw  = nanmean(logw');
mean_loggp = nanmean(loggp');
mean_loggpp= nanmean(loggpp');
ste_loggp  = nanstd(logtau') ./ sqrt(N');
ste_loggpp = nanstd(logmsd') ./ sqrt(N');

lognp = log10(np);
lognpp= log10(npp);
mean_lognp = nanmean(lognp');
mean_lognpp= nanmean(lognpp');
ste_lognp = nanstd(lognp') ./ sqrt(N');
ste_lognpp= nanstd(lognpp') ./ sqrt(N');

% select the desired depiction of frequency
switch freq_type
    case 'f'
        plot_freq = mean_logf;
        freq_label = 'log_{10}(f) [Hz]';
        gp_label = 'G''(f)';
        gpp_label = 'G''''(f)';
        np_label = '\eta''(f)';
        npp_label = '\eta''''(f)';
    case 'w'
        plot_freq = mean_logw;
        freq_label = 'log_{10}(\omega) [rad/s]';
        gp_label = 'G''(\omega)';
        gpp_label = 'G''''(\omega)';
        np_label = '\eta''(\omega)';
        npp_label = '\eta''''(\omega)';
end

    % plot it out
	figure;
    hold on;
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'r');
    hold off;
    xlabel(freq_label);
	ylabel('log_{10}(modulus) [Pa]');
	h = legend(gp_label, gpp_label, 0);
	grid on;
	pretty_plot;
	
	figure;
    hold on;
	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'b');
	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r');
    hold off;
	xlabel(freq_label);
	ylabel('log_{10}(\eta'',\eta'''') [Pa sec]');
	legend(np_label, npp_label, 0);
	grid on;
	pretty_plot;
    
    