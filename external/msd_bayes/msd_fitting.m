function results = msd_fitting(timelags, MSD_vs_timelag, msd_params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Fits the provided MSD curve with the models contained in msd_params.models
%
% Parameters in msd_params:
%   .models: {'N','D','DA','DR','V','DV','DAV','DRV','DE','DAE',...}
%   .error_cov
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright MIT 2012
% Developed by Nilah Monnier & Syuan-Ming Guo
% Laboratory for Computational Biology & Biophysics
%%%%%%%%


% Default settings:
if ~isfield(msd_params,'models')
    msd_params.models = {'N','D','DA','DR','V','DV','DAV','DRV'};
end

msd_params.prior_scale = 200;   % multiple of the std error in each parameter after fitting

% Bounds on fitting; also used as prior ranges if prior_range='manual'
msd_params.lower_b.C = 0;
msd_params.upper_b.C = 1000;
msd_params.lower_b.D = 0;
msd_params.upper_b.D = 1000;
msd_params.lower_b.A = 0;
msd_params.upper_b.A = 1;
msd_params.lower_b.R = 0;
msd_params.upper_b.R = 1000;
msd_params.lower_b.V = 0;
msd_params.upper_b.V = 1000;
msd_params.lower_b.E = 0;
msd_params.upper_b.E = 100;

results.msd_params = msd_params;

warning('off','MATLAB:nearlySingularMatrix')


%%%%%% FITTING %%%%%%%

nan = find(isnan(MSD_vs_timelag));
MSD_vs_timelag(nan) = [];
timelags(nan) = [];

if ~isempty(find(ismember(msd_params.models,'N'),1))
    % Fit MSD with a constant: MSD = C = 6*sigmaE^2
    nparam_N = 1;
    f_N = inline('b-x+x','b','x');
    [coeffs_N resnorm_N residuals_N e o l J L] = lsqcurvefit_GLS(f_N,0.01,timelags,MSD_vs_timelag,msd_params.error_cov,msd_params.lower_b.C,msd_params.upper_b.C,optimset('Display','off'));
    J = full(J);   
    COVB_N = resnorm_N/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_N,residuals_N,'covar',COVB_N);
    results.N.C = coeffs_N;
    results.N.C_se = se;
    results.N.C_cilo = ci(1);
    results.N.C_cihi = ci(2);
end

if ~isempty(find(ismember(msd_params.models,'D'),1))
    % Fit MSD with diffusion alone: MSD = 6*D*t
    nparam_D = 1;
    f_D = @(b,x) 6*b*x;
    [coeffs_D resnorm_D residuals_D e o l J L] = lsqcurvefit_GLS(f_D,0.01,timelags,MSD_vs_timelag,msd_params.error_cov,msd_params.lower_b.D,msd_params.upper_b.D,optimset('Display','off'));
    J = full(J);   
    COVB_D = resnorm_D/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_D,residuals_D,'covar',COVB_D);
    results.D.D = coeffs_D;
    results.D.D_se = se;
    results.D.D_cilo = ci(1);
    results.D.D_cihi = ci(2);
end

if ~isempty(find(ismember(msd_params.models,'DE'),1))
    % Fit MSD with diffusion alone plus error: MSD = 6*sigmaE^2 + 6*D*t
    nparam_DE = 2;
    f_DE = @(b,x) 6*b(1)^2 + 6*b(2)*x;
    [coeffs_DE resnorm_DE residuals_DE e o l J L] = lsqcurvefit_GLS(f_DE,[0.01 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D],[msd_params.upper_b.E msd_params.upper_b.D],optimset('Display','off'));
    J = full(J);   
    COVB_DE = resnorm_DE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DE,residuals_DE,'covar',COVB_DE);
    results.DE.E = coeffs_DE(1);
    results.DE.E_se = se(1);
    results.DE.E_cilo = ci(1,1);
    results.DE.E_cihi = ci(1,2);
    results.DE.D = coeffs_DE(2);
    results.DE.D_se = se(2);
    results.DE.D_cilo = ci(2,1);
    results.DE.D_cihi = ci(2,2);
end

