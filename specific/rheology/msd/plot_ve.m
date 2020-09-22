function h = plot_ve(v, freq_type, h, optstring)
% PLOT_VE plots the viscoelastic moduli from an inputted ve structure 
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
%        "h" is the handle of the figure into which to plot the data
%        "optstring" is any combination of the following characters:
%                                       'G' for storage modulus, G'(w)
%                                       'g' for loss modulus, G''(w)
%                                       'S' for complex modulus, |G*(w)|
%                                       'N' for viscosity, n'(w)
%                                       'n' for elasticity, n''(w)
%                                       's' for complex viscosity, |n*(w)|
%
%  An example: plot_ve(data, 'f', 1, 'Nns') to plot 'data' viscosity, 
%              elasticity, and complex viscosity on the same figure.
%  

if nargin < 4 || isempty(optstring)
    optstring = 'Nn';
end

if nargin < 3 || isempty(h)
    h = figure;
end

if nargin < 2 || isempty(freq_type)
    freq_type = 'f';
end

if nargin < 1 || isempty(v.tau)
    logentry('No data to plot.  Exiting now.');
    close(h);
    h = [];
    return;
end
    
% pull out the variables we need for the plot from the ve data structure.
f   = v.f;
w   = v.w;
tau = v.tau;
msd = v.msd;
gp  = v.gp;
gpp = v.gpp;
np  = v.np;
npp = v.npp;
gstar = sqrt(gp.^2 + gpp.^2);
nstar = sqrt(np.^2 + npp.^2);
N   = v.Ntrackers;

gperr = v.error.gp;
gpperr= v.error.gpp;
nperr = v.error.np;
npperr= v.error.npp;

gstarerr = sqrt((gp + gperr).^2 + (gpp + gpperr).^2);
nstarerr = sqrt((np + nperr).^2 + (npp + npperr).^2);

% setting up axis transforms for the figures plotted below.  You cannot plot
% errorbars on a loglog plot, it seems, so we have to set them up here.
logtau = log10(tau);
logf   = log10(f);
logw   = log10(w);

loggp  = log10(gp);
loggpp = log10(gpp);
lognp  = log10(np);
lognpp = log10(npp);

loggstar  = log10(gstar);
lognstar  = log10(nstar);

loggperr  = log10(gp+gperr) - log10(gp);
loggpperr = log10(gpp+gpperr) - log10(gpp);
lognperr  = log10(np + nperr) - log10(np);
lognpperr = log10(npp + npperr) - log10(npp);

loggstar_err = log10(gstar + gstarerr) - log10(gstar);
lognstar_err = log10(nstar + nstarerr) - log10(nstar);

% select the desired depiction of frequency
switch freq_type
    case 'f'
        plot_freq = logf;
        freq_label = 'log_{10}(f) [Hz]';
        gp_label = 'G''(f)';
        gpp_label = 'G''''(f)';
        np_label = '\eta''(f)';
        npp_label = '\eta''''(f)';
        gstar_label = 'G*(f)';
        nstar_label = '\eta*(f)';
    case 'w'
        plot_freq = logw;
        freq_label = 'log_{10}(\omega) [rad/s]';
        gp_label = 'G''(\omega)';
        gpp_label = 'G''''(\omega)';
        np_label = '\eta''(\omega)';
        npp_label = '\eta''''(\omega)';
        gstar_label = 'G*(\omega)';
        nstar_label = '\eta*(\omega)';
end


figure(h);
% clf(h);

leg = [];
y_label = [];
unit_label = [];

hold on;

    if regexp(optstring, 'G')
        errorbar(plot_freq, real(loggp), real(loggperr), 'b');
        y_label{length(y_label)+1} = 'G''';
        leg{length(leg)+1} = gp_label;
    end

    if regexp(optstring, 'g')
        errorbar(plot_freq, real(loggpp), real(loggpperr), 'b--');
        y_label{length(y_label)+1} = 'G''''';
        leg{length(leg)+1} = gpp_label;
    end

    if regexp(optstring, 'S')
        errorbar(plot_freq, loggstar, loggstar_err, loggstar_err, ...
                 'Color', [0 0.75 0.75], 'LineWidth', 2);
        y_label{length(y_label)+1} = '|G*|';
        leg{length(leg)+1} = gstar_label;
    end
    
    if regexp(optstring, 'N')
        errorbar(plot_freq, real(lognp), real(lognperr), 'r');
        y_label{length(y_label)+1} = '\eta''';
        leg{length(leg)+1} = np_label;
    end

    if regexp(optstring, 'n') 
        errorbar(plot_freq, real(lognpp), real(lognpperr), 'r--');
        y_label{length(y_label)+1} = '\eta''''';
        leg{length(leg)+1} = npp_label;
    end

    if regexp(optstring, 's')    
        errorbar(plot_freq, lognstar, lognstar_err, lognstar_err, ...
                 'Color', [0.75 0 0.75], 'LineWidth', 2);
        y_label{length(y_label)+1} = '|\eta*|';
        leg{length(leg)+1} = nstar_label;
    end
    
    if regexpi(optstring, 'g') | regexp(optstring, 'S')
        unit_label = [unit_label, ' [Pa]'];
    end

    if regexpi(optstring, 'n') | regexp(optstring, 's')
        unit_label = [unit_label, ' [Pa s]'];
    end
    
    if isempty(optstring)
        plot(0,0);
        full_ylabel=[];
    end
    
    

hold off;

for k = 1:length(y_label)
    if k == 1
        full_ylabel = y_label{1};
    else
        full_ylabel = [full_ylabel ', ' [y_label{k}]];        
    end    
end

full_ylabel = ['log_{10}(' full_ylabel ') ' unit_label];


  xlabel(freq_label);
  ylabel(full_ylabel);
  legend(leg);
  grid on;
  pretty_plot;

 
    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'plot_ve: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    