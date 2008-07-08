function v = plot_cap_ssweep(stress, modulus, h, mytitle)

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
    stress(idxa) = NaN;
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

% Create multiple lines using matrix input to loglog
G = loglog(stress, modulus,'Marker','diamond','Color',[0.502 0.502 0.502]);
set(G(1), 'MarkerFaceColor',[0.502 0.502 0.502], ...
          'DisplayName','G''');
set(G(2), 'MarkerEdgeColor',[0.502 0.502 0.502], ...
          'DisplayName','G''''');
set(h, 'Name', 'ssweep');
xlabel('shear stress, \sigma [Pa]');
ylabel('modulus, G'', G'''' [Pa]');
legend('toggle');
title(mytitle);
pretty_plot;

v = 0;

% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'plot_cap_ssweep: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return