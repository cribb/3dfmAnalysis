% corr_repair modifies sigular covariance matrix to make it non-sigular.
% input:
% cova - covariance matrix
% n_ite - number of iteration
% option: 'corr' - modify the correlation matrix
%         'cov' - modify the covariance matrix
% output- non-singular covariance matrix
% 
% When the resulting covariance is still close to singular, increase EPS and threshold. 
% Larger EPS and threshold will change the covariance more.
% Try corr_repair2 if this function does not work for your matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright MIT 2012
% Developed by Nilah Monnier & Syuan-Ming Guo
% Laboratory for Computational Biology & Biophysics
%%%%%%%%


function covrpr = corr_repair(cova, n_ite, option)
% C = cov_Scldev ;

EPS = 1e-2  ; 
thres = 1e-2 ;
% lamda = 0.5;    % shrinkage coefficient
% thres = 1e-200 ;
switch option
    case 'corr'
sigma_sq = sqrt(diag(cova)*diag(cova)') ;
C = cova ./ sigma_sq ;  % get the correlation matrix
Cr = C ;
% Cf = C;
% Cf(abs(Cf)<1e-1) = 0;
% Cr = Cf;
% Cr(abs(Cr)<2e-1) = 0;
e   = eig(Cr);
ite = 0;
% compute eigenvectors/-values
% disp('making the rank-deficient covariance matrix positive definite...')

% drawnow
while (min(e)< thres || ~isreal(e)) && ite <= n_ite
% while prod(e)< thres || ~isreal(e)
[V,D]   = eig(Cr);
% replace negative eigenvalues by zero
e       = max(diag(D), EPS);
e = abs(e);
D = diag(e);
% reconstruct correlation matrix
Cr      = V * D * V';
e = eig(Cr);
ite=ite+1 ;
% if mod(ite, 10)==0
%     drawnow
%     disp(['n(iterations)= ', num2str(ite) ', det = ' num2str(prod(e))])
% else
% end
end

% Cr = lamda * C+(1-lamda) * Cr;

%% rescale correlation matrix
T       = 1 ./ sqrt(diag(Cr));
TT      = T * T';
Cr      = Cr .* TT ;

dev = norm(Cr-C, 'fro')/norm(C, 'fro');

% disp('matrix repair is done,')
% disp(['n(iterations)= ', num2str(ite) ', det = ' num2str(det(Cr)) ...
%     ', dev = ' num2str(100*dev) '%'])

covrpr = Cr .* sigma_sq ;
    case 'cov'

cova_r = cova ;

e   = eig(cova_r);
ite = 0 ;
% compute eigenvectors/-values
% disp('making the rank-deficient covariance matrix positive definite...')

% drawnow
while (min(e)< thres || ~isreal(e)) && ite <= n_ite

[V,D]   = eig(cova_r);
% replace negative eigenvalues by zero
e       = max(diag(D), EPS);
e = abs(e);
D = diag(e);
% reconstruct correlation matrix
cova_r      = V * D * V';
e = eig(cova_r);
ite=ite+1 ;
% if mod(ite, 10)==0
%     drawnow
%     disp(['n(iterations)= ', num2str(ite) ', det = ' num2str(prod(e))...
%         ', minimum eig = ' num2str(min(e))])
% else
% end
end



%% rescale correlation matrix
dev = norm(cova_r-cova, 'fro')/norm(cova, 'fro');

% disp('matrix repair is done,')
% disp(['n(iterations)= ', num2str(ite) ', det = ' num2str(det(cova_r)) ...
%     ', dev = ' num2str(100*dev) '%'])

covrpr = cova_r ;
[~, C] = cov2corr(cova) ;
[~, Cr] = cov2corr(cova_r) ;
 otherwise
        error('Wrong option')
end

% figure(931)
% imshow(C, 'InitialMagnification', 'fit')
%     axis on
%     colormap(jet)
%     h = colorbar ;
%     set(gca, 'fontsize',15)
%     caxis([-1 1])
% 
% figure(932)
% imshow(Cr, 'InitialMagnification', 'fit')
%     axis on
%     colormap(jet)
%     h = colorbar ;
%     set(gca, 'fontsize',15)
%     caxis([-1 1])
