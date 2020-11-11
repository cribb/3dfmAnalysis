function v = gser(tau, msd, bead_radius)
% GSER computes complex modulus and viscosity from Generalized Stokes-Einstein Relation
%

    kb = 1.3806e-23;
    T = 298;
    timeblur_decade_fraction = .3;

    % trim out NaNs   
    tau = tau( ~isnan(tau));
    msd = msd( ~isnan(tau), :);
    
    logtau = log10(tau);
    logmsd = log10(msd);

    % preseed alpha matrix
    alpha = NaN(size(msd));
    MYgamma = NaN(size(msd));
    
    for k = 1:size(msd,2)

        [myalpha, ~, ~] = getMSDSlope(logtau, logmsd(:,k), timeblur_decade_fraction);

        alpha(1:length(myalpha),k) = myalpha;

    end

    MYgamma = gamma(1 + abs(alpha));
    % get frequencies all worked out from timing (tau)
    f = 1 ./ tau;
    w = 2*pi*f;

    % compute shear and viscosity
    gstar = (2/3) * (kb*T) ./ (pi * bead_radius .* msd .* MYgamma);
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