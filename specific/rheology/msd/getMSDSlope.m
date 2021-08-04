function [alpha, tau_evenspace, msd_evenspace] = ...
                            getMSDSlope(logtau, logmsd, timeblur_decade_fraction, debugPlotTF)
% GETMSDSLOPE calculates slope over a smoothed window for msd curves already in log space
%
%
                        
if nargin < 4 || isempty(debugPlotTF)
    debugPlotTF = false;
end


% Find ranges of tau, prepare for interpolation
nBufferPoints = 2;
min_tau         = min(logtau);
tau_interp_step = min(diff(logtau))/2;
max_tau         = max(logtau);
tau_evenspace(:,1)   = (min_tau - tau_interp_step*nBufferPoints : tau_interp_step : max_tau + tau_interp_step*nBufferPoints);

% Handle case where empty dataset is sent
if isempty(logtau) || (isnan(min_tau) && isnan(max_tau))
    alpha = NaN;
    tau_evenspace = NaN;
    msd_evenspace = NaN;
    return;
end

%Interpolate MSD to get evenly spaced MSD data
warning('OFF', 'MATLAB:interp1:NaNinY');
msd_evenspace = interp1(logtau, logmsd, tau_evenspace, 'linear', 'extrap');

%Create some important constants
derivative_blur = timeblur_decade_fraction / tau_interp_step;
[m_interp,n_interp] = size(msd_evenspace);
[m, n] = size(logmsd);

%Take derivative of each bead's MSD (loop over beads)
alpha_evenspace = nan(m_interp,n_interp); %initialize alpha matrix
for i = 1:n_interp
    dMSDdTau = CreateGaussScaleSpace(msd_evenspace(:, i), 1, 0.5)/tau_interp_step;
%     alpha_evenspace(:, i) = dMSDdTau(nBufferPoints+1:end-nBufferPoints);
    alpha_evenspace(:, i) = dMSDdTau;
%     alpha_evenspace(:, i) = CreateGaussScaleSpace(msd_evenspace(:, i), 1, derivative_blur)/tau_interp_step;
%     mb  = polyfit(tau_interp_step, msd_evenspace, 1);
%     alpha_evenspace(:,i) = mb(1);
end

% Map indicies back to the original (uninterpolated) taus
tau_matrix = repmat(logtau', [m_interp 1]);
tau_evenspace_matrix = repmat(tau_evenspace, [1 m]);
diffmat = abs(tau_matrix - tau_evenspace_matrix);
C = min(diffmat, [], 2);
idx = 1:m_interp;
foo = [idx' C];
bar = sortrows(foo, 2);
tau_map_indicies = sortrows(bar(1:m)');

%Populate alpha matrix
alpha = NaN(size(logmsd)); %Initialize
alpha(:,:) = alpha_evenspace(tau_map_indicies,:);

alpha_evenspace(tau_evenspace < min(tau_evenspace)+3*timeblur_decade_fraction,:) = NaN;

if debugPlotTF
    h = figure;
    subplot(1,3,1);
    plot(tau_evenspace, msd_evenspace(:, 1:4:end), '.',...
         logtau, logmsd(:, 1:4:end), '-');
    xlabel('log(tau)');
    ylabel('log(msd)');
    pretty_plot;
    
    figure(h);
    subplot(1,3,2);
    plot(10.^tau_evenspace, alpha_evenspace, '-b');
    plot(tau, alpha, '.r');
    xlabel('tau');
    ylabel('alpha');
    set(gca, 'YLim', [0 1.5], 'XScale', 'Log');
    pretty_plot;

    % Plot MSDs colored by slope
    idx1 = find(alpha < 0.05 & alpha > -0.05);
    idx2 = find(alpha < 1.05 & alpha >  0.95);
    figure(h);
    subplot(1,3,3);
    plot(log10(tau(idx1)), log10(msd(idx1)), '.b');
    plot(log10(tau(idx2)), log10(msd(idx2)), '.r');
    xlabel('tau (s)');
    ylabel('msd');
    pretty_plot;
end

return;
