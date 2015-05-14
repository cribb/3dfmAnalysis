function msd_color = bayes_plot_msd_by_color(model_curve_struct)
% BAYES_PLOT_MSD_BY_COLOR
%
% Plots msd trajectores by model, where each model is a different color
%
% Created:       4/7/14, Luke Osborne
% Last modified: 4/7/14, Luke Osborne 
%


% Pull out the curve structure for each model type

N  = model_curve_struct.N_curve_struct;
D  = model_curve_struct.D_curve_struct;
DA = model_curve_struct.DA_curve_struct;
DR = model_curve_struct.DR_curve_struct;
V  = model_curve_struct.V_curve_struct;

% Compute the MSD statistics quantities used for plotting

if ~isempty(N)
    [~, row] = size(N.tau);
    if row > 1
        N = msdstat(N);
    else
        N.logtau = log10(N.tau);
        N.logmsd = log10(N.msd);
    end
else
    N.logtau = NaN;
    N.logmsd = NaN;
end

if ~isempty(D)
    [~, row] = size(D.tau);
    if row > 1
        D = msdstat(D);
    else
        D.logtau = log10(D.tau);
        D.logmsd = log10(D.msd);
    end
else
    D.logtau = NaN;
    D.logmsd = NaN;
end

if ~isempty(DA)
    [~, row] = size(DA.tau);
    if row > 1
        DA = msdstat(DA);
    else
        DA.logtau = log10(DA.tau);
        DA.logmsd = log10(DA.msd);
    end
else
    DA.logtau = NaN;
    DA.logmsd = NaN;
end

if ~isempty(DR)
    [~, row] = size(DR.tau);
    if row > 1
        DR = msdstat(DR);
    else
        DR.logtau = log10(DR.tau);
        DR.logmsd = log10(DR.msd);
    end
else
    DR.logtau = NaN;
    DR.logmsd = NaN;
end

if ~isempty(V)
    [~, row] = size(V.tau);
    if row > 1
        V = msdstat(V);
    else
        V.logtau = log10(V.tau);
        V.logmsd = log10(V.msd);
    end
else
    V.logtau = NaN;
    V.logmsd = NaN;
end


% Generate the plot

msd_color = figure;

hold on;
    plot(N.logtau,  N.logmsd, 'k');
    plot(D.logtau,  D.logmsd, 'm');
    plot(DA.logtau, DA.logmsd, 'g');
    plot(DR.logtau, DR.logmsd, 'r');
    plot(V.logtau,  V.logmsd, 'Color', [0.68,0.47,0]);
hold off;  
  

xlabel('log_{10}(\tau) [s]');
ylabel('log_{10}(MSD) [m^2]');

grid on;
box on;
pretty_plot;


return;