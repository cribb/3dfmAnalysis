function winout = msd_gen_taus(framemax, numtaus, percent_duration)


    % percent_duration refers to proportion of data used in determining the
    % msd (1 = all data, 0.5 half data)
    if nargin < 3 || isempty(percent_duration)
        percent_duration = 1;
    end
    
    newFRAMEmax = floor(framemax*percent_duration);
    
    if numtaus >= newFRAMEmax
        logentry('Too many windows for the available number of frames. Reducing to every instance of best case.');
        winout(:,1) = 1:newFRAMEmax-1;
        return;
    end
        
    
    w = 0;
    N = numtaus;
    while w == 0
    
        
        logtaus = round(logspace(0,log10(newFRAMEmax),N));
        window_vect = unique(logtaus);
        
        window_vect( window_vect > newFRAMEmax) = [];
        
        if length(window_vect) == numtaus
            w = 1;
        elseif length(window_vect) < numtaus
            N = N + 1;
        end
        
    end
    
    
    
%     winout = NaN(1,numtaus);
%     winout(1:length(window_vect)) = window_vect;    
    
    winout = window_vect(:);
return;
    
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'msd_gen_taus: '];
     
     fprintf('%s%s\n', headertext, txt);
return;