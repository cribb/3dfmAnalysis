function [msd,Tau] = msdbase(tpos, tau)
% 3DFM function  
% Rheology 
% last modified 02/26/06 -kvdesai
%  
% Computes mean-square displacements for varying window-length (Tau)
% from given time vs position data.
%  
% USAGE:
%
%  [msd, Tau] = msd(tpos, tau)  
%   
% Inputs:
%        tpos: matrix with N rows and D+1 columns containing coordinates of N points in D dimensions, 
%           with timestamps in the first column. If data is not evenly sampled
%           in time, it would be resampled and linearly interpolated at double of the
%           original mean sample rate. 
%        tau:  vector with lenght M containing desired window-sizes [in units of seconds]. 
%           default tau = [1 2 5 10 20 50 .... MaxTau]*1/srate. Where MaxTau is 5 units in the highest
%           full decade available for the given duration, or 5 seconds, whichever is less. For example, 
%             MaxTau = 0.05     for                 duration  <= 1 second
%             MaxTau = 0.5      for     1 second  < duration  <= 10 seconds
%             MaxTau = 5        for    10 seconds < duration 
%       
% Outputs:
%       msd: M x 1 vector containing msd value for each given window-length
%       Tau: M x 1 vector containing the actual 'tau' in units of seconds.
%       Output Tau is same as or really close to input tau.
%
pos = tpos(:,2:end);
t = tpos(:,1);
dt = diff(t);
srate = 1/mean(dt);

% If tau is not supplied, generate in logspace from 
% 1/srate to 1/10th of dataspan or 10 seconds (whichever is less).
if (nargin < 2) | isempty(tau) 
    decapt = [1; 2; 5]; %points in each decade. Arbitrariy chosen.
    maxTau = min(10,range(t)/10); %ensure that tau is not longer than span
    Ndeca = ceil(log10(srate*maxTau)); % number of decades
    mul = (1/srate)*(10.^[0:1:Ndeca-1]);
    taumat = decapt*mul;
    tau = reshape(taumat,1,[]);% vectorize   
end

% Check that time stamps are evenly spaced
if std(dt) > 1E-2/srate %less than 1 percent spread allowed in sample-intervals. Arbitrarily chosen.
    srate = srate*2;    %resample at double of the original sample-rate. 
    disp(['MSD: Timestamps were unevenly spaced. Will resample at ',num2str(srate),' Hz and interpolate.']);    
    tnew = t(1):1/srate:t(end);
    for c = 1:size(pos,2)
        posnew(:,c) = interp1(t,pos(:,c),tnew); % interpolate with new sampling rate
    end
    clear t pos;
    t = tnew; pos = posnew; 
    clear tnew posnew;
end

win = ceil(tau*srate); % window-lengths in units of number of samples

% CORE CODE: Computation of mean-squared-displacements
for w = 1:length(win)    
    A = pos(1:end-win(w),:);
    B = pos(win(w)+1:end,:);
    r2 = sum((B - A).^2, 2); % squared displacement    
    
    msd(w,1) = mean(r2);
    Tau(w,1) = win(w)/srate; % Actual tau used
end 