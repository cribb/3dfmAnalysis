function varforce_plot_force_distance(data, results)
% VARFORCE_PLOT_FORCE_DISTANCE plots the powerlaw exponent value vs. input current 
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/18/08 (krisford)
%
% varforce plotting function that plots the powerlaw exponent 
% value vs. input current.  This checks for invariance of the 
% gradient of the force applied to the bead.
%
% varforce_plot_force_distance(data, results)
%
% where data is the 'data' substructure of the varforce output structure
%       results is the 'results' substructure of the varforce output structure
%

    % constants for log_fit and logtable
    log_fit_volts    =  results.volts;
    slope            =  results.fit(:,1);
    intercept        =  results.fit(:,2);

    radpos   = magnitude(data.xy);
    forcevec = magnitude(data.Fxy);
    err      = magnitude(data.Fxyerr);
    
    log_dist    = log10(radpos);
    logforce    = log10(magnitude(data.Fxy));

    table_volts = data.volts;
    these_volts = unique(table_volts);


    
    % set up table of distance for wich polyval will evaluate loglogfit
    min_dist   =  min(radpos);
    max_dist   =  max(radpos);
    range_dist =  range(radpos);
    dtable     =  [min_dist : range_dist/300 : max_dist];

    h = figure;

    clr  = 'bgrkmcy';

    for I=1:length(these_volts)
        idx = find(log_fit_volts == these_volts(I));
        
        if length(idx)>0
             fit_force = 10.^(slope(idx).*log10(dtable)+intercept(idx));
             figure(h);
             hold on;
             plot(dtable*1e6, fit_force * 1e12,[clr(mod(I,length(clr))+1) '-']);
             drawnow;
        end
        
        figure(h);
        hold on;
            idx=find(table_volts == these_volts(I));
%             plot(radpos(idx) * 1e6, forcevec(idx) * 1e12, [clr(mod(I,length(clr))+1) '.'])
            errorbar(radpos(idx) * 1e6, forcevec(idx) * 1e12, err(idx) * 1e12, [clr(mod(I,length(clr))+1) '.'])
            drawnow;
        hold off;
    end
    
    % final modifications to the output figure
    figure(h);
    xlabel('distance from pole tip [\mum]');
    ylabel('force [pN]');
    pretty_plot;
    
    return;
    
    



