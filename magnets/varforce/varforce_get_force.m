function [F,e] = varforce_get_force(calib, rad_pos, voltage)
% VARFORCE_GET_FORCE takes varforce calib. file,rad. position,volt. and returns force
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%  
% varforce_getforce takes a varforce calibration file, a radial position and 
% a voltage and returns the force +/- most likely error at that voltage and 
% position.  If a voltage or position that has not been tested, then the 
% values for force and error are interpolated from available data.
%
% [F,e] = varforce_get_force(calib, rad_pos, voltage)
%


volts      = calib.volts;
fit        = calib.fit;
fit_err    = calib.fiterror;

% interpolate for fits and high error and low err for a given voltage and
% distance for the poletip.
dVolts = abs(voltage - volts);
dVolts = dVolts(find(dVolts > 0));
smallest_dVolts = min(abs(dVolts));

smallest_dVolts = 0.001;

interp_volts(:,1) = min(volts) : smallest_dVolts : max(volts);
interp_fit        = interp1(volts, fit, interp_volts);
interp_fiterr     = interp1(volts, fit_err, interp_volts);
% interp_fiterr     = zeros(size(interp_fiterr));

idx = find(single(voltage) == single(interp_volts));

if length(idx) > 0
    
    N = length(rad_pos);

    es = repmat(abs(interp_fiterr(idx,1)), N, 1);
    ei = repmat(abs(interp_fiterr(idx,2)), N, 1);

    slope = repmat(interp_fit(idx,1), N, 1);
    icept = repmat(interp_fit(idx,2), N, 1);


    F(:,1)      = 10 .^ ( slope .* log10(rad_pos) + icept);
    errorH(:,1) = 10 .^ ( (slope - es) .* log10(rad_pos) + icept-ei);
    errorL(:,1) = 10 .^ ( (slope + es) .* log10(rad_pos) + icept+ei);

    force_errH = errorH - F;
    force_errL = F - errorL;
    
    e = [force_errH , force_errL];

else
    error('The requested voltage was not found.');
end


return;
