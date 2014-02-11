function heatmapfig = pan_plot_heatmap(data, type, colorbar_limits)

% handle the input parameters
if nargin < 1 || isempty(data)
    error('No data to plot.');
end

if nargin < 2 || isempty(type)
    error('No heatmap plottype defined.');
end

if nargin < 3 || isempty(colorbar_limits)
    colorbar_limits = [-3.3 2];
end

% set the differences for the plot based on the plot type
switch type    
    case 'rms displacement'
        data = data * 1e9;
        mytitle = 'RMS Displacement (in log_{10} [nm]';
        colorbar_limits = [0 200];
        mycolormap = hot(256);
        logdata = 0;
    case 'msd'
%         data = log10(data);
        mytitle = 'MSD (in log_{10} [m^2])';
        colorbar_limits = [-16 -12];
        mycolormap = hot(256);
        logdata = 1;
    case 'viscosity'
%         data = log10(data);
        mytitle = 'Viscosity (in log_{10} [Pa s])';
        colorbar_limits = [-3.3 2];
        mycolormap = hot(256);
        logdata = 1;
    case 'longest tracker duration'        
        mytitle = 'Longest Tracking Duration [s]';
        colorbar_limits = [0 max(data(:))+eps];
        mycolormap = winter(256);
        logdata = 0;
    case 'image SNR'
        mytitle = 'Image SNR';
        colorbar_limits = [0 max(data(:))+eps];
        mycolormap = hot(256);
        logdata = 0;
    case 'num trackers'
        mytitle = 'Number of trackers';
        colorbar_limits = [0 max(data(:))+eps];
        logdata = 0;
        mycolormap = winter(256);
    case 'MCU parameter'
        mytitle = 'MCU parameter';
        colorbar_limits = [0 max(data(:))+eps];
        logdata = 0;
        mycolormap = winter(256);
    otherwise
        error('Heatmap plottype not defined');
end

% Now, plot whatever heatmap we have
heatmapfig = figure; 
set(heatmapfig, 'Visible', 'off');
imagesc(1:12, 1:8, data, colorbar_limits); 
colormap(mycolormap);
cb = colorbar;
set(heatmapfig, 'Units', 'Pixels');
set(heatmapfig, 'Position', [300 300 800 600]);
set(gca, 'XTick', [1:12]');
set(gca, 'XTickLabel', [1:12]');
set(gca, 'XAxisLocation', 'top');
set(gca, 'YTick', [1:8]');
set(gca, 'YTickLabel', {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'});
cbticks = get(cb, 'YTick')';
if logdata
    cbtick_labels = cellstr([repmat('10^{', size(cbticks)) num2str(cbticks) repmat('}', size(cbticks))]);
else
    cbtick_labels = num2str(cbticks);
end
set(cb, 'YTickLabel', cbtick_labels);
title(mytitle);

% setup the alpha for the NaN entries (meaning no data)
my_alpha = ones(8,12);
my_alpha(isnan(data)) = 0.5;
im = get(gca, 'Children');
alpha(my_alpha);

pretty_plot;

return;

