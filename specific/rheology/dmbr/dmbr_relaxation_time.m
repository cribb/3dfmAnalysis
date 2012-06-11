function out = dmbr_relaxation_time(rheo_table, params)

    dmbr_constants;
    voltages    = params.voltages;
    bead_radius = params.bead_radius * 1e-6;
    calib_um    = params.calibum;
    poleloc     = params.poleloc;
    trackers    = unique(rheo_table(:,ID))';

    idx = find( rheo_table(:,VOLTS) == 0);

    if length(idx) > 1
        t = rheo_table(idx,TIME);
        r = rheo_table(idx,RADIAL);
        n = 1; % number of taus
        [J,tau,R_square] = relaxation_time(t, r, n, 'off');
        xy = mean(rheo_table(idx,X:Y));
        out = [tau, R_square];

    else
        logentry('No data for this segment. Reporting NaN.');
        out = [NaN, NaN];

    end

return; 

% %%%
% extraneous functions
% %%%

% % Prints out a log message complete with timestamp.

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_relaxation_time: '];
     fprintf('%s%s\n', headertext, txt);
    
    return    

