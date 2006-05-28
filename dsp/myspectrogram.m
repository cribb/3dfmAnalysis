function varargout = myspectrogram(sig, rate, tres, window_type, clrmap)
% 3DFM function  
% DSP 
% last modified 05/04/06 - kvdesai
%  
% This function computes the spectrogram for the input signal. Spectrogram is 
% the magnitude of the short-term, time-localized Fourier transform of the signal.
% Function signature:
%  [s, f, t] = myspectrogram(signal, rate, fres, window_type,clrmap);  
%   
%  where 
%    "signal" is a one column vector
%    "rate" is the sampling rate in units of [Hz] [required argument] 
%    "tres"  is the desired time resolution in seconds
%         default value is the the one that gives equal number of points on
%         time and frequency axis.
%    "window_type" could be any of
%         'blackman' 'rectangle' 'hamming' 'hann', defaulting to 'blackman'
%    "clrmap" could be any of the matlab recognized colormaps.
%         Default is gray.
% 
%    "s" is the estimated short-term, time-localized frequency content 
%     of signal (Nf x Nt) 
%    "f" is the frequencies at which the spectrogram is computed (Nf x 1) 
%    "t" is the time-vector at which the spectrogram is computed (1 x Nt)
%    "p" is the psd of each segment (Nf x Nt)    
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
if(nargin < 3 | isempty(tres))
    % here we don't want the finest possible resolution in frequency,
    % because that will result in psd (only 1 bin for time) and not spectrogram.
    % Instead, we want frequency resolution that is the best trade, i.e. 
    % it should result in equal points on frqeuncy axis and time axis. 
    % It could be easily shown that if 
    % Nt = number of points on time axis and
    % Nf = number of points on frequency axis then
    % Nt*Nf = total number of points in the data. 
    %               (Nt+1)*(Nf-1) = N, to be precise, but we ignore 1 
    % Then for the condition Nt = Nf,  Nf = sqrt(N) = Nt.
    % Apply this to tres = span/Nt and fres = srate/(2*Nf);
    tres = (size(sig,1)/rate)/ceil(sqrt(size(sig,1)));  
%     fres = rate/(2*floor(sqrt(size(sig,1))));
end

% fres = 1/(2*tres);
% nw = fix(rate/(2*fres))*2;

nw = fix(rate*tres)*2; %length of fft, make it even

if (nw > size(sig,1))
    disp('myspectrogram ERROR: Time resolution can not be greater than time span');
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

%    [s,f,t] = spectrogram(x,window,noverlap,nfft,fs)
[s f t p] = spectrogram(sig(:,1), win, nw/2, nw, rate);

switch nargout
    case 1
        varargout{1} = s;
    case 3
        varargout{1} = s;
        varargout{2} = f;        
        varargout{3} = t;
    case 4
        varargout{1} = s;
        varargout{2} = f;        
        varargout{3} = t;
        varargout{4} = p;
    otherwise
        args = {f,t,10*log10(abs(p')+eps)};         
        surf(args{:},'EdgeColor','none');
        axis xy; axis tight;
        colormap(clrmap); view(0,90);

        ylabel('Time [s]');
        xlabel('Frequency [Hz]');
end
