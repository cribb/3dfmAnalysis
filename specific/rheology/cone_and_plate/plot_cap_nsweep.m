function v = plot_cap_nsweep(strain, modulus, h, mytitle)

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

% Create multiple lines using matrix input to loglog
G = loglog(strain, modulus,'Marker','diamond','Color',[0.502 0.502 0.502]);
set(G(1), 'MarkerFaceColor',[0.502 0.502 0.502], ...
          'DisplayName','G''');
set(G(2), 'MarkerEdgeColor',[0.502 0.502 0.502], ...
          'DisplayName','G''''');

set(h, 'Name', 'nsweep');      
xlabel('shear strain, \gamma');
ylabel('modulus, G'', G'''' [Pa]');
legend('toggle');
title(mytitle);
pretty_plot;

v = 0;

