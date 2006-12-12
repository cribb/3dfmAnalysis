function varforce_plot_powerlaw_vs_current(data, results)
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/06
%
% varforce plotting function that plots the powerlaw exponent 
% value vs. input current.  This checks for invariance of the 
% gradient of the force applied to the bead.
%
% varforce_plot_powerlaw_vs_current(data, results)
%
% where data is the 'data' substructure of the varforce output structure
%       results is the 'results' substructure of the varforce output structure
%

current       = results.volts / 2;
power_law_exp = results.fit(:,1);
errH          = results.force_errH;
errL          = results.force_errL;

h = figure;

    errorbar(current, power_law_exp, errH, errL, '.-');

    xlabel('Current [A]');
    ylabel('Power Law Exponent');

    set(gca, 'Xlim', [ 0 2.5]);      
    set(gca, 'Ylim', [-5   0]);

    grid on;
    
    set(h, 'Name', 'varforce: Powerlaw Exponents vs. Current')
    set(h, 'NumberTitle', 'off');

    pretty_plot;

return;
