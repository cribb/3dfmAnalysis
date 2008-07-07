function v = plot_cap_fsweep(freq, modulus, h, mytitle, freqspec)
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
G = loglog(freq, modulus,'Marker','diamond','Color',[0.502 0.502 0.502]);
set(G(1), 'MarkerFaceColor',[0.502 0.502 0.502], ...
          'DisplayName','G''');
set(G(2), 'MarkerEdgeColor',[0.502 0.502 0.502], ...
          'DisplayName','G''''');
set(h, 'Name', 'fsweep');
xlabel(freqlabel);
ylabel('modulus, G'', G'''' [Pa]');
legend('toggle');
title(mytitle);

pretty_plot;

v = 0;

