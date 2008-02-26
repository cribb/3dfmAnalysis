function [tau, mymsd, time] = msdt(t, data, tauwindow, dt)
% 3DFM function  
% Rheology 
% last modified 11/06/2007
%  
% This function computes the mean-square displacements (via the Stokes-
% Einstein relation) for a single bead.
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

if (nargin < 3) || isempty(tauwindow)  
    tauwindow = [1 2 5 10 20 50 100]; 
end;

if (nargin < 3) || isempty(dt)
%     frame_rate = 120;
    dt = 0:floor(t(end)); 
end;


% load in the constants that identify the output's column headers for the current
% version of the vrpn-to-matlab program.
video_tracking_constants;


% for every window size (or tau)
warning('off', 'MATLAB:divideByZero');

    for k = 1:length(dt)-1
        idx = find(t > dt(k) & t < dt(k+1));
        % call up the MSD program to compute the MSD for each bead
        
        if ~isempty(t(idx))
            neutdata = data(idx,:);
            neutdata = neutdata - repmat(neutdata(1,:),size(neutdata,1),1);
            [tau(:, k), mymsd(:, k)] = msd(t(idx), neutdata, tauwindow);
        else
            tau(:,k) = NaN;
            mymsd(:,k) = NaN;
        end
      
%         tau(k, :) = tauwindow(k) * mean(diff(t));
%         mymsd(k, :) = mean(r2);
        time(k,:) = dt(k);
    end

warning('on', 'MATLAB:divideByZero');


% tau = 0;
% mymsd = 0;