if ~isempty(find(ismember(msd_params.models,'DA'),1))
    % Fit MSD with anomalous diffusion alone: MSD = 6*D*t^alpha
    nparam_DA = 2;
    f_DA = @(b,x) 6*b(1)*x.^b(2);
    [coeffs_DA resnorm_DA residuals_DA e o l J L] = lsqcurvefit_GLS(f_DA,[0.01 1],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.D msd_params.lower_b.A],[msd_params.upper_b.D msd_params.upper_b.A],optimset('Display','off'));
    J = full(J);
    COVB_DA = resnorm_DA/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DA,residuals_DA,'covar',COVB_DA);
    results.DA.D = coeffs_DA(1);
    results.DA.D_se = se(1);
    results.DA.D_cilo = ci(1,1);
    results.DA.D_cihi = ci(1,2);
    results.DA.A = coeffs_DA(2);
    results.DA.A_se = se(2);
    results.DA.A_cilo = ci(2,1);
    results.DA.A_cihi = ci(2,2);
end

if ~isempty(find(ismember(msd_params.models,'DAE'),1))
    % Fit MSD with anomalous diffusion alone plus error: MSD = 6*sigmaE^2 + 6*D*t^alpha
    nparam_DAE = 3;
    f_DAE = @(b,x) 6*b(1)^2 + 6*b(2)*x.^b(3);
    [coeffs_DAE resnorm_DAE residuals_DAE e o l J L] = lsqcurvefit_GLS(f_DAE,[0.01 0.01 1],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D msd_params.lower_b.A],[msd_params.upper_b.E msd_params.upper_b.D msd_params.upper_b.A],optimset('Display','off'));
    J = full(J);
    COVB_DAE = resnorm_DAE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DAE,residuals_DAE,'covar',COVB_DAE);
    results.DAE.E = coeffs_DAE(1);
    results.DAE.E_se = se(1);
    results.DAE.E_cilo = ci(1,1);
    results.DAE.E_cihi = ci(1,2);
    results.DAE.D = coeffs_DAE(2);
    results.DAE.D_se = se(2);
    results.DAE.D_cilo = ci(2,1);
    results.DAE.D_cihi = ci(2,2);
    results.DAE.A = coeffs_DAE(3);
    results.DAE.A_se = se(3);
    results.DAE.A_cilo = ci(3,1);
    results.DAE.A_cihi = ci(3,2);
end

if ~isempty(find(ismember(msd_params.models,'DR'),1))
    % Fit MSD for diffusion in a reflective sphere without flow: MSD = R^2*(1-exp(-6*D*t/R^2))
    nparam_DR = 2;
    f_DR = @(b,x) b(2)^2*(1 - exp(-6*b(1)*x/b(2)^2));
    [coeffs_DR resnorm_DR residuals_DR e o l J L] = lsqcurvefit_GLS(f_DR,[0.01 1],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.D msd_params.lower_b.R],[msd_params.upper_b.D msd_params.upper_b.R],optimset('Display','off'));
    J = full(J);
    COVB_DR = resnorm_DR/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DR,residuals_DR,'covar',COVB_DR);
    results.DR.D = coeffs_DR(1);
    results.DR.D_se = se(1);
    results.DR.D_cilo = ci(1,1);
    results.DR.D_cihi = ci(1,2);
    results.DR.R = coeffs_DR(2);
    results.DR.R_se = se(2);
    results.DR.R_cilo = ci(2,1);
    results.DR.R_cihi = ci(2,2);
end

if ~isempty(find(ismember(msd_params.models,'DRE'),1))
    % Fit MSD for diffusion in a reflective sphere without flow plus error: MSD = 6*sigmaE^2 + R^2*(1-exp(-6*D*t/R^2))
    nparam_DRE = 3;
    f_DRE = @(b,x) 6*b(1)^2 + b(3)^2*(1 - exp(-6*b(2)*x/b(3)^2));
    [coeffs_DRE resnorm_DRE residuals_DRE e o l J L] = lsqcurvefit_GLS(f_DRE,[0.01 0.01 1],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D msd_params.lower_b.R],[msd_params.upper_b.E msd_params.upper_b.D msd_params.upper_b.R],optimset('Display','off'));
    J = full(J);
    COVB_DRE = resnorm_DRE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DRE,residuals_DRE,'covar',COVB_DRE);
    results.DRE.E = coeffs_DRE(1);
    results.DRE.E_se = se(1);
    results.DRE.E_cilo = ci(1,1);
    results.DRE.E_cihi = ci(1,2);
    results.DRE.D = coeffs_DRE(2);
    results.DRE.D_se = se(2);
    results.DRE.D_cilo = ci(2,1);
    results.DRE.D_cihi = ci(2,2);
    results.DRE.R = coeffs_DRE(3);
    results.DRE.R_se = se(3);
    results.DRE.R_cilo = ci(3,1);
    results.DRE.R_cihi = ci(3,2);
