function peak = processpeak(pp, pf,f,interactive)
% 3DFM function  
% DSP 
% Created 01/20/05 - kvdesai. 
% Last modified 09/23/05 - kvdesai
% Usage: peak = processpeak(pp, pf,fsearch,interactive)
%   pp = output of psd in units of [power/frequency] or [disp^2/frequency]
%   pf = frequency vector corresponding to pp
%   fsearch = search frequency
%   interactive = 0 or 1, select frquencies using cross-hair window.
%           if 1, then fsearch ignored.
% peak.p = power at fsearch
% peak.ampli = amplitude of sine wave at fsearch
% peak.fsearch = fsearch
fres = mean(diff(pf));%the step size in frequencies
if (~interactive)
    NBIN = 3; %Number of bins to be integrated on both sides to calculate total power
    i = find(abs(pf - f) < fres/2); %find the index of pf that has value nearest to search frquency
    peak.p = 0;
    if    isempty(i)
        peak.f = []; % a signal that search frquency was out of the range of data provided.
%         keyboard;
    else
        if(i - NBIN > 1)
            for k = 1:2*NBIN+1
                inow = i - NBIN-1+k;
                peak.p = peak.p + (pp(inow))*(pf(inow)-pf(inow-1)); %discrete integration over 2*NBIN + 1 bins
            end
            peak.f = pf(i -NBIN:i+NBIN);
        else % this might be the lowest frequency, so we don't have enough bins on lower side
            for k = 1:NBIN+1
                inow = i-1+k;
                peak.p = peak.p + (pp(inow))*(pf(inow)-pf(inow-1)); %discrete integration over NBIN + 1 bins
            end  
            peak.f = pf(i:i+NBIN);
        end
    end
    peak.ampli = sqrt(peak.p*2);%conversion from power to amplitude of sine wave
    peak.fsearch = f;
else %interactively choose frequencies
    [x y] = ginput(2);
    dbstop if error
    fmin = x(1,1); fmax = x(2,1);
    
    imin = max(find(pf <= fmin));
    imax = min(find(pf >= fmax));
    peak.p = 0;
    for k = imin:imax
        peak.p = peak.p + pp(k)*(pf(k) - pf(k-1));        
    end   
    peak.f = pf(imin:imax);
    peak.fsearch = mean(peak.f);
    peak.ampli = sqrt(peak.p*2);%conversion from power to amplitude of sine wave
end
    
    

      