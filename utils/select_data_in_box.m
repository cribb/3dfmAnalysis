function [xout, yout, idx, serh] = select_data_in_box(fig)


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
		x = x{end};
		y = y{end};
	end
	
	idx = find(x > xlo & x < xhi & y > ylo & y < yhi);
	xout = x(idx);
	yout = y(idx);
    