function v = dmbr_mean_creep_curve(table, seq_width);
% averages across all sequences.  data are interpolated to 1kHz in order to
% remove the possiblity of discrepancies between the number of availble
% points from sequence to sequence.
% 
% mean creep curves are only valid across sequences of the same bead, and
% for sequences where the net displacement is more or less constant from
% curve to curve.

dmbr_constants;

% determine the minimum time difference between all points.  If this value
% is less than 0.001 second (aka 1 kHz) break out and generate an error.
smallest_dt = min(diff(table(:,TIME)));

% check for the existence of more than one tracker.  if so, break.
if length(unique(table(:,ID))) > 1
    error('More than one tracker exists in this dataset.  The results will not be valid.  Exiting now.');
end

% iterate across sequences
available_sequences = unique(table(:,SEQ))';

for k = available_sequences
    idx = find(table(:,SEQ) == k);

    t = table(idx,TIME);
    x = table(idx,X);
    y = table(idx,Y);
    j = table(idx,J);
    
    t = t - t(1);
    x = x - x(1);
    y = y - y(1);
    j = j - j(1);
    
    tnew = [0 : 1/1000 : seq_width-1/1000]';
    xnew = interp1(t, x, tnew);
    ynew = interp1(t, y, tnew);
    jnew = interp1(t, j, tnew);
    
    if ~exist('x_aggregate')
        x_aggregate = xnew(:);
        y_aggregate = ynew(:);
        j_aggregate = jnew(:);
    else
        x_aggregate = [x_aggregate, xnew(:)];
        y_aggregate = [y_aggregate, ynew(:)];
        j_aggregate = [j_aggregate, jnew(:)];
    end
    
end
    
meanx = nanmean(x_aggregate,2);
meany = nanmean(y_aggregate,2);
meanj = nanmean(j_aggregate,2);

xerr = nanstd(x_aggregate,[],2)/sqrt(cols(x_aggregate));
yerr = nanstd(y_aggregate,[],2)/sqrt(cols(y_aggregate));
jerr = nanstd(j_aggregate,[],2)/sqrt(cols(j_aggregate));

v.t    = tnew(1:10:end);
v.x    = meanx(1:10:end);
v.y    = meany(1:10:end);
v.j    = meanj(1:10:end);
v.xerr = xerr(1:10:end);
v.yerr = yerr(1:10:end);
v.jerr = jerr(1:10:end);
v.xraw = x_aggregate(1:10:end,:);
v.yraw = y_aggregate(1:10:end,:);
v.jraw = j_aggregate(1:10:end,:);
