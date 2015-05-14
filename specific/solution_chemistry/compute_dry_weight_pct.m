function wt_pct = compute_dry_weight_pct(dry_wt_struct)
% PAN_ROT2STAGE rotates a vector to ludl stage orientation
%
% Solution Chemistry function 
% 
% This function is used by the Panoptes analysis code to rotate a velocity
% vector inplace to coordinate directionality from the camera frame to the
% stage frame. The lower left corner of the stage (in the vicinity of
% optics channel 7) is considered the origin for both the X and Y
% coordinates.
% 
% newxy = pan_rot2stage(xy, wellid, theta) 
%
% where "newxy" is the 
%       "xy" is the 
%       "wellid" is the
%       "theta" is the
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can also be used manually from the matlab command line interface.
%

q = dry_wt_struct;

% mean_pan_wt = mean(q.pan_wt);
% mean_pan_plus_dry = mean(q.pan_plus_dry);

pan = mean(q.pan_wt);
panerr = stderr(q.pan_wt);

dry = mean(q.pan_plus_dry);
dryerr = stderr(q.pan_plus_dry);

if ~isfield(q, 'pan_plus_wet_times') || isempty(q.pan_plus_wet_times)
    len = length(q.pan_plus_wet);
    time = (0:len-1)*30+90;
else
    time = q.pan_plus_wet_times;
end

wetfit = polyfit(time, q.pan_plus_wet, 1);
wet_plus_pan = wetfit(2);
wet = wet_plus_pan - pan;
fit_err = uncertainty_in_linefit(time, q.pan_plus_wet, wetfit);
wet_plus_pan_err = fit_err(2);

weterr = wet_plus_pan_err + panerr;

dry_wt = dry - pan;
dry_wt_err = dryerr + panerr;

wt_pct = dry_wt / wet; 
wt_pct_err = abs( (dry_wt + dry_wt_err) / (wet - weterr) - wt_pct);

logentry(['Dry wt measurement: (' num2str(wt_pct*100, '%3.2f') ' +/- ' num2str(wt_pct_err*100, '%3.2f') ')%']);

return;