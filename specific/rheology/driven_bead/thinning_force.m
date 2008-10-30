function F = thinning_force(gammadot, a, lambda, eta0, etainf, m, n)
% 3DFM function  
% Rheology/DMBR
% last modified 09-Sep-2008 (jcribb)
%  
% This function estimates the required forces 'F' needed to obtain maximum
% shear rates 'gammadot' around an actuated sphere with radius 'a'.  The
% material around the sphere is assumed to be a shear-thinning material
% with a zero-shear viscosity 'eta0' and an infinite-shear viscosity
% 'etainf'.  The infinite-shear value is assumed to be zero if none is
% defined.
%
% 'm' and 'n' define powerlaw parameters for either a Cross model or a
% Carreau model.  If only 'm' is defined, then a Cross model is assumed.
% If both 'm' and 'n' are defined, then a full Carreau model is used.
%  
%  [F] = thinning_force(gammadot, a, lambda, eta0, etainf, m, n)
%   
%  where "gammadot" is strain-rate in units of [1/s] 
%        "a" is bead radii in units of [m] 
%        "lambda" is the time constant for thinning model
%        "eta0" is estimate of zero-shear viscosity
%        "etainf" is estimate of viscosity at infinite shear
%        "m" is the powerlaw exponent for cross model or width-scaling exponent
%        for carreau model
%        "n" is the powerlaw parameter for carreau model such that (n-1) is
%        equal to the powerlaw slope.
%

if nargin < 7 || isempty(n)
    logentry('No Carreau exponent found for thinning band.  Using Cross model.');
    model = 'cross';
end

if nargin < 6 || isempty(m)
    logentry('No thinning exponent found.  No model found for estimates.');
    error('No adequate model found for given parameters.');
end

if nargin < 5 || isempty(etainf)
    logentry('No estimates given for infinite viscosity.  Assuming zero.');
    etainf = 0;
end

if nargin < 4 || isempty(eta0)
    logentry('No estimate given for zero-shear viscosity.  Not enough info.');
    error('No adequate model found for given parameters.');
end

if nargin < 3 || isempty(lambda)
    logentry('No time constant given.  Not enough information.');
    error('No adequate model found for given parameters.');
end

if nargin < 2 || isempty(a)
    logentry('No bead size(s) given.  Assuming 1 micron diameter.');
    a = 0.5e-6;
end

if nargin < 1 || isempty(gammadot)
    logentry('No shear rates given.  Assuming 0.01, 0.1, 1, 10 1/s.');
    gammadot = [0.01, 0.1, 1, 10];
end

if ~exist('model') || isempty(model)
    model = 'carreau';
    logentry('Using Carreau model.');
end

% 'A' is the geometric constant prefactor.  It is a column vector if more
% than one bead size is used.
A = 4*pi .* (a.^2);
A = A(:)'; % makes A a column vector
A = repmat(A, length(gammadot), 1);


switch model
    case 'cross'
        eta = (eta0-etainf) ./ (1+(lambda.*gammadot).^m) + etainf;
    case 'carreau'
        eta = (eta0-etainf) .* ((1+(lambda.*gammadot).^m).^((n-1)/m)) + etainf;
    otherwise
        % nothing should be here; this should never happen.
end

B = gammadot .* eta;
B = B(:);
B = repmat(B, 1, length(a));

F = A .* B;


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'thinning_force: '];
     
     fprintf('%s%s\n', headertext, txt);

