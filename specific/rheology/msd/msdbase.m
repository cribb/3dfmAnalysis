function varargout = msdbase(tpos, tau)
% 3DFM function  
% Rheology 
% last modified 07/31/06 -kvdesai
%  
% Computes mean-square displacements for varying window-length (Tau)
% from given time vs position data.
%  
% USAGE:
%
%  [msd, Tau] = msdbase(tpos, tau)  
%  [msd, Tau, ste_d, ste_t, count] = msdbase(tpos, tau)
%   
% Inputs:
%   tpos: matrix with N rows and D+1 columns containing coordinates of 
%         N points in D dimensions, with timestamps in the first column. 
%         Sample rate is considered to be the mean time interval between 
%         successive samples. If data is not evenly sampled it would be 
%         resampled at double of the original mean sample rate using linear
%         interpolation. 
%            
%   tau:  vector with lenght M containing desired window-sizes [in seconds]
%           If tau is not supplied then it is constructed such that each
%           decade has five points [1, 2, 3, 5, 7]. So, if S =sampling rate
%           default tau = [1/S, 2/S, 3/S, 5/S, 7/S, 10/S, 20/S..., MaxTau]
%            Where MaxTau is 7 units in the longest decade available for 
%            the given duration, or 70 seconds, whichever is less. 
%            For example, 
%            MaxTau = 0.07     for                  duration  <= 0.7 second
%            MaxTau = 0.7      for     0.7 second  < duration <= 7 seconds
%            MaxTau = 7        for       7 seconds < duration <= 70 seconds
%            MaxTau = 70       for      70 seconds < duration
%       
% Outputs:
%       msd: M x 1 vector containing msd value for each given window-length
%       Tau: M x 1 vector containing the actual 'tau' in units of seconds.
%               Output Tau is same as or really close to input tau.
%       ste_d: M x 1 vector containing standard error value for squared
%               displacement for each given window-length
%       ste_t: M x 1 vector containing standard error value for the window
%               lengths. Use this when time stamps are uneven.
%       count: M x 1 vector containing number of points that fell within each
%               window
%
pos = tpos(:,2:end);
t = tpos(:,1);
dt = diff(t);
srate = 1/mean(dt);
CLIP_TAU = 70; %Clip Tau to 70 seconds
% If tau is not supplied, generate in logspace from 1/srate to MaxTau
if (nargin < 2) | isempty(tau) 
    decapt = [1; 2; 3; 5; 7]; %points in each decade. Arbitrariy chosen.
    Nord = floor(log10(range(t))); %the order of the highest full decade
    Nord_maxpt = max(decapt)*10^Nord;
    if Nord_maxpt >= range(t)
        %ensure that longest tau is not longer than duration
        Nord_maxpt = max(decapt)*10^(Nord-1);
    end
    maxTau = min(CLIP_TAU,Nord_maxpt);
    Ndeca = ceil(log10(srate*maxTau)); % number of useful decades
    mul = (1/srate)*(10.^[0:1:Ndeca-1]);
    taumat = decapt*mul;
    tau = reshape(taumat,1,[]);% vectorize   
end

% Check that time stamps are evenly spaced. Interpolation is wrong since 
% diffusion is a nonlinear process, but we will go with interpolation until
% we have alternate method.
if std(dt) > 1E-2/srate %less than 1 percent spread allowed in sample-intervals. Arbitrarily chosen.
%     srate = 10000;    %resample at double of the original sample-rate. 
%     disp(['MSD: Timestamps were unevenly spaced. Will resample at ',num2str(srate),' Hz and interpolate.']);    
%     tnew = t(1):1/srate:t(end);
%     for c = 1:size(pos,2)
%         posnew(:,c) = interp1(t,pos(:,c),tnew); % interpolate with new sampling rate
%     end
%     clear t pos;
%     t = tnew; pos = posnew; 
%     clear tnew posnew;
    disp('MSDBASE: Time stamps are uneven by more than 1%. You should use errorbars for Tau also.'); 
end

win = ceil(tau*srate); % window-lengths in units of number of samples

% CORE CODE: Computation of mean-squared-displacements
for w = 1:length(win)    
    A = pos(1:end-win(w),:);
    B = pos(win(w)+1:end,:);
    r2 = sum((B - A).^2, 2); % squared displacement    
    
    count(w,1) = length(r2);
    if count(w,1) == 0 %Avoid 'divide by zero' warning when computing standard error
        msd(w,1) = NaN;
        ste_d(w,1) = NaN;
        Tau(w,1) = NaN;
        ste_t(w,1) = NaN;
    else
        msd(w,1) = mean(r2); 
        ste_d(w,1) = std(r2)/sqrt(count(w,1));
        %     Tau(w,1) = win(w)/srate; % Actual tau used
        tdiff = t(win(w)+1:end) - t(1:end-win(w));
        Tau(w,1) = mean(tdiff);
        ste_t(w,1) = std(tdiff)/sqrt(count(w,1));
    end
end

switch nargout
    case 5
        varargout{1} = msd;
        varargout{2} = Tau;
        varargout{3} = ste_d;
        varargout{4} = ste_t;
        varargout{5} = count;
    case 2
        varargout{1} = msd;
        varargout{2} = Tau;
    otherwise
        disp('MSDBASE error: Unrecognized number of output arguments');
end