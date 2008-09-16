function h = plot_cap_fsweep(freq, modulus, h, mytitle, freqspec)
% 3DFM function  
% Rheology/cone_and_plate 
% last modified 16-09-2008 (jcribb)
%  
% Plots frequency sweep curves for cone and plate data.
%  
%  h = plot_cap_fsweep(freq, modulus, h, mytitle, freqspec)  
%   
%  where "h" is the input/output figure handle
%  "freq" is a vector containing tested frequencies
%  "modulus" is a matrix containing modulus values, G' and G'' columnwise
%  in [Pa]
%  "mytitle" is a string with title for figure
%  "freqspec" is one of the following strings 'ff', 'fw', 'wf', 'ww' where
%  the first letter indicates the units of frequency in the given data and
%  the second letter indicates the desired units of frequency in the
%  outputted figure.
%

if nargin < 5 || isempty('freqspec')
    freqspec = 'ff';
end

if nargin < 4 || isempty(mytitle)
    mytitle= '';
end

if nargin < 3 || isempty(h)
    h = figure; 
end

if nargin < 2
    error('No data specified.');
end

% To avoid the warnings that matlab barks out regarding plotting negative
% values in log space....
idx1 = find(modulus(:,1) < 0);
idx2 = find(modulus(:,2) < 0);
idxa = find(modulus(:,1) < 0 & modulus(:,2) < 0);

if ~isempty(idx1)
    modulus(idx1,1)  = NaN;
    logentry('Converted negative data to NaN.');
end

if ~isempty(idx2)
    modulus(idx2,2)  = NaN;
    logentry('Converted negative data to NaN.');
end

if ~isempty(idxa)
    freq(idxa) = NaN;
    logentry('Converted negative data to NaN.');
end

% Create axes
axes('Parent',     h, ...
     'YScale',     'log', ...
     'YMinorTick', 'on', ...
     'XScale',     'log',...
     'XMinorTick', 'on');
 
box('on');
hold('all');


switch freqspec
    case 'ff'
        freqlabel = 'frequency [Hz]';
    case 'fw'
        freq = freq / (2*pi);
        freqlabel = 'ang.freq., \omega [rad/s]';
    case 'wf'
        freq = freq * (2*pi);
        freqlabel = 'frequency [Hz]';
    case 'ww'
        freqlabel = 'ang. freq., \omega [rad/s]';
    otherwise
        error('Do not understand frequency type specified.');
end

% Create multiple lines using matrix input to loglog
G = loglog(freq, modulus,'Marker','diamond','Color','b');
set(G(1), 'MarkerFaceColor','b', ...
          'DisplayName','G''');
set(G(2), 'MarkerEdgeColor','b', ...
          'DisplayName','G''''');

xlabel(freqlabel);
ylabel('modulus, G'', G'''' [Pa]');
legend('toggle');
title(mytitle);

pretty_plot;

return;


% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'plot_cap_fsweep: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
