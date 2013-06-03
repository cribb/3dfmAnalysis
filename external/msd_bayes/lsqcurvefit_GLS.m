function [coeffs resnorm residuals e o l J L] = lsqcurvefit_GLS(f, b0, x, y, error_cov, varargin)
%%%%%%%%
% Performs generalized least squares using the built-in MATLAB function
% lsqcurvefit. Requires an error covariance matrix error_cov for the data
% y. All other inputs are the same as for lsqcurvefit.
%%%%%%%%
% Copyright MIT 2012
% Developed by Nilah Monnier & Syuan-Ming Guo
% Laboratory for Computational Biology & Biophysics
%%%%%%%%

if size(y,1)<size(y,2)
    y = y';
end

if size(x,1)<size(x,2)
    x = x';
end

[L p] = chol(error_cov, 'lower');
if p~=0
    L = chol(corr_repair(error_cov,100,'cov'), 'lower');
    disp('Warning: regularization failed')
end

f_transformed = @(b,x) L\f(b,x);

if nargin>7
    [coeffs resnorm residuals e o l J] = lsqcurvefit(f_transformed, b0, x, L\y, varargin{1}, varargin{2}, varargin{3});
elseif nargin>5
    [coeffs resnorm residuals e o l J] = lsqcurvefit(f_transformed, b0, x, L\y, varargin{1}, varargin{2});
else
    [coeffs resnorm residuals e o l J] = lsqcurvefit(f_transformed, b0, x, L\y);
end

residuals = y - f(coeffs, x);
resnorm = sum(residuals.^2);

end