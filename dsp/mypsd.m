function varargout = mypsd(s, rate, res, window_type, style, obsoletearg)
% 3DFM function  
% DSP 
% last modified 12/22/05 - kvdesai
%  
% This function computes the power spectral density for input.
% Function signature:
%  [p, f, id] = mypsd(signal, rate,res, window_type, style, obsoletearg);
%   
%  where "signal" is a matrix (each column is a different signal)
%        "rate" is the sampling rate in units of [Hz] [required argument] 
%		 "res"  is the desired PSD resolution in [Hz]
%               default value is the maximum that could be achieved
%               for given length of data.
%        "window_type" couldbe any of
%               'blackman' 'rectangle' 'hamming' 'hann', defaulting to 'blackman'
%        "style" is matlab graph-style string
%        "obsoletearg" is what used to be the flag for 'calculateId'. 
%               This argument is now obsolete and ignored. Id is calculated when
%               number of output arguments are more than 2. (see Usage below) 
%               The argument is kept as a  placeholder so that old dependent 
%               code supplying 6 args doesn't break.  
%        "p" is the computed power-density [power/hz] at frequencies in "f"
%        "id" is the sqrt of area under the curve upto frequency "f"
%               'id' stands for 'integrated displacement'
%  Various Usages:
%           mypsd(signal, rate, ...);
%                Calculates psd (p and f) and plots it on loglog axes.
%       p = mypsd(signal, rate, ...);
%                Calculates psd and returns power-density (p).
%   [p,f] = mypsd(signal, rate, ...);
%                Calculates psd and returns p as well as frequencies (f).
%[p,f,id] = mypsd(signal, rate, ...);
%                Calculates psd as well as accumulated displacement 
%                and returns all: power-density(p), frequencies(f), accum. disp. (id)
%%  Notes:  
%  - Resolution cannot exceed 1/time-span
%    
%  ??/??/?? - created by gb.  
%  05/06/04 - added documentation; jcribb/kvdesai
%  05/07/04 - added integrated displacement option; kvdesai
%  
varargout = cell(nargout); %initialize outputs with empty cells
if(nargin < 5 | isempty(style))
	style = '-';
end
if(nargin < 4 | isempty(window_type))
   	window_type = 'blackman';
end
if(nargin < 3 | isempty(res))
  res = ceil(size(s,1)/rate);%the finest possible resolution with given data
end

nw = fix(rate/(2*res))*2;
if (nw > size(s,1))
    disp('mypsd ERROR: Not enough data for requested frequency-resolution.');
    disp('Time span of data should atleast be 1/resolution');
    return;   
end
win = zeros(nw,1);
switch window_type
	case 'blackman'
		win = blackman(nw);
	case 'rectangle'
		win = ones(nw,1);
    case 'hamming'
        win = hamming(nw);
    case 'hann'
        win = hann(nw);
    otherwise
        disp('ERROR: mypsd:: Unrecoginzed window type');        
        return;       
end

for i=1:size(s,2)
   % [Pxx,f]=pwelch(X, WINDOW,NOVERLAP,NFFT)   
   [p(:,i) f] = pwelch(s(:,i), win, nw/2, nw, rate); 
end

switch nargout
    case 1
        varargout{1} = p;
    case 2
        varargout{1} = p;
        varargout{2} = f;
    case 3
        varargout{1} = p;
        varargout{2} = f;
        % Integrated displacement = sqrt(area under psd)
        varargout{3} = sqrt(cumsum(p)*mean(diff(f)));
    otherwise
        loglog(f, p, style);
        zoom on;
        grid on;
end

      