end

if ~isempty(find(ismember(msd_params.models,'V'),1))
    % Fit MSD with flow alone: MSD = (v*t)^2
    nparam_V = 1;
    f_V = @(b,x) b^2*x.^2;
    [coeffs_V resnorm_V residuals_V e o l J L] = lsqcurvefit_GLS(f_V,0.01,timelags,MSD_vs_timelag,msd_params.error_cov,msd_params.lower_b.V,msd_params.upper_b.V,optimset('Display','off'));
    J = full(J);
    COVB_V = resnorm_V/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_V,residuals_V,'covar',COVB_V);
    results.V.V = coeffs_V;
    results.V.V_se = se;
    results.V.V_cilo = ci(1);
    results.V.V_cihi = ci(2);
end

if ~isempty(find(ismember(msd_params.models,'VE'),1))
    % Fit MSD with flow alone plus error: MSD = 6*sigmaE^2 + (v*t)^2
    nparam_VE = 2;
    f_VE = @(b,x) 6*b(1)^2 + b(2)^2*x.^2;
    [coeffs_VE resnorm_VE residuals_VE e o l J L] = lsqcurvefit_GLS(f_VE,[0.01 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.V],[msd_params.upper_b.E msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_VE = resnorm_VE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_VE,residuals_VE,'covar',COVB_VE);
    results.VE.E = coeffs_VE(1);
    results.VE.E_se = se(1);
    results.VE.E_cilo = ci(1,1);
    results.VE.E_cihi = ci(1,2);
    results.VE.V = coeffs_VE(2);
    results.VE.V_se = se(2);
    results.VE.V_cilo = ci(2,1);
    results.VE.V_cihi = ci(2,2);
end

if ~isempty(find(ismember(msd_params.models,'DV'),1))
    % Fit MSD with diffusion plus flow: MSD = 6*D*t + (v*t)^2
    nparam_DV = 2;
    f_DV = @(b,x) 6*b(1)*x + b(2)^2*x.^2;
    [coeffs_DV resnorm_DV residuals_DV e o l J L] = lsqcurvefit_GLS(f_DV,[0.01 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.D msd_params.lower_b.V],[msd_params.upper_b.D msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DV = resnorm_DV/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DV,residuals_DV,'covar',COVB_DV);
    results.DV.D = coeffs_DV(1);
    results.DV.D_se = se(1);
    results.DV.D_cilo = ci(1,1);
    results.DV.D_cihi = ci(1,2);
    results.DV.V = coeffs_DV(2);
    results.DV.V_se = se(2);
    results.DV.V_cilo = ci(2,1);
    results.DV.V_cihi = ci(2,2);
end

if ~isempty(find(ismember(msd_params.models,'DVE'),1))
    % Fit MSD with diffusion plus flow plus error: MSD = 6*sigmaE^2 + 6*D*t + (v*t)^2
    nparam_DVE = 3;
    f_DVE = @(b,x) 6*b(1)^2 + 6*b(2)*x + b(3)^2*x.^2;
    [coeffs_DVE resnorm_DVE residuals_DVE e o l J L] = lsqcurvefit_GLS(f_DVE,[0.01 0.01 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D msd_params.lower_b.V],[msd_params.upper_b.E msd_params.upper_b.D msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DVE = resnorm_DVE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DVE,residuals_DVE,'covar',COVB_DVE);
    results.DVE.E = coeffs_DVE(1);
    results.DVE.E_se = se(1);
    results.DVE.E_cilo = ci(1,1);
    results.DVE.E_cihi = ci(1,2);
    results.DVE.D = coeffs_DVE(2);
    results.DVE.D_se = se(2);
    results.DVE.D_cilo = ci(2,1);
    results.DVE.D_cihi = ci(2,2);
    results.DVE.V = coeffs_DVE(3);
    results.DVE.V_se = se(3);
    results.DVE.V_cilo = ci(3,1);
    results.DVE.V_cihi = ci(3,2);
end

if ~isempty(find(ismember(msd_params.models,'DAV'),1))
    % Fit MSD with anomalous diffusion plus flow: MSD = 6*D*t^alpha + (v*t)^2
    nparam_DAV = 3;
    f_DAV = @(b,x) 6*b(1)*x.^b(2) + b(3)^2*x.^2;
    [coeffs_DAV resnorm_DAV residuals_DAV e o l J L] = lsqcurvefit_GLS(f_DAV,[0.01 1 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.D msd_params.lower_b.A msd_params.lower_b.V],[msd_params.upper_b.D msd_params.upper_b.A msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DAV = resnorm_DAV/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DAV,residuals_DAV,'covar',COVB_DAV);
    results.DAV.D = coeffs_DAV(1);
    results.DAV.D_se = se(1);
    results.DAV.D_cilo = ci(1,1);
    results.DAV.D_cihi = ci(1,2);
    results.DAV.A = coeffs_DAV(2);
    results.DAV.A_se = se(2);
    results.DAV.A_cilo = ci(2,1);
    results.DAV.A_cihi = ci(2,2);
    results.DAV.V = coeffs_DAV(3);
    results.DAV.V_se = se(3);
    results.DAV.V_cilo = ci(3,1);
    results.DAV.V_cihi = ci(3,2);
end

if ~isempty(find(ismember(msd_params.models,'DAVE'),1))
    % Fit MSD with anomalous diffusion plus flow plus error: MSD = 6*sigmaE^2 + 6*D*t^alpha + (v*t)^2
    nparam_DAVE = 4;
    f_DAVE = @(b,x) 6*b(1)^2 + 6*b(2)*x.^b(3) + b(4)^2*x.^2;
    [coeffs_DAVE resnorm_DAVE residuals_DAVE e o l J L] = lsqcurvefit_GLS(f_DAVE,[0.01 0.01 1 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D msd_params.lower_b.A msd_params.lower_b.V],[msd_params.upper_b.E msd_params.upper_b.D msd_params.upper_b.A msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DAVE = resnorm_DAVE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DAVE,residuals_DAVE,'covar',COVB_DAVE);
    results.DAVE.E = coeffs_DAVE(1);
    results.DAVE.E_se = se(1);
    results.DAVE.E_cilo = ci(1,1);
    results.DAVE.E_cihi = ci(1,2);
    results.DAVE.D = coeffs_DAVE(2);
    results.DAVE.D_se = se(2);
    results.DAVE.D_cilo = ci(2,1);
    results.DAVE.D_cihi = ci(2,2);
    results.DAVE.A = coeffs_DAVE(3);
    results.DAVE.A_se = se(3);
    results.DAVE.A_cilo = ci(3,1);
    results.DAVE.A_cihi = ci(3,2);
    results.DAVE.V = coeffs_DAVE(4);
    results.DAVE.V_se = se(4);
    results.DAVE.V_cilo = ci(4,1);
    results.DAVE.V_cihi = ci(4,2);
end

if ~isempty(find(ismember(msd_params.models,'DRV'),1))
    % Fit MSD for diffusion in a reflective sphere plus flow: MSD = R^2*(1-exp(-6*D*t/R^2)) + (v*t)^2
    nparam_DRV = 3;
    f_DRV = @(b,x) b(2)^2*(1 - exp(-6*b(1)*x/b(2)^2)) + b(3)^2*x.^2;
    [coeffs_DRV resnorm_DRV residuals_DRV e o l J L] = lsqcurvefit_GLS(f_DRV,[0.01 1 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.D msd_params.lower_b.R msd_params.lower_b.V],[msd_params.upper_b.D msd_params.upper_b.R msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DRV = resnorm_DRV/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DRV,residuals_DRV,'covar',COVB_DRV);
    results.DRV.D = coeffs_DRV(1);
    results.DRV.D_se = se(1);
    results.DRV.D_cilo = ci(1,1);
    results.DRV.D_cihi = ci(1,2);
    results.DRV.R = coeffs_DRV(2);
    results.DRV.R_se = se(2);
    results.DRV.R_cilo = ci(2,1);
    results.DRV.R_cihi = ci(2,2);
    results.DRV.V = coeffs_DRV(3);
    results.DRV.V_se = se(3);
    results.DRV.V_cilo = ci(3,1);
    results.DRV.V_cihi = ci(3,2);
end

if ~isempty(find(ismember(msd_params.models,'DRVE'),1))
    % Fit MSD for diffusion in a reflective sphere plus flow plus error: MSD = 6*sigmaE^2 + R^2*(1-exp(-6*D*t/R^2)) + (v*t)^2
    nparam_DRVE = 4;
    f_DRVE = @(b,x) 6*b(1)^2 + b(3)^2*(1 - exp(-6*b(2)*x/b(3)^2)) + b(4)^2*x.^2;
    [coeffs_DRVE resnorm_DRVE residuals_DRVE e o l J L] = lsqcurvefit_GLS(f_DRVE,[0.01 0.01 1 0.01],timelags,MSD_vs_timelag,msd_params.error_cov,[msd_params.lower_b.E msd_params.lower_b.D msd_params.lower_b.R msd_params.lower_b.V],[msd_params.upper_b.E msd_params.upper_b.D msd_params.upper_b.R msd_params.upper_b.V],optimset('Display','off'));
    J = full(J);
    COVB_DRVE = resnorm_DRVE/(length(MSD_vs_timelag)-1)*(J'*J)^(-1);
    [ci se] = nlparci_se(coeffs_DRVE,residuals_DRVE,'covar',COVB_DRVE);
    results.DRVE.E = coeffs_DRVE(1);
    results.DRVE.E_se = se(1);
    results.DRVE.E_cilo = ci(1,1);
    results.DRVE.E_cihi = ci(1,2);
    results.DRVE.D = coeffs_DRVE(2);
    results.DRVE.D_se = se(2);
    results.DRVE.D_cilo = ci(2,1);
    results.DRVE.D_cihi = ci(2,2);
    results.DRVE.R = coeffs_DRVE(3);
    results.DRVE.R_se = se(3);
    results.DRVE.R_cilo = ci(3,1);
    results.DRVE.R_cihi = ci(3,2);
    results.DRVE.V = coeffs_DRVE(4);
    results.DRVE.V_se = se(4);
    results.DRVE.V_cilo = ci(4,1);
    results.DRVE.V_cihi = ci(4,2);
end


%%%%%% Likelihoods and model probabilities %%%%%%

MLsum = 0; %normalization factor for model probabilities

% Calculate the log probability for each model
if ~isempty(find(ismember(msd_params.models,'N'),1))
    results.N.logML = -0.5*sum(residuals_N'*(L^-1)'*(L^-1)*residuals_N) + 0.5*nparam_N*log(2*pi) + 0.5*log(abs(det(COVB_N))); 
    results.N.logML = results.N.logML - log(2*results.N.C_se*msd_params.prior_scale);
    if isnan(results.N.logML)
        results.N.logML = -Inf;
    end
    MLsum = MLsum + exp(results.N.logML);
end
if ~isempty(find(ismember(msd_params.models,'D'),1))
    results.D.logML = -0.5*sum(residuals_D'*(L^-1)'*(L^-1)*residuals_D) + 0.5*nparam_D*log(2*pi) + 0.5*log(abs(det(COVB_D))); 
    results.D.logML = results.D.logML - log(2*results.D.D_se*msd_params.prior_scale);
    if isnan(results.D.logML)
        results.D.logML = -Inf;
    end
    MLsum = MLsum + exp(results.D.logML);
end
if ~isempty(find(ismember(msd_params.models,'DE'),1))
    results.DE.logML = -0.5*sum(residuals_DE'*(L^-1)'*(L^-1)*residuals_DE) + 0.5*nparam_DE*log(2*pi) + 0.5*log(abs(det(COVB_DE))); 
    results.DE.logML = results.DE.logML - log(2*results.DE.E_se*msd_params.prior_scale * 2*results.DE.D_se*msd_params.prior_scale);
    if isnan(results.DE.logML)
        results.DE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DE.logML);
end
if ~isempty(find(ismember(msd_params.models,'DA'),1))
    results.DA.logML = -0.5*sum(residuals_DA'*(L^-1)'*(L^-1)*residuals_DA) + 0.5*nparam_DA*log(2*pi) + 0.5*log(abs(det(COVB_DA)));
    results.DA.logML = results.DA.logML - log(2*results.DA.D_se*msd_params.prior_scale * 2*results.DA.A_se*msd_params.prior_scale);
    if isnan(results.DA.logML)
        results.DA.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DA.logML);
end
if ~isempty(find(ismember(msd_params.models,'DAE'),1))
    results.DAE.logML = -0.5*sum(residuals_DAE'*(L^-1)'*(L^-1)*residuals_DAE) + 0.5*nparam_DAE*log(2*pi) + 0.5*log(abs(det(COVB_DAE)));
    results.DAE.logML = results.DAE.logML - log(2*results.DAE.E_se*msd_params.prior_scale * 2*results.DAE.D_se*msd_params.prior_scale * 2*results.DAE.A_se*msd_params.prior_scale);
    if isnan(results.DAE.logML)
        results.DAE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DAE.logML);
end
if ~isempty(find(ismember(msd_params.models,'DR'),1))
    results.DR.logML = -0.5*sum(residuals_DR'*(L^-1)'*(L^-1)*residuals_DR) + 0.5*nparam_DR*log(2*pi) + 0.5*log(abs(det(COVB_DR)));
    results.DR.logML = results.DR.logML - log(2*results.DR.D_se*msd_params.prior_scale * 2*results.DR.R_se*msd_params.prior_scale);
    if isnan(results.DR.logML)
        results.DR.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DR.logML);
end
if ~isempty(find(ismember(msd_params.models,'DRE'),1))
    results.DRE.logML = -0.5*sum(residuals_DRE'*(L^-1)'*(L^-1)*residuals_DRE) + 0.5*nparam_DRE*log(2*pi) + 0.5*log(abs(det(COVB_DRE)));
    results.DRE.logML = results.DRE.logML - log(2*results.DRE.E_se*msd_params.prior_scale * 2*results.DRE.D_se*msd_params.prior_scale * 2*results.DRE.R_se*msd_params.prior_scale);
    if isnan(results.DRE.logML)
        results.DRE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DRE.logML);
end
if ~isempty(find(ismember(msd_params.models,'V'),1))
    results.V.logML = -0.5*sum(residuals_V'*(L^-1)'*(L^-1)*residuals_V) + 0.5*nparam_V*log(2*pi) + 0.5*log(abs(det(COVB_V)));
    results.V.logML = results.V.logML - log(2*results.V.V_se*msd_params.prior_scale);
    if isnan(results.V.logML)
        results.V.logML = -Inf;
    end
    MLsum = MLsum + exp(results.V.logML);
end
if ~isempty(find(ismember(msd_params.models,'VE'),1))
    results.VE.logML = -0.5*sum(residuals_VE'*(L^-1)'*(L^-1)*residuals_VE) + 0.5*nparam_VE*log(2*pi) + 0.5*log(abs(det(COVB_VE)));
    results.VE.logML = results.VE.logML - log(2*results.VE.E_se*msd_params.prior_scale * 2*results.VE.V_se*msd_params.prior_scale);
    if isnan(results.VE.logML)
        results.VE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.VE.logML);
end
if ~isempty(find(ismember(msd_params.models,'DV'),1))
    results.DV.logML = -0.5*sum(residuals_DV'*(L^-1)'*(L^-1)*residuals_DV) + 0.5*nparam_DV*log(2*pi) + 0.5*log(abs(det(COVB_DV)));
    results.DV.logML = results.DV.logML - log(2*results.DV.D_se*msd_params.prior_scale * 2*results.DV.V_se*msd_params.prior_scale);
    if isnan(results.DV.logML)
        results.DV.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DV.logML);
