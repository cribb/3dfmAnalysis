function pretty_plot(fig)
% 3DFM function
% Utilities
% last modified 01/03/05
%
% This function changes the font sizes and weights for any given figure
% (or the current figure if no input parameter is used) so that when pasted 
% into a document, the axis labels and values are easily readable.
% 
% pretty_plot(fig);
%
% where "fig" is the matlab figure number (can use gcf here if desired)
%
% 
% 08/02/03 - created; jcribb
% 01/03/05 - fixed case-sensitive typo; jcribb
%

if nargin == 0
    fig = gcf;
end

axes = gca(fig);
titl = get(axes, 'Title');
legd = legend;
xlab = get(axes, 'Xlabel');
ylab = get(axes, 'Ylabel');

set(titl, 'FontSize', 14, 'FontWeight', 'Bold');
set(legd, 'FontSize', 12, 'FontWeight', 'Bold');
set(xlab, 'FontSize', 12, 'FontWeight', 'Bold');
set(ylab, 'FontSize', 12, 'FontWeight', 'Bold');
set(axes, 'FontSize', 12, 'FontWeight', 'Bold');

