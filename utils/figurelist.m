function figs = figurelist
% FIGURELIST Returns a list of handles to opened Matlab figures.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%

	% Get the handles to the figures to process.
	if ~nargin                              % If no input arguments...
       figs = findobj('Type', 'figure');    % ...find all figures.
       figs = sort(figs);
	end

