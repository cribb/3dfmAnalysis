function winout = msd_gen_taus(framemax, numtaus, percent_duration)


    % percent_duration refers to proportion of data used in determining the
    % msd (1 = all data, 0.5 half data)
    percent_duration = 1;
    
    newFRAMEmax = framemax*percent_duration;
    window_vect = unique(floor(logspace(0,round(log10(newFRAMEmax)), numtaus)));
    
    window_vect( window_vect >= newFRAMEmax) = [];
    
%     winout = NaN(1,numtaus);
%     winout(1:length(window_vect)) = window_vect;    
    
    winout = window_vect(:);
