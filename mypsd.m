function varargout = mypsd(s, rate, res, window_type, style)
% [p,f] = mypsd(signal, rate, res, window_type, style);
% where windowtype = 'blackman' or 'rectangle', defaulting to 'blackman'

if(nargin < 5)
	style = '-';
end
if(nargin < 4)
   	windowtype = 'blackman';
end
if(nargin < 3)
  res = 1;
end

nw = fix(rate/(2*res))*2;

switch window_type
	case 'blackman'
		window = blackman(nw);
	case 'rectangle'
		window = ones(nw,1);
end
	

for i=1:size(s,2)
   % [Pxx,f]=pwelch(X, WINDOW,NOVERLAP,NFFT)
   % [p(:,i) f] = pwelch(s(:,i), blackman(nw), nw/2, nw, rate);  %original gbcode
   [p(:,i) f] = pwelch(s(:,i), window, nw/2, nw, rate);          %jac-hack
end

switch nargout
case 1
   varargout{1} = p;
case 2
   varargout{1} = p;
   varargout{2} = f;
otherwise
   loglog(f, p, style);
   zoom on;
   grid on;
end

   