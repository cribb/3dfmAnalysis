function [im_mean, im_stderr, im_count] = bin2d(x, y, Fxy, x_bins, y_bins)
% BIN2D Arranges 2D data into a matrix, no interp, computes average and stderr.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%  
% bin2d.m works like griddata for arranging 2D data into a matrix.  However, 
% instead of just averaging the values in a selected bin, it reports the 
% standard error as well.  Also, interpolation between values is not done.
% 
%  
% [im_mean, im_stderr] = forcecal_2d_binning(x, y, Fxy, x_bins, y_bins)  
%   
%  where "im_mean" and "im_stderr" are the output mean and standard error
%                                  matrices containing the binned data.
%        "x" and "y" are parameter values of "Fxy"  
%        "x_bins" and "y_bins" are vectors containing the data bins
%   

Lx = length(x_bins);
Ly = length(y_bins);

    for k = 1 : Lx
		for m = 1 : Ly

            % bin the data for all bins except the very last one (edge
            % condition).
            if (k ~= Lx) & (m ~= Ly)
                idx = find( x >= x_bins(k) & x < x_bins(k+1) ...
                          & y >= y_bins(m) & y < y_bins(m+1));
            else
                % have to handle the edge condition.
                idx = find( x >= x_bins(k) & y > y_bins(m) );
            end

            % we have to divide by length(idx) so if there's no data in
            % this particular bin, just set that bin to NaN to avoid pesky
            % divide by zero errors.
            im_count(m,k) = length(idx);
            if length(idx) > 0
                im_mean(m,k) = mean(Fxy(idx));
                im_stderr(m,k) = std(Fxy(idx))/sqrt(length(idx));
            else
                im_mean(m,k) = NaN;
                im_stderr(m,k) = NaN;
            end

        end
    end
            
    return;
