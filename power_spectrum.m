function [psd,f] = power_spectrum(t, x, sampling_rate);

[r c] = size(x);

fft_size = ceil(log(r)/log(2));
X = fft(x); %, 2 ^ fft_size);

Pxx = X .* conj(X) / fft_size;

f   = [0 : 1/t(end) : sampling_rate/2]';
psd = Pxx(1:length(Pxx)/2);
