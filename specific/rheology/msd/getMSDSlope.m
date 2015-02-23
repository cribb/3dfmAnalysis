function [alpha, tau_evenspace, msd_evenspace] =...
                            getMSDSlope (msd, tau, timeblur_decade_fraction)
%Get into log space
tau_exponents = log10(tau(:, 1));
msd_exponents = log10(msd);


%Find ranges of tau, prepare for interpolation
min_tau         = min(tau_exponents);
tau_interp_step = min(diff(tau_exponents))/2;
max_tau         = max(tau_exponents);
tau_evenspace   = (min_tau : tau_interp_step : max_tau)';

% handle case where empty dataset is sent
if isempty(tau) || (isnan(min_tau) && isnan(max_tau))
    alpha = NaN;
    tau_evenspace = NaN;
    msd_evenspace = NaN;
    return;
end

%Interpolate MSD to get evenly spaced MSD data
warning('OFF', 'MATLAB:interp1:NaNinY');
msd_evenspace = interp1(tau_exponents,...
                        msd_exponents,...
                        tau_evenspace ...
                        );

%Create some important constants
derivative_blur = timeblur_decade_fraction / tau_interp_step;
[m_interp,n_interp] = size(msd_evenspace);
[m, n] = size(msd);

%Take derivative of each bead's MSD (loop over beads)
alpha_evenspace = nan(m_interp,n_interp); %initialize alpha matrix
for i = 1:n_interp
    curve = msd_evenspace(:, i) / tau_interp_step;
    alpha_evenspace(:, i) = CreateGaussScaleSpace(curve, 1, derivative_blur);
end

% Map indicies back to the original (uninterpolated) taus
tau_matrix = repmat(tau_exponents', [m_interp 1]);
tau_evenspace_matrix = repmat(tau_evenspace, [1 m]);
diffmat = abs(tau_matrix - tau_evenspace_matrix);
C = min(diffmat, [], 2);
idx = 1:m_interp;
foo = [idx' C];
bar = sortrows(foo, 2);
tau_map_indicies = sortrows(bar(1:m)');

%Populate alpha matrix
alpha = msd * NaN; %Initialize
alpha(:,:) = alpha_evenspace(tau_map_indicies,:);

alpha_evenspace(tau_evenspace < min(tau_evenspace)+3*timeblur_decade_fraction,:) = NaN;

if(0)
    figure;
    hold on
    plot(tau_evenspace, msd_evenspace(:, 1:4:end), '.',...
         tau_exponents, msd_exponents(:, 1:4:end), '-');
    xlabel('log(tau)');
    ylabel('log(msd)');
    pretty_plot;
    hold off
    
    figure;
    hold on
    plot(10.^tau_evenspace, alpha_evenspace, '-b');
    plot(tau, alpha, '.r');
    xlabel('tau');
    ylabel('alpha');
    set(gca, 'YLim', [0 1.5], 'XScale', 'Log');
    hold off

    %Plot MSDs colored by slope
    idx1 = find(alpha < 0.05 & alpha > -0.05);
    idx2 = find(alpha < 1.05 & alpha >  0.95);
    figure;
    hold on
    plot(log10(tau(idx1)), log10(msd(idx1)), '.b');
    plot(log10(tau(idx2)), log10(msd(idx2)), '.r');
    xlabel('tau (s)');
    ylabel('msd')
    hold off
end

return;
