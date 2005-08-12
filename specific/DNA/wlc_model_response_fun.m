function F = WLC_model_response_fun(x0, r)

	P = x0(1);
	L = x0(2);
	offset = x0(3);
    
	T = 293;
	k = 1.3807e-23;
	
    F = (k*T/P) * (.25*(1-(r+offset)/L).^-2 - .25 + (r+offset)/L);


    