end
if ~isempty(find(ismember(msd_params.models,'DVE'),1))
    results.DVE.logML = -0.5*sum(residuals_DVE'*(L^-1)'*(L^-1)*residuals_DVE) + 0.5*nparam_DVE*log(2*pi) + 0.5*log(abs(det(COVB_DVE)));
    results.DVE.logML = results.DVE.logML - log(2*results.DVE.E_se*msd_params.prior_scale * 2*results.DVE.D_se*msd_params.prior_scale * 2*results.DVE.V_se*msd_params.prior_scale);
    if isnan(results.DVE.logML)
        results.DVE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DVE.logML);
end
if ~isempty(find(ismember(msd_params.models,'DAV'),1))
    results.DAV.logML = -0.5*sum(residuals_DAV'*(L^-1)'*(L^-1)*residuals_DAV) + 0.5*nparam_DAV*log(2*pi) + 0.5*log(abs(det(COVB_DAV)));
    results.DAV.logML = results.DAV.logML - log(2*results.DAV.D_se*msd_params.prior_scale * 2*results.DAV.A_se*msd_params.prior_scale * 2*results.DAV.V_se*msd_params.prior_scale);
    if isnan(results.DAV.logML)
        results.DAV.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DAV.logML);
end
if ~isempty(find(ismember(msd_params.models,'DAVE'),1))
    results.DAVE.logML = -0.5*sum(residuals_DAVE'*(L^-1)'*(L^-1)*residuals_DAVE) + 0.5*nparam_DAVE*log(2*pi) + 0.5*log(abs(det(COVB_DAVE)));
    results.DAVE.logML = results.DAVE.logML - log(2*results.DAVE.E_se*msd_params.prior_scale * 2*results.DAVE.D_se*msd_params.prior_scale * 2*results.DAVE.A_se*msd_params.prior_scale * 2*results.DAVE.V_se*msd_params.prior_scale);
    if isnan(results.DAVE.logML)
        results.DAVE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DAVE.logML);
