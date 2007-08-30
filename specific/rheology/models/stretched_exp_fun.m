function x = stretched_exp_fun(init_cond, t, xt)

    % set guesses for fitting parameters
    x_zero = init_cond(1);
    tau    = init_cond(2);
    h      = init_cond(3);

    % go to town.  this is our fitting function
    x = x_zero .* exp( - (t./tau) .^ (1./h) );

