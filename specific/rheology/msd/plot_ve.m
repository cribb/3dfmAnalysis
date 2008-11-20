function plot_ve(v, freq_type, h, optstring)
% PLOT_VE plots the viscoelastic moduli using the ve output structure 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
%
%  plot_ve(v, freq_type);  
%   
%  where "v" is the output structure of ve.
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%  

if nargin < 4 || isempty(optstring)
    optstring = 'Gn';
end

if nargin < 3 || isempty(h)
    h = figure;
end

if nargin < 2 || isempty(freq_type)
    freq_type = 'f';
end


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

mean_logf  = nanmean(logf,2);
mean_logw  = nanmean(logw,2);
mean_loggp = nanmean(loggp,2);
mean_loggpp= nanmean(loggpp,2);
ste_loggp  = nanstd(logtau,[],2) ./ sqrt(N);
ste_loggpp = nanstd(logmsd,[],2) ./ sqrt(N);

lognp = log10(np);
lognpp= log10(npp);
mean_lognp = nanmean(lognp,2);
mean_lognpp= nanmean(lognpp,2);
ste_lognp = nanstd(lognp,[],2) ./ sqrt(N);
ste_lognpp= nanstd(lognpp,[],2) ./ sqrt(N);


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


figure(h);
clf(h);

if strcmp(optstring, 'G')
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
    y_label = 'log_{10}(G'') [Pa]';
    leg = gp_label;
elseif strcmp(optstring, 'g')
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'b--');
    y_label = 'log_{10}(G'''') [Pa]';
    leg = gpp_label;
elseif strcmp(optstring, 'N')
	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'r');
    y_label = 'log_{10}(\eta'') [Pa s]';
    leg = np_label;
elseif strcmp(optstring, 'n') 
	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r--');
    y_label = 'log_{10}(\eta'''') [Pa s]';
    leg = npp_label;
elseif strcmp(optstring, 'Gg')
    hold on;
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'b--');
    hold off;
    y_label = 'log_{10}(G'',G'''') [Pa]';
    leg = {gp_label, gpp_label};
elseif strcmp(optstring, 'GgN')
    hold on;
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'b--');
	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'r');
    hold off;
    y_label = 'log_{10}(G'',G'''') [Pa], log_{10}(\eta'')';
    leg = {gp_label, gpp_label, np_label};
elseif strcmp(optstring, 'gn')
    hold on;
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'b--');
	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r--');
    hold off;
    y_label = 'log_{10}(G'''') [Pa], log_{10}(\eta'''')';
    leg = {gpp_label, npp_label};
elseif strcmp(optstring, 'Nn')
    hold on;
	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'r');
	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r--');
    hold off;
    y_label = 'log_{10}(\eta'',\eta'''') [Pa s]';
    leg = {np_label, npp_label};
elseif strcmp(optstring, 'GN')
    hold on;
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'r');
    hold off;
    y_label = 'log_{10}(G'') [Pa], log_{10}(\eta'') [Pa s]';
    leg = {gp_label, np_label};
elseif strcmp(optstring, 'GgNn')
    hold on;
	errorbar(plot_freq, real(mean_loggp), real(ste_loggp), 'b');
	errorbar(plot_freq, real(mean_loggpp), real(ste_loggpp), 'b--');	
    errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'r');
	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r--');
    hold off;
    y_label = 'log_{10}(G'',G'''') [Pa], log_{10}(\eta'',\eta'''') [Pa s]';
    leg = {gp_label, gpp_label, np_label, npp_label};
else
    error('No code for printing that one.');
end


  xlabel(freq_label);
  ylabel(y_label);
  h = legend(leg, 0);
  grid on;
  pretty_plot;
% % 	
% % 	figure;
% %     hold on;
% % 	errorbar(plot_freq, real(mean_lognp), real(ste_lognp), 'b');
% % 	errorbar(plot_freq, real(mean_lognpp), real(ste_lognpp), 'r');
% %     hold off;
% % 	xlabel(freq_label);
% % 	ylabel('log_{10}(\eta'',\eta'''') [Pa sec]');
% % 	legend(np_label, npp_label, 0);
% % 	grid on;
% % 	pretty_plot;
% %     
    
