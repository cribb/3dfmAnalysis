function [xout, yout, idx, serh] = select_data_in_box(fig)
% SELECT_DATA_IN_BOX Given two corner locations, select only the data within.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)

	if nargin < 1 || isempty(fig)
        fig = gcf;
	end
	
	figure(fig);
	
	[xm, ym] = ginput(2);
	
	xlo = min(xm);
	xhi = max(xm);
	ylo = min(ym);
	yhi = max(ym);
        
	serh = get(gca, 'Children');
	
	x = get(serh, 'XData');
	y = get(serh, 'YData');
	
	if iscell(x)
% 		x = x{end};
% 		y = y{end};
        for k = 1:length(x)
            idx = find(x{k} > xlo & x{k} < xhi & y{k} > ylo & y{k} < yhi);
            x{k} = x{k}(idx);
            y{k} = y{k}(idx);
        end
        
        for k = length(x):-1:1
            if isempty(x{k})
                x(k) = [];
                y(k) = [];
            end
        end
        
        if length(x) == 1
            xout = x{1};
            yout = y{1};
        else
            logentry('Only keeping first series on which you clicked.');
            xout = x{1};
            yout = y{1};
            % This function typically assumes you've clicked on only one
            % dataset.  The simplest thing to do would be to extract just
            % the data in the first cell position.  Ideally you would want
            % to be able to extract all the information, or ask which
            % series, and what happens if the data aren't identically
            % sampled? oy
        end
    elseif isnumeric(x)
            idx = find(x > xlo & x < xhi & y > ylo & y < yhi);

            xout = x(idx);
            yout = y(idx);
    else
        error('Unknown behavior.');
    end
    
    return;
    
    
function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'select_data_in_box: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;
     
    