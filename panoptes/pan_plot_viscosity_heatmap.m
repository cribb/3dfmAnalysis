function heatmapfig = pan_plot_viscosity_heatmap(visc)

colorbar_limits = [-3.3 2];

% Heat map
heatmapfig = figure; 
% imagesc(1:12, 1:8, heatmap_msds); 
imagesc(1:12, 1:8, log10(visc), colorbar_limits); 
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
title('Viscosity (in log_{10} [Pa s])');
    my_alpha = ones(8,12);
    my_alpha(isnan(visc)) = 0.5;
    im = get(gca, 'Children');
    alpha(my_alpha);
%     set(gcf, 'AlphaData', my_alpha);
    
pretty_plot;
