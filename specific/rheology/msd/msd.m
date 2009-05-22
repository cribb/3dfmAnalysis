function [tau, msd, r2out] = msd(t, data, window)
% MSD computes the mean-square displacements (via the Stokes-Einstein relation) for a single bead
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
%  
% [tau, msd] = msd(t, data, window);   
%
% where "t" is the time
%       "data" is the input matrix of data
%       "window" is a vector containing window sizes of tau when computing MSD. 
%
% Notes: - No arguments will run a 2D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%


%initializing arguments
if (nargin < 1) || isempty(t)  
    error('Input data needed.'); 
end;

if (nargin < 2) || isempty(data)  
    error('Input data needed.');
end;

if (nargin < 3) || isempty(window)  
    window = [1 2 5 10 20 50 100 200 500 1000 1001]; 
end;

% for every window size (or tau)
warning('off', 'MATLAB:divideByZero');

r2out = zeros(length(window), size(data,1)) * NaN;

    for w = 1:length(window)
    
      % for x,y,z (k = 1,2,3) directions  
      for k = 1:cols(data)
  
        % for all frames
        A = data(1:end-window(w), k);
        B = data(window(w)+1:end, k);
    
        r = (B - A);
        % var_r = sum((mean(r) - r).^2) / size(r,1);
        
        if k == 1
            r2 = r.^2;
        elseif k > 1
            r2 = r2 + r.^2;
        end
        
      end
      
        tau(w, :) = window(w) * mean(diff(t));
        msd(w, :) = mean(r2);
        r2out(w,1:length(r2)) = r2;
    end

warning('on', 'MATLAB:divideByZero');

return;



