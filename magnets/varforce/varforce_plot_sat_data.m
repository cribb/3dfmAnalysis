function varforce_plot_sat_data(ins);
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/06
%  
% Plots current in [A] vs force in [pN] for multiple distance series.  This 
% plot conveys information regarding the saturation of the bead and/or 
% the poletip during a force calibration run.
%
%   varforce_plot_sat_data(ins);
%
% where "ins" is the resulting varforce data structure from 
% varforce_compute_sat_data.m 
%


% plots current vs. force for multiple distance series. The loop sorts input
% data such that different distances are plotted in distinct series.

% generate the legend
for k = 1:length(ins.legend_distances)
    legend_entries{k} = [num2str(round(ins.legend_distances(k)*1e6), '%11.1d') ' \mum'];
end

   
[nrows ncols] = size(ins.forces);
current = repmat(ins.volts, 1, ncols)/2;
dists   = repmat(ins.distances, nrows, 1);
forces  = ins.forces;
errorH  = ins.force_errH;
errorL  = ins.force_errL;

% pause(0.001);

h = figure;
figure(h);
% plot((current), (forces * 1e12), '.-')
errorbar(current, forces * 1e12, errorL * 1e12, errorH * 1e12, '.-');
xlabel('Current [A]');
ylabel('Force [pN]');
legend(legend_entries);
pretty_plot;


return;
