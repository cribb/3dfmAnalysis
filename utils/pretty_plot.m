function pretty_plot(fig, type, mag)
% PRETTY_PLOT Changes proportional sizes of Fonts and axis data for screen or print output.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%
% This function changes the font sizes and weights for any given figure
% (or the current figure if no input parameter is used) so that when pasted 
% into a document, the axis labels and values are easily readable.
% 
% pretty_plot(fig);
%
% where "fig" is the matlab figure number (can use gcf here if desired)
%

if nargin < 3 || isempty(mag)
    mag = 1;
end

if nargin < 2 || isempty(type)
    type = 'screen';
    mag = 1;
end

if nargin < 1 || isempty(fig)
    fig = gcf;
    type = 'screen';
    mag = 1;
end

switch type
    case 'screen'
        plot_figure_for_screen(fig);
    case 'eps'
        plot_figure_for_eps(fig, mag);
    otherwise
% need a msg here
end

return;

function plot_figure_for_screen(fig)

    axes = get(fig, 'Children');
    
    for k = 1 : length(axes)

        try
            titl = get(axes(k), 'Title');
            legd = legend;
            xlab = get(axes(k), 'Xlabel');
            ylab = get(axes(k), 'Ylabel');

            set(titl, 'FontSize', 16, 'FontWeight', 'Bold');
            set(legd, 'FontSize', 14, 'FontWeight', 'Bold');
            set(xlab, 'FontSize', 14, 'FontWeight', 'Bold');
            set(ylab, 'FontSize', 14, 'FontWeight', 'Bold');
            set(axes(k), 'FontSize', 14, 'FontWeight', 'Bold');
        catch
%             logentry('something weird happened when setting figure properties.');
        end        
    end
    
    return;
    
function plot_figure_for_eps(fig, mag)

    ax_fnt_sz = 12;
    fnt_sz = 14;
    mark_sz = 6;

%     ax_fnt_sz = 20;
%     fnt_sz = 24;
%     mark_sz = 10;

%     ax_fnt_sz = 30;
%     fnt_sz = 36;
%     mark_sz = 16;
    
    factor = 117/6 * 1/mag;
    ysize =       factor * ax_fnt_sz;  % testimage is 117mm tall, font is 6mm tall
    xsize = 5/4 * factor * ax_fnt_sz;  % testimage is 138mm wide, font is 4mm wide
    
    pos = [xsize/4 ysize/4 xsize ysize];
    set(fig, 'Units', 'points');
    set(fig, 'Position', pos);
    ax = get(fig, 'Children');

    for k = 1 : length(ax)

        try
            titl = get(ax(k), 'Title');
            legd = legend;
            xlab = get(ax(k), 'Xlabel');
            ylab = get(ax(k), 'Ylabel');

            set(  titl, 'FontSize',    fnt_sz, 'FontWeight', 'Normal');
            set(  legd, 'FontSize',    fnt_sz, 'FontWeight', 'Normal');
            set(  xlab, 'FontSize',    fnt_sz, 'FontWeight', 'Normal');
            set(  ylab, 'FontSize',    fnt_sz, 'FontWeight', 'Normal');
            set( ax(k), 'FontSize', ax_fnt_sz, 'FontWeight', 'Normal');
        catch
%            logentry('something weird happened when setting figure properties.');
        end        
        
        axis_children = get(ax, 'Children');
        
%         for m = 1:length(axis_children);
%             obj = axis_children(m);
%             if findstr(get(obj, 'type'), 'line');
%                  if ~strcmp(get(obj, 'Marker'), 'none')
%                     set(obj, 'MarkerSize', mark_sz);
%                  end
%                  
%                  if ~strcmp(get(obj, 'LineStyle'), 'none')
%                      set(obj, 'LineWidth', 1);
%                  end                 
%             end                        
%         end
    end
return;

function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pretty_plot: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;