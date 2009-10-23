function [tau, mymsd, time, xout, yout, zout] = msdt(t, data, tauwindow, dt)
% MSDT computes the mean-square displacements (via the Stokes-Einstein relation) for a single bead
%
% 3DFM function
% specific\rheology\msd
% last modified 09/05/09 (rspero) to handle 1, 2, and 3D
%  
% This function computes the mean-square displacements (via the Stokes-
% Einstein relation) for a single bead.
%  
% [tau, mymsd, time, , xout, yout] = msdt(t, data, tauwindow, dt, plot)   
%
% where "t" is the time
%       "data" is the matrix of data with x, y, z columns of position
%       "tauwindow" is a vector containing window sizes of tau when computing MSD
%       "dt" is the vector of starting times at which to evaluate msd
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

%Pre-allocate
tau   = NaN(length(tauwindow), length(dt)-1);
mymsd = tau;

%handle multiple dimensions
[datalength, numDimensions] = size(data);
if(numDimensions < 3)
    data(:,numDimensions+1:3) = NaN;
end

% for every window size (or tau)
warning('off', 'MATLAB:divideByZero');

    %Loop over time intervals
    for k = 1:length(dt)-1
        %Find all datapoints within this time interval
        idx = find(t > dt(k) & t < dt(k+1));
        % call up the MSD program to compute the MSD for each bead
        
        %If we have data on this bead in this time interval
        if ~isempty(t(idx))
            %Extract datapoints within this time interval
            neutdata = data(idx,:);
            xout(1:length(idx),k) = neutdata(:,1);
            yout(1:length(idx),k) = neutdata(:,2);
            zout(1:length(idx),k) = neutdata(:,3);
            
            %Set position at first time point to zero
            neutdata = neutdata - repmat(neutdata(1,:),size(neutdata,1),1);
            %Find MSD for this time interval
            [tau(:, k), mymsd(:, k), r2] = msd(t(idx), neutdata, tauwindow);
        else
            tau(:,k) = NaN;
            mymsd(:,k) = NaN;
        end
      
%        tau(k, :) = tauwindow(k) * mean(diff(t));
%        mymsd(k, :) = nanmean(r2,2);
        time(:,k) = repmat(dt(k), [length(tauwindow),1]);
    end

warning('on', 'MATLAB:divideByZero');

%surf(im_mean)
xout(xout==0) = NaN;
yout(yout==0) = NaN;
zout(zout==0) = NaN;

% [rows, cols] = size(xout);
% 
% D = mymsd ./(4*tau);
% Davg = nanmean(D);
%Plot Davg vs. Time
% figure;
% plot(time(1,:),Davg)
% xlabel('time');
% ylabel('D_{eff}');