function varargout=sampleKKR(f, psd)
% SAMPLEKKR averages a power spectrum so there's an equal number of points per decade of frequency   
%
% 3DFM function
% specific\rheology\kkr
% last modified 11/20/08 (krisford)
%
%		    sampleKKR(f, psd)
%    psd  = sampleKKR(f, psd)
% [f psd] = sampleKKR(f, psd)
%
% This function averages a power spectrum so there's
% an equal number of points per decade of frequency.
% For example, this function would give you points from a
% 0.1 Hz resolution dataset at 
% 
% 		0.1, 0.2, 0.3, ...
%		  1,   2,   3, ...
%        10,  20,  30, ...  Hz
%
% Specifying no output arguments constructs a plot of the PSD
% before and after the averaging process.  Having only one 
% argument outputs the PSD vector only, while using both output
% arguments will give you the PSD and the frequencies where
% those values reside (in Hz).
%
% 11/01/2002 - created
% 07/28/2003 - updated help information and beautified code

count = 1;
    f = f';
    a = log10(f(2));
    b = log10(f(end));

for n = a : b
	for m=1:9
		if (m-1)*10^n < f(end)
			new_f(count) = m * 10^n;
			count = count + 1;	
		end
	end
end

for n = 1 : length(new_f)
	c = find(f < new_f(n));
	p(n) = c(end);
	new_psd(n) = psd(p(n));
end

for n = 1 : length(new_f)-1
	if floor(log10(new_f(n))) <= a
		smoothed_psd(n) = new_psd(n);
	else
		g = mean([new_f(n-1) new_f(n)]);
		h = mean([new_f(n) new_f(n+1)]);
		
		freq_range=find(f > g & f < h);
		smoothed_psd(n) = 10^mean(log10((psd(freq_range))));
	end

end

new_f=new_f(1:end-1);
new_w=new_f/(2*pi);


switch nargout
	case 1
		varargout = {smoothed_psd};
	case 2
		varargout = {new_f, smoothed_psd};
	otherwise 
		figure(1); 
		loglog(f    , psd,          'b', ...
			   new_f, smoothed_psd, 'r');
	    legend('original', 'smoothed');
		title(['Power Spectral Density']);
		xlabel('frequency (Hz)');
		ylabel('Power');
	end
