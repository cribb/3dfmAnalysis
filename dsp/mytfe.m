function res = mytfe(x,y,srate);
%estimate the transfer function tf such that
%y(t) = conv(x(t),tf(t))
%srate = sampling rate
dbstop if error
if nargin < 1 % this is testing mode, no arguments are provided
    h = fir1(30,0.2,rectwin(31)); %true transfer function
    x = randn(100000,1);
    y = conv(h,x);
    srate = 10000;
end

resolution = 10;
y = y - mean(y);%detrending 
x = x - mean(x);
nw = fix(srate/(2*resolution))*2;
y = [y;zeros(length(y),1)]; %zero padding for elimination of circular convolution
x = [x;zeros(length(y) - length(x),1)];
% [Pxy,F] = CSD(X,Y,NFFT,Fs,WINDOW,NOVERLAP) returns a vector of frequen-
%     cies the same size as Pxy at which the CSD is estimated, and overlaps
%     the X and Y sections NOVERLAP samples.
[pxy fxy] = csd(x,y,nw,srate,nw,nw/2);
[pxx fxx] = csd(x,x,nw,srate,nw,nw/2);

tfxy = pxy./pxx;
figure(234)
loglog(fxy, abs(tfxy),'r.-');
xlabel('Frequency in Hz');
ylabel('Amplitude');
title('Estimated transfter function in frequency domain');
grid on;

% NOTE: the function csd reports only useful data points in the arrays pxy and pxx.
% i.e. if the nfft = 1000, only first 501 fft data points have useful 
% information - rest are repeatation. So csd will report only first 501 fft points into pxx. 
% Also the frequencies at which those 501 points are calculated will range from 
% 0 to half of sampling rate
%
% TO make this point more clear, take a simple case
% t = 0:0.001:0.6;
% z = sin(2*pi*50*t)+sin(2*pi*120*t);
% x = z + 2*randn(size(t));%x is the signal with 50 Hz and 120 Hz sinusoids and some noise
% fx = fft(x,512); %fft with frequency range [0 1:half of srate, half of srate:1]
% 
% CALCULATING MANUALLY
% In the simplest form the power spectrum  of x can be calculated as
% pxx = fx.*conj(fx);
% here this pxx is calculated at frequencies [0 1:half of srate, half of srate:1]
% CALCULATING WITH CSD 
% cpxx = csd(x,x,nfft,srate,window,noverlap)
% here, csd automatically removes the redundant data points, so that cpxx will contain
% power spectrum calculated at frequencies [0:half of srate] only

tf = ifft(tfxy);
% NOTE: # of data points in fft doesn't matter except for increasing resolution.
% BUT # of data pints in ifft does matter, because ifft reports the datapoints separated by
% 1/(length of i.p. array). This points can be plotted against time-in-seconds by dividing the
% separation with (sampling rate/2), since the highest frequency contained in the input to ifft 
% will be (sampling rate/2) and not the (sampling rate).

figure(235)
time  = (0:length(tf)-1)*2/srate; %Separation between two consequtive pts is 2/srate
plot(time,real(tf),'r.-'); 
xlabel('Time in seconds');
ylabel('Amplitude');
title('Estimated transfter function in time domain');
grid on;
if(nargin<1) % it this is a testing mode
    mh = [h';zeros(length(tfxy)-length(h),1)];
    fmh = fft(mh);
    fmax = round(length(fmh)/2);%the maximum frequency that would be contained in fmh
    freq = srate*(0:fmax)/length(fmh); % a meaningful frequency axis: 0 to sampling rate/2.
    figure(234)
    hold on
    loglog(freq,abs(fmh(1:fmax+1)),'b'); %plot only 0:half, another half is repeatation
    legend('Estimate','Truth');
    hold off
    figure(235)
    hold on
    plot((0:length(h)-1)/srate,h,'b');%Separation between two consequtive pts is 1/srate
    legend('Estimate','Truth');
    hold off
end

res.freq_domain.amp = tfxy;
res.freq_domain.freq = fxy;
res.time_domain.amp = tf;
res.time_domain.time = time;

dbclear if error