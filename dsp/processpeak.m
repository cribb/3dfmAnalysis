function peak = processpeak(pp, pf,f)
% 3DFM function  
% DSP 
% Created 01/20/05 - kvdesai. Last modified 01/20/05 - kvdesai
% Usage: peak = processpeak(pp, pf,fsearch)
%   pp = output of psd in units of [power/frequency] or [disp^2/frequency]
%   pf = frequency vector corresponding to pp
%   fsearch = search frequency
% peak.p = power at fsearch
% peak.ampli = amplitude of sine wave at fsearch
% peak.fsearch = fsearch

    NBIN = 3; %Number of bins to be integrated on both sides to calculate total power
    fres = mean(diff(pf));%the step size in frequencies
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


      