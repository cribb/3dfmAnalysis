function plot_forcecal2d(xpos, ypos, force_map, error_map, plotstring)
% 3DFM function  
% Magnetics
% last modified 07/31/06 (jcribb)
%  
% Plots a 2D force calibration dataset.
%  
%   plot_forcecal2d(xpos, ypos, force_map, error_map, plotstring)
% 
% where  xpos,ypos are vectors containing x,y grid values
%        force_map is the matrix containing forces at xpos,ypos
%        error_map is the matrix containing std error values at xpos,ypos
%        plotstring is any combination of 'f' (forces), 'e' (error), and 's' (surface)
%


    if nargin < 4 | isempty(error_map)
        error_map = [];
    end
    
    % set up for generic plotting
    warning off MATLAB:griddata:DuplicateDataPoints; 
    
    % plot the surface
    if findstr('s', plotstring)
        figure;
        surf(xpos * 1e6, ypos * 1e6, force_map * 1e12);
        colormap(hot);
        xlabel('x [\mum]');
        ylabel('y [\mum]');
        zlabel('force [pN]');
    end
    
    % plot the binned output mean
    if findstr('f', plotstring)
        figure; 
        if findstr('e', plotstring) & (size(error_map) == size(force_map))
            subplot(1,2,1);
        end
        imagesc(xpos * 1e6, ypos * 1e6, force_map * 1e12);
        title('Mean Calibrated Force (pN)');
        xlabel('\mum'); ylabel('\mum');
        colormap(hot);
        colorbar; 
    end
    
    if findstr('e', plotstring) & (size(error_map) == size(force_map))
        % plot the binned output error
        if findstr('f', plotstring)
            subplot(1,2,2);
        end
        imagesc(xpos * 1e6, ypos * 1e6, error_map./force_map);
        title('Standard Error / Mean');
        xlabel('\mum'); ylabel('\mum');
        colormap(hot);
        colorbar;     
        set(gcf, 'Position', [65 153 1353 420]);
    end
