function Sstar = cov_shrinkage(M, target)

%%%%%%%%
%
% M is a 2D matrix with observations as rows and variables as columns.
%
% This function computes a regularized covariance matrix between the
% variables (columns) of M using the shrinkage method described in: 
%   Schaefer and Strimmer. 2005. Large-Scale Covariance Matrix Estimation.
%
% The shrinkage target (the matrix that is linearly combined with the
% empirical covariance matrix) must be specified by setting the input
% variable target:
%  1 = diagonal matrix with equal diagonal elements
%  2 = diagonal matrix with unequal (empirical) diagonal elements
%
%%%%%%%%
% Copyright MIT 2012
% Developed by Nilah Monnier & Syuan-Ming Guo
% Laboratory for Computational Biology & Biophysics
%%%%%%%%


% Unbiased empirical covariance matrix
S = cov(M);

% Target matrix
if target==1
    T = eye(size(S)) * mean(diag(S));  % T is diagonal with T[i,i] = mean(S[i,i])
elseif target==2
    T = diag(diag(S));  % T is diagonal with T[i,i] = S[i,i]
end

n = size(M,1);  % number of observations

% Variance in covariance matrix elements (for calculating weighting factor
% below)
varS = zeros(size(S));
for i = 1:size(S,1)
    for j = 1:size(S,1)
        w = M(:,i) .* M(:,j);
        varS(i,j) = n/(n-1)^3 * sum((w - mean(w)).^2);
    end
end

% Weighting factor
if target==1
    lambda = sum(sum(varS)) / sum(sum((S-T).^2));
elseif target==2
    lambda = sum(sum(varS-diag(diag(varS)))) / sum(sum((S-diag(diag(S))).^2));
end

% Inferred covariance matrix
Sstar = lambda * T + (1-lambda) * S;


end

