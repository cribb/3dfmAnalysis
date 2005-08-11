function S = LorentzianFit(fx, px, fy, py, fz, pz)
% set parameters for the options structure sent to lsqcurvefit.
options = optimset('MaxFunEvals', 20000, ...
                   'Diagnostics', 'off', ...
                   'TolFun', 1e-120, ...
                   'TolX', 1e-60, ...
                   'MaxIter', 200000, ...
                   'ShowStatusWindow', 'on');

T = 298;
K = 1.3807e-23;
eta = .026;         % viscosity in Pa s
a = .5e-6;          % bead radius in m
gamma = 6*pi*eta*a;

% fc = k/(2*pi*gamma)
fc = 30;  % inital guess for frequency cutoff

x0 = [fc]; % building the input vector

% make inputs column vectors
% fx = fx(10:end)';
% px = px(10:end)';
% 
% fy = fy(10:end)';
% py = py(10:end)';
% 
% fz = fz(10:end)';
% pz = pz(10:end)';

log_index = [30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000 2000];

logsamp_fx = fx(log_index);
logsamp_px = px(log_index);

logsamp_fy = fy(log_index);
logsamp_py = py(log_index);

logsamp_fz = fz(log_index);
logsamp_pz = pz(log_index);


% figure; 
% plot(log(fx), log(px));
% perform fit
% [fit_x,resnorm_x,residuals_x] = lsqcurvefit('LorentzianFit_fun',x0,fx,log(px),0,[],options);
% [fit_y,resnorm_y,residuals_y] = lsqcurvefit('LorentzianFit_fun',x0,fy,log(py),0,[],options);
% [fit_z,resnorm_z,residuals_z] = lsqcurvefit('LorentzianFit_fun',x0,fz,log(pz),0,[],options);


[fit_x,resnorm_x,residuals_x] = lsqcurvefit('LorentzianFit_fun',x0,logsamp_fx,logsamp_px,0,[],options);
[fit_y,resnorm_y,residuals_y] = lsqcurvefit('LorentzianFit_fun',x0,logsamp_fy,logsamp_py,0,[],options);
[fit_z,resnorm_z,residuals_z] = lsqcurvefit('LorentzianFit_fun',x0,logsamp_fz,logsamp_pz,0,[],options);

% get outputted fitting values
fc_x = fit_x(1)
fc_y = fit_y(1)
fc_z = fit_z(1)

gamma = 6*pi*eta*a;

% use fitted values to estimate equation previously used in fit
fit_px = (K*T) ./ (gamma*(pi^2)*(fc_x^2 + logsamp_fx.^2));
fit_py = (K*T) ./ (gamma*(pi^2)*(fc_y^2 + logsamp_fy.^2));
fit_pz = (K*T) ./ (gamma*(pi^2)*(fc_z^2 + logsamp_fz.^2));


%%%%%%%%%%%%%%%%%%%%%%%%  figure error value  %%%%%%%%%%%%%%%%%%%%%%%%%%%
rms_residuals_x = rms(residuals_x);
rms_residuals_y = rms(residuals_y);
rms_residuals_z = rms(residuals_z);

sse_x = resnorm_x;      % measure of the total deviation of the response values from the fit to the response values
sse_y = resnorm_y;
sse_z = resnorm_z;

sst_x = sum((px - mean(px)).^2);
sst_y = sum((py - mean(py)).^2);
sst_z = sum((pz - mean(pz)).^2);

R_square_x = 1 - sse_x/sst_x    
R_square_y = 1 - sse_y/sst_y
R_square_z = 1 - sse_z/sst_z


% R square means the fit explains ___% of the total variation in the data about the average.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use fc to determine the spring constant of the trap
%S.kx = fc/(2*pi*gamma);

S.kx = ((2*K*T)/(pi*fit_px(1)*fc_x)) *1e6;  %'pN/um'
S.ky = ((2*K*T)/(pi*fit_py(1)*fc_y)) *1e6;
S.kz = ((2*K*T)/(pi*fit_pz(1)*fc_z)) *1e6

figure;
loglog(fx,px, '.', logsamp_fx, logsamp_px, '*k', logsamp_fx,fit_px, 'r');
title('X PSD')
xlabel('Freq (Hz)')
ylabel('nm/rt(Hz)')
% subplot(2,1,2);
% loglog(fx,px,fx,abs(px - fit_px));

figure;
loglog(fy,py, '.', logsamp_fy, logsamp_py, '*k', logsamp_fy,fit_py, 'r');
title('Y PSD')
xlabel('Freq (Hz)')
ylabel('nm/rt(Hz)')
% subplot(2,1,2);
% loglog(fy,py,fy,abs(py - fit_py));

figure;
loglog(fz,pz, '.', logsamp_fz, logsamp_pz, '*k',logsamp_fz,fit_pz, 'r');
title('Z PSD')
xlabel('Freq (Hz)')
ylabel('nm/rt(Hz)')
% subplot(2,1,2);
% loglog(fz,pz,fz,abs(pz - fit_pz));

