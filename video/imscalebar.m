function imscalebar(im, physlen, calib, units, location, color)
% 3DFM function  
% Video
% last modified 09/04/05 (jcribb)
% 
% Run a 2D force calibration using data from EVT_GUI.
% 
% [no output] =  imscalebar(im, physlen, calib, units, location); 
% 
% where "im" is the handle to a figure (or figure number).
%      "physlen" is the requested physical length of the scalebar.
%      "calib" is the calibration value from pixels to units of "units"
%      "units" is a string for the physical length units used in "calib", e.g. "microns"
%      "location" is the location of the scalebar:
%                "br" bottom-right, "bl" bottom left, "tr" top right, "tl" top left.
%      "color", b = blue, r = red, g = green, k = black, w = white, etc...
% 
   
% handle the argument list
if nargin < 6 | isempty(color);     color = 'k';                  end
if nargin < 5 | isempty(location);  location = 'br';              end
if nargin < 4 | isempty(units);     units = 'axis length units';  end
if nargin < 3 | isempty(calib);     calib = 1;                    end
if nargin < 2 | isempty(physlen);   physlen = 10;                 end
if nargin < 1 | isempty(im);        im = gcf;                     end

% Now, let's get started.
figure(im);
ax = gca;
set(ax, 'YDir', 'Normal');  % hack it this way until later

% get the current limits on the axis we're interested in
xlim = get(ax, 'XLim');
xlo = xlim(1);
xhi = xlim(2);
ylim = get(ax, 'YLim');
ylo = ylim(1);
yhi = ylim(2);
xrange = range(xlim);
yrange = range(ylim);

% how long in pixels do we need the scale bar?
L = physlen / calib;

% Where do we want to put the scalebar?
switch location
    case 'tr'
        barlocx = xhi - 0.1 * xrange - L;
        barlocy = yhi - 0.1 * yrange;    
    case 'bl'
        barlocx = xlo + 0.1 * xrange;
        barlocy = ylo + 0.1 * yrange;
    case 'tl'
        barlocx = xlo + 0.1 * xrange;
        barlocy = yhi - 0.1 * yrange;        
    otherwise  % put the scalebar on the 'br'
        barlocx = xhi - 0.1 * xrange - L;
        barlocy = ylo + 0.1 * yrange;
end

% ok now draw the line
hold on;
    line([barlocx,  barlocx + L], ...
         [barlocy barlocy], ...
         'Color', color, ...
         'LineWidth', 4);
    text(mean([barlocx, barlocx + L]), ...
         barlocy - 0.01 * yrange, ...
         [num2str(physlen) ' ' units],  ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'top', ...
         'Color', color);
hold off;

axis off;