end
if ~isempty(find(ismember(msd_params.models,'DRV'),1))
    results.DRV.logML = -0.5*sum(residuals_DRV'*(L^-1)'*(L^-1)*residuals_DRV) + 0.5*nparam_DRV*log(2*pi) + 0.5*log(abs(det(COVB_DRV)));
    results.DRV.logML = results.DRV.logML - log(2*results.DRV.D_se*msd_params.prior_scale * 2*results.DRV.R_se*msd_params.prior_scale * 2*results.DRV.V_se*msd_params.prior_scale);
    if isnan(results.DRV.logML)
        results.DRV.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DRV.logML);
end
if ~isempty(find(ismember(msd_params.models,'DRVE'),1))
    results.DRVE.logML = -0.5*sum(residuals_DRVE'*(L^-1)'*(L^-1)*residuals_DRVE) + 0.5*nparam_DRVE*log(2*pi) + 0.5*log(abs(det(COVB_DRVE)));
    results.DRVE.logML = results.DRVE.logML - log(2*results.DRVE.E_se*msd_params.prior_scale * 2*results.DRVE.D_se*msd_params.prior_scale * 2*results.DRVE.R_se*msd_params.prior_scale * 2*results.DRVE.V_se*msd_params.prior_scale);
    if isnan(results.DRVE.logML)
        results.DRVE.logML = -Inf;
    end
    MLsum = MLsum + exp(results.DRVE.logML);
end

% Calculate the normalized probablity of each model 
if ~isempty(find(ismember(msd_params.models,'N'),1)), results.N.PrM = exp(results.N.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'D'),1)), results.D.PrM = exp(results.D.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DE'),1)), results.DE.PrM = exp(results.DE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DA'),1)), results.DA.PrM = exp(results.DA.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DAE'),1)), results.DAE.PrM = exp(results.DAE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DR'),1)), results.DR.PrM = exp(results.DR.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DRE'),1)), results.DRE.PrM = exp(results.DRE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'V'),1)), results.V.PrM = exp(results.V.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'VE'),1)), results.VE.PrM = exp(results.VE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DV'),1)), results.DV.PrM = exp(results.DV.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DVE'),1)), results.DVE.PrM = exp(results.DVE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DAV'),1)), results.DAV.PrM = exp(results.DAV.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DAVE'),1)), results.DAVE.PrM = exp(results.DAVE.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DRV'),1)), results.DRV.PrM = exp(results.DRV.logML)/MLsum; end
if ~isempty(find(ismember(msd_params.models,'DRVE'),1)), results.DRVE.PrM = exp(results.DRVE.logML)/MLsum; end


end

