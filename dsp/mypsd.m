function varargout = mypsd(s, rate, res, window_type, style, calculateId)
% 3DFM function  
% DSP 
% last modified 09/11/05 - kvdesai
%  
% This function computes the power spectral density for input, s  
%  
%  [p,f] = mypsd(signal, rate, res, window_type, style, calculateId);
%  OR
%  [p,f,Id] = mypsd(signal, rate, res, window_type, style, calculateId);
%   
%  where "signal" is a matrix (columns denote different datasets)
%        "rate" is the sampling rate in units of [Hz] 
%		 "res"  is the desired PSD resolution in [Hz]
%        "window_type" couldbe any of
%               'blackman' 'rectangle' 'hamming' 'hann', defaulting to 'blackman'
%        "style" is matlab graph-style string
%        "calculateId" is 'yes' or 'no': a switch for calculating
%        integrated displacement upto the frequency, defaulted to 'no'
%  
%  Notes:  
%  - Resolution cannot exceed 1/time-span
%   
%   
%  ??/??/?? - created by gb.  
%  05/06/04 - added documentation; jcribb/kvdesai
%  05/07/04 - added integrated displacement option; kvdesai
%  
varargout = cell(nargout); %initialize outputs with empty cells
if(nargin < 6 | isempty(calculateId))
    calculateId = 'no';
end
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
    disp('mypsd ERROR: Not enough data for requested freuqncy-resolution.');
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
   if(findstr(calculateId,'y'))
       Id(1,i) = sqrt(p(1,i)*f(1));
       for j = 2:length(p(:,i))
           Id(j,i) = sqrt(Id(j-1,i)^2 + p(j,i)*(f(j)-f(j-1)));%discrete integration
       end
   end
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
       varargout{3} = Id;
	otherwise
       loglog(f, p, style);
       zoom on;
       grid on;
end

      