function [im_mean, im_stderr] = bin2d(x, y, Fxy, x_bins, y_bins)
% 3DFM function  
% Utilities 
% last modified 07/31/06 (jcribb)
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


    for k = 1 : length(x_bins)-1
		for m = 1 : length(y_bins)-1
            
            idx = find( x >= x_bins(k) & x < x_bins(k+1) ...
                      & y >= y_bins(m) & y < y_bins(m+1));

            % we have to divide by length(idx) so if there's no data in
            % this particular bin, just set that bin to NaN to avoid pesky
            % divide by zero errors.
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
