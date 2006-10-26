function pretty_plot(fig)
% 3DFM function
% Utilities
% last modified 07/25/05
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
% 07/25/05 - added support for multiple axes in figure (e.g. yy-overlays)
%

if nargin == 0
    fig = gcf;
end

axes = get(fig, 'Children');

for k = 1 : length(axes)
    
	titl = get(axes(k), 'Title');
	legd = legend;
	xlab = get(axes(k), 'Xlabel');
	ylab = get(axes(k), 'Ylabel');
	
	set(titl, 'FontSize', 16, 'FontWeight', 'Bold');
	set(legd, 'FontSize', 14, 'FontWeight', 'Bold');
	set(xlab, 'FontSize', 14, 'FontWeight', 'Bold');
	set(ylab, 'FontSize', 14, 'FontWeight', 'Bold');
	set(axes(k), 'FontSize', 14, 'FontWeight', 'Bold');
	
end