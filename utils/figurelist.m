function figs = figurelist;

	% Get the handles to the figures to process.
	if ~nargin                              % If no input arguments...
       figs = findobj('Type', 'figure');    % ...find all figures.
       figs = sort(figs);
	end

