function v = gser(tau, msd, Ntrackers, bead_radius)
    k = 1.3806e-23;
    T = 298;

%     A = tau(1:end-1,:);
%     B = tau(2:end,:);
%     C = msd(1:end-1,:);
%     D = msd(2:end,:);

%     alpha = log10(D./C)./log10(B./A);

    
    % trim out NaNs
    mymsd = msd( ~isnan(tau));
    mytau = tau( ~isnan(tau));

    timeblur_decade_fraction = .3;
    [myalpha, tau_evenspace, msd_evenspace] = getMSDSlope(mymsd, mytau, timeblur_decade_fraction);

    alpha = NaN(size(msd));
    alpha(1:length(myalpha)) = myalpha;
    
    MYgamma = gamma(1 + abs(alpha));
    % gamma = 0.457*(1+alpha).^2-1.36*(1+alpha)+1.9;

    % because of the first-difference equation used to compute alpha, we have
    % to delete the last row of f, tau, and msd values computed.
    % msd = msd(1:end-1,:);
    % tau = tau(1:end-1,:);
    % Ntrackers = Ntrackers(1:end-1,:);

    % get frequencies all worked out from timing (tau)
    f = 1 ./ tau;
    w = 2*pi*f;

    % compute shear and viscosity
    gstar = (2/3) * (k*T) ./ (pi * bead_radius .* msd .* MYgamma);
    gp = gstar .* cos(pi/2 .* alpha);
    gpp= gstar .* sin(pi/2 .* alpha);
    nstar = gstar .* tau;
    np = gpp .* tau;
    npp= gp  .* tau;


    %
    % setup very detailed output structure
    %

    v.f = f;
    v.w = w;
    v.tau = tau;
    v.msd = msd;
    v.alpha = alpha;
    v.gamma = MYgamma;
    v.gstar = gstar;
    v.gp = gp;
    v.gpp = gpp;
    v.nstar = nstar;
    v.np = np;
    v.npp = npp;

return;