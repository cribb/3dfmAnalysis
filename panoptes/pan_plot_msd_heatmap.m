function heatmapfig = pan_plot_msd_heatmap(logmsdmap)

colorbar_limits = [-3.3 2];


heatmapfig = figure; 
set(heatmapfig, 'Visible', 'off');
imagesc(1:12, 1:8, logmsdmap); 
% imagesc(1:12, 1:8, log10(msdmap), colorbar_limits); 

colormap((hot));
cb = colorbar;

set(heatmapfig, 'Units', 'Pixels');
set(heatmapfig, 'Position', [300 300 800 600]);
set(gca, 'XTick', [1:12]');
set(gca, 'XTickLabel', [1:12]');
set(gca, 'XAxisLocation', 'top');
set(gca, 'YTick', [1:8]');
set(gca, 'YTickLabel', {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'});
cbticks = get(cb, 'YTick')';
cbtick_labels = cellstr([repmat('10^{', size(cbticks)) num2str(cbticks) repmat('}', size(cbticks))]);
set(cb, 'YTickLabel', cbtick_labels);
title('MSD (in log_{10} [m^2])');

my_alpha = ones(8,12);
my_alpha(isnan(logmsdmap)) = 0.5;
% im = get(gca, 'Children');
% set(im, 'AlphaData', alpha);
alpha(my_alpha);    
pretty_plot;
