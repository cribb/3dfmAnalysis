function out = RP_checkparams(RP_params)
%RP_CHECKPARAMS checks input for necessary ROLIE-POLY modeling parameters
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%
% RP_CHECKPARAMS checks input for necessary ROLIE-POLY modeling parameters.
% When parameters are missing, RP_CHECKPARAMS tries to fill in the missing
% information with default (and possibly non-relevant) parameter values.
%
% [out] = RP_checkparams(RP_params)
%
% where   "out" is the outputted RP structure (see RP_force_on_a_bead_surface) 
%         "RP_params" is the inputted RP data structure 
%

%------
% BEAD
%------

% a, bead radius in [m]
if ~isfield(RP_params, 'a');
    RP_params.a = 0.5e-6;
end

% rho, bead material density in [kg/m^3] (from specsheet)
if ~isfield(RP_params, 'rho');
    RP_params.rho = 1300;
end

% m, mass of bead in [kg]
% NOTE: potential method to break physics here by presetting a, rho, & m.
% Should probably add sanity check to ensure that physically sane values
% are used.
if ~isfield(RP_params, 'm');
    RP_params.m = 4/3*pi*RP_params.a.^3.*RP_params.rho;
end


%---------
% POLYMER
%---------
% these are the polymer parameters we get from fitting RP 
% to a step shear CAP measurement.

% Ge, Plateau Modulus in [Pa]
if ~isfield(RP_params, 'Ge');
    RP_params.Ge = 1;
end

% tr, retraction based time constant in [s]
if ~isfield(RP_params, 'tr');
    RP_params.tr = 2.2;
end

% td, thermal reptation time scale in [s]
if ~isfield(RP_params, 'td');
    RP_params.td = 22;
end

% eta_inf , viscosity at infinite shear from thinning plot in [Pa s]
% can be approximated by solvent viscosity
if ~isfield(RP_params, 'eta_bg');
    RP_params.eta_bg = 0.005;
end

% beta, RP parameter
if ~isfield(RP_params, 'beta');
    RP_params.beta = 1;
end

% delta, RP parameter
if ~isfield(RP_params, 'delta');
    RP_params.delta = -0.5;
end

%------------
% EXPERIMENT
%-----------
% these are the polymer parameters we get from fitting RP 
% to a step shear CAP measurement.

% F, applied or driving force to bead by magnet (1-100 pN is normal), [N]
if ~isfield(RP_params, 'F');
    RP_params.F = 1e-12;
end

% t0, init cond, [s]
if ~isfield(RP_params, 't0');
    RP_params.t0 = 0;
end

% x0, init cond, [m]
if ~isfield(RP_params, 'x0');
    RP_params.x0 = 0;
end

% v0, init cond, [m]
if ~isfield(RP_params, 'v0');
    RP_params.v0 = RP_params.F ./ (6*pi*RP_params.eta_bg.*RP_params.a);
end

% stress0, init cond, [Pa]
if ~isfield(RP_params, 'stress0');
    identity = zeros(9,2,9);
    identity(:,:,1:4:9) = 1;

    % Set stress to equilibrium based on RP definition.
    RP_params.stress0 = identity;
end

% duration, length of experiment, [s]
if ~isfield(RP_params, 'duration');
    RP_params.duration = 0.001;
end

out = RP_params;
