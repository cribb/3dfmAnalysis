function results = msd_curves_bayes(timelags, MSD_curves, msd_params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Each MSD curve must be a column in the MSD_curves matrix.
%
% Parameters in msd_params:
%   .models: {'N','D','DA','DR','V','DV','DAV','DRV','DE','DAE',...}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright MIT 2012
% Developed by Nilah Monnier & Syuan-Ming Guo
% Laboratory for Computational Biology & Biophysics
%%%%%%%%


results = struct;


%%%% Mean MSD curve %%%%

MSD_mean = mean(MSD_curves,2);
MSD_mean_se = std(MSD_curves,0,2)/sqrt(size(MSD_curves,2));


%%%% Covariance matrix %%%%

errors = [];

% Get difference between each individual curve and the mean curve
for i=1:size(MSD_curves,2)
    errors(:,i) = MSD_curves(:,i) - MSD_mean;
end

errors = errors';
results.errors = errors;

% Calculate raw covariance matrix
msd_params.error_cov_raw = cov(errors);

% Regularize covariance matrix
msd_params.error_cov = cov_shrinkage(errors,1);

% Covariance of the mean curve
msd_params.error_cov_raw = msd_params.error_cov_raw / size(errors,1);
msd_params.error_cov = msd_params.error_cov / size(errors,1);


%%%% Fitting %%%%

results.mean_curve = msd_fitting(timelags, MSD_mean, msd_params);

results.timelags = timelags;
results.mean_curve.MSD_vs_timelag = MSD_mean;
results.mean_curve.MSD_vs_timelag_se = MSD_mean_se;
results.msd_params = results.mean_curve.msd_params;
results.MSD_vs_timelag = MSD_curves;


end