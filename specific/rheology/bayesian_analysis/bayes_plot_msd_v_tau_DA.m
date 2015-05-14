function msd_DA = bayes_plot_msd_v_tau_DA(DA_struct)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% rename data for internal use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DA_curves = DA_struct.curves;
DA_names  = DA_struct.name;


% Compute the MSD statistics quantities used for plotting


if ~isempty(DA_curves)
    [~, row] = size(DA_curves.tau);
    if row > 1
        DA = msdstat(DA_curves);
    else
        DA.logtau = log10(DA_curves.tau);
        DA.logmsd = log10(DA_curves.msd);
    end
else
    DA.logtau = NaN;
    DA.logmsd = NaN;
end


% Generate the plot

msd_DA = figure;

hold on;
    plot(DA.logtau, DA.logmsd, 'g');
hold off;  
  

xlabel('log_{10}(\tau) [s]');
ylabel('log_{10}(MSD) [m^2]');

grid on;
box on;
pretty_plot;


return;