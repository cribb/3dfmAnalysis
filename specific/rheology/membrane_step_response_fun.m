function x = membrane_step_response_fun(x0, t, ct)

% % set known constant values
% tau = 2;
% f = 1;

% set guesses for fitting parameters
k0      = x0(1);
k1      = x0(2);
gamma0  = x0(3);
gamma1  = x0(4);

tau = gamma1 * (k0 + k1) / (k0 * k1);

% go to town.  this is our fitting function
x = (1 / k0) * ( 1 - k1 / (k0 + k1) * exp(-t / tau)) + t/gamma0;

