function [s, f, t, p] = myspectrogram(sig, rate, fres, window_type, clrmap)
% 3DFM function  
% DSP 
% last modified 05/04/06 - kvdesai
%  
% This function computes the spectrogram for the input signal. Spectrogram is 
% the magnitude of the short-term, time-localized Fourier transform of the signal.
% Function signature:
%  [s, f, t] = myspectrogram(signal, rate, fres, window_type,clrmap);  
%   
%  where "signal" is a matrix (each column is treated independently)
%        "rate" is the sampling rate in units of [Hz] [required argument] 
%		 "fres"  is the desired PSD resolution in [Hz]
%               default value is the maximum that could be achieved
%               for a given length of data.
%        "window_type" couldbe any of
%               'blackman' 'rectangle' 'hamming' 'hann', defaulting to 'blackman'
%        "clrmap" could be any of the matlab recognized colormaps.
%        Default is gray.
%          
%        "s" is the estimated short-term, time-localized frequency content of signal
%        "f" is the frequencies at which the spectrogram is computed
%        "t" is the vector of times at which the spectrogram is computed%        
%  Various Usages:
%           myspectrogram(signal, rate, ...);
%                Calculates spectrogram and plots it on semilogx surface.
%         s = myspectrogram(signal, rate, ...);
%   [s,f,t] = myspectrogram(signal, rate, ...);
% 
%  Notes:  
%  - Resolution cannot exceed 1/duration
%  - This function wraps the matlab inbuilt 'spectrogram' in easy-to-understand parameters  
%  05/04/06 - created by kvdesai

varargout = cell(nargout); %initialize outputs with empty cells
if(nargin < 5 | isempty(clrmap))  	clrmap = gray; end
if(nargin < 4 | isempty(window_type))  	window_type = 'blackman'; end
if(nargin < 3 | isempty(fres))
  fres = ceil(rate/size(sig,1));%the finest possible resolution with given data
end

nw = fix(rate/(2*fres))*2; %length of fft
if (nw > size(sig,1))
    disp('myspectrogram ERROR: Not enough data for requested frequency-resolution.');
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
        disp('myspectrogram ERROR: Unrecoginzed window type');        
        return;       
end

for c=1:size(sig,2)
%    [s,f,t] = spectrogram(x,window,noverlap,nfft,fs) 
   [s(:,:,c) f t p] = spectrogram(sig(:,c), win, nw/2, nw, rate); 
end

switch nargout
    case 1
        varargout{1} = s;
    case 3
        varargout{1} = s;
        varargout{2} = f;        
        varargout{3} = t;
    otherwise
        args = {f,t,10*log10(abs(p')+eps)};         
        surf(args{:},'EdgeColor','none');
        axis xy; axis tight;
        colormap(clrmap); view(0,90);

        ylabel('Time [s]');
        xlabel('Frequency [Hz]');
end
