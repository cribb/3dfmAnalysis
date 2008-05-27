function logfits = varforce_compute_sat_data(forces, params)
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/06
%
% Computes generates tables later used to produce plots of the loglog fit 
% of force vs distance and of current vs force.
% 
%   log_fits = varforce_compute_sat_data(forces,params);
%

% computes table of log force magnitude vs log radial distance for all 
% pulses whose original linear fit for force is within the user specified 
% error tolerance (error_tol)
voltages    = params.voltages;
poleloc     = params.poleloc;
poletip_radius = params.poletip_radius;
error_tol   = params.error_tol;
table_volts = forces.volts;

radpos      = magnitude(forces.xy);
raderr      = magnitude(forces.Fxyerr);
logpos      = log10(radpos);
logforce    = log10(magnitude(forces.Fxy));
logwt_r     = log10(1 ./ raderr);

% computes the linear fit with error for loglog force vs distance for each voltage
for k = 1 : length(voltages)
    idx = find(table_volts(:) == voltages(k));   
    order = 1;
    
    this_r     = logpos(idx); 
    this_force = logforce(idx); 
    this_wt    = logwt_r(idx);
    
    if length(this_r) > order
        myfit   = polyfitw(this_r, this_force , 1, [], this_wt);
        myerror = uncertainty_in_linefit(this_r,  this_force,  myfit);
        
        logfits.volts(k,1) = voltages(k);
        logfits.fit(k,:)   = myfit;
        logfits.fiterror(k,:) = myerror;
    else

        logentry('cannot compute error with only 2 points, reporting this fit as NaN');
        logfits.volts(k,1)    = voltages(k);
        logfits.fit(k,1:2)      = NaN;
        logfits.fiterror(k,1:2) = NaN;
    end


end

Fd       = logfits.fit(:,1);
fiterror = logfits.fiterror;
inter    = logfits.fit(:,2);

% calculate voltage vs distance table
rangepos  = range(radpos);
legend_distances = [10 12 15:5:50] * 1e-6;
distances = legend_distances + poletip_radius;

es = abs(fiterror(:,1));
ei = abs(fiterror(:,2));

gridforces = 10 .^ (Fd * log10(distances) + repmat(inter, 1, length(distances)));
errorH     = 10 .^ ( (Fd - es) * log10(distances) + repmat(inter-ei, 1, length(distances)));
errorL     = 10 .^ ( (Fd + es) * log10(distances) + repmat(inter+ei, 1, length(distances)));

logfits.distances        = distances;
logfits.legend_distances = legend_distances;
logfits.forces           = gridforces;
logfits.force_errH       = gridforces - errorH;
logfits.force_errL       = errorL - gridforces;


return;

%% Prints out a log messages if any.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforce_compute_sat_data: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
