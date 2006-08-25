function peak = processpeak(pp, pf,f,interactive)
% 3DFM function  
% DSP 
% Created 01/20/05 - kvdesai. 
% Last modified 08/24/06 - kvdesai
% Usage: peak = processpeak(pp, pf,fsearch,interactive)
%   pp = output of psd in units of [power/frequency] or [disp^2/frequency]
%   pf = frequency vector corresponding to pp
%   fsearch = search frequency
%   interactive = 0 or 1, select frquencies using cross-hair window.
%           if 1, then third argument is ignored ignored. Default 0.
% peak.p = power at fsearch
% peak.ampli = amplitude of sine wave at fsearch
% peak.fsearch = fsearch

if nargin < 4 | isempty(interactive) interactive = 0; end

fres = mean(diff(pf));%the step size in frequencies
if (~interactive)
    NBOTH = 3; %Number of bins to be integrated on both sides to calculate total power
    
    %find the index of pf that has value nearest to search frquency    
%     isrch = find(abs(pf - f) <= fres/2); 
    isrch = interp1(pf,[1:length(pf)],f,'nearest');    
    peak.p = 0;
    if    isnan(isrch)
        peak.f = []; % a signal that search frquency was out of the range of data provided.
%         keyboard;
    else
%         isrch = isrch(1); %Sometime the search freqeuncy could fall
%         exactly between two bins
        if(isrch - NBOTH >= 1) & (isrch + NBOTH <= length(pf)) 
            % search freq is not on either edge of the frequency range provided
            for k = 1:2*NBOTH+1
                inow = isrch - NBOTH-1+k;
                peak.p = peak.p + (pp(inow))*fres; %discrete integration over 2*NBOTH + 1 bins
            end
            peak.f = pf(isrch -NBOTH:isrch+NBOTH);
        elseif (isrch - NBOTH < 1)% 
            % search freq is on the lower edge of the frequency range
            for k = 1:NBOTH+isrch
                inow = k;
                peak.p = peak.p + (pp(inow))*fres; %discrete integration over NBOTH + 1 bins
            end  
            peak.f = pf(1:isrch+NBOTH);
        else
            % search freq is on the upper edge of the frequency range
            for k = 1:NBOTH+1+length(pf)-isrch
                inow = isrch-NBOTH-1+k;
                peak.p = peak.p + (pp(inow))*fres; %discrete integration over NBOTH + 1 bins
            end  
            peak.f = pf(isrch-NBOTH:end);
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
    
    

      