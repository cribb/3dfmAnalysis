function [v,rho] = sucrose_viscosity(sucrose_molar_conc, temperature, temp_units)
% SUCROSE_VISCOSITY Returns viscosity of sucrose solution with input of molar concentration (mol/L) and temperature (°C or K)
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford) 
%  
% This function returns the viscosity of a sucrose solution when given 
% an input molar concentration of sucrose in mol/L and the solution's 
% temperature in degrees Celsius (or Kelvin).  This model for sucrose viscosity can 
% be found in the book: "Rheological properties of sucrose solutions and 
% suspensions"; M.Mathlouthi and J.Génotelle pp. 126-154 in SUCROSE 
% Properties and Applications, M. Mathlouthi and P. Reiser eds., Blackie 
% Academic & Professional 1995.
%  
% viscosity_Pasec = sucrose_viscosity(sucrose_molar_conc, temperature);
%   
%  where "sucrose_molar_conc" is in mol/L
%        "temperature" is in units of 'temp_units'
%        "temp_units" is a 'K' for Kelvin, or a 'C' for Celsius 
%  Notes:  
%   
%  - This model gives ~1% error on the experimental values.  
%    


    if (temp_units == 'K')
        temperature = temperature - 273.15;
    end
    
    % Check the temperature input value for sanity.
    if temperature < 0 | temperature > 100
        error('This model is valid for temperature values between 0 and 100 degrees Celsius.');
    end

    % This section contains the model for determining the viscosity of a
    % sucrose solution from the sucrose concentration in percent
    % (determined recursively from the solution density function below) and
    % the temperature of the solution in degrees Celsius.
    [sucrose_conc_percent, rho] = solution_density(sucrose_molar_conc, temperature);
    
    % Check the solution concentration input for sanity.  If the input
    % concentration is greater than the solubility of sucrose at the
    % reqested temperature, then the function exits with an 'exceeded
    % solubility' error.  This check is placed here because it depends on
    % the concentration of sucrose in percent.  Putting it here reduces the
    % number of computations as the convergence routine in
    % 'solution_density' needs only be ran once.
    sol = sucrose_solubility(sucrose_conc_percent, temperature);
    
    A = sucrose_conc_percent / (1900 - 18 * sucrose_conc_percent);
	B = (30 - temperature) / (91 + temperature);
	C = A^1.25;
	D = -0.114 + (1.1*B);
	
	v = 10^( (22.46*A) - 0.114 + ( B * ( 1.1 + 43.1 * C ))); % returns in mPa sec.

    v = v/1000; % converts to Pa sec (the SI unit)

    if sucrose_conc_percent > sol
        warning('The input sucrose concentration exceeds sucrose solubility at the input temperature. Setting NaN.');
        v = NaN;
    end;
    
% The solution_density function determines the sucrose concentration in
% percent and the solution density in kg/m^3.  The model used to do this
% was obtained from: Sugar Technologists Manual; Z. Bubnik, P. Kadlek, 
% D. Urban, M. Bruhns p. 164, Bartens 1995.  These equations are only valid 
% from 0 to 100°C.  This routine uses recursion to determine these
% values and runs until the error is below a tolerance value.  If more than
% 'count' recursions are done, the function exits with a "failure to
% converge" error.
function [sc, rho] = solution_density(sucrose_molar_conc, t)

    mw=18.016;   % the molecular weight of water
	ms=342.30;   % the molecular weight of sucrose

    d = 1000;    % a starting density value for pure water in kg/m^3
    sc = (100 * ms * sucrose_molar_conc) / d; % starting solution concentration in percent

    % This is a polynomial fit that describes the density of water for a
    % given temperature in degrees Celsius.
	siDensityWater = (999.83952               ...
                     + 16.952577    *  t      ...
                     - 7.9905127e-3 * (t^2)   ...
                     - 46.241757e-6 * (t^3)   ...
                     + 105.84601e-9 * (t^4)   ...
                     - 281.03006e-12 * (t^5)) ...
                     / (1 + 16.887236e-3 * t);

    % Parameter list for the sucrose density model.
	a1 = 385.1761;
	a2 = 135.3705;
	a3 = 40.9299;
	a4 = -3.9646;
	a5 = 13.4853;
	a6 = -17.2890;
	
	b1 = -46.2720;
	b2 = -7.1720;
	b3 = 1.1597;
	b4 = 5.1126;
	b5 = 17.5254;
	
	c1 = 59.7712;
	c2 = 7.2491;
	c3 = 12.3630;
	c4 = -35.4791;
	
	d1 = -47.2207;
	d2 = -21.6977;
	d3 = 27.6301;
	
	e1 = 18.3184;
	e2 = 12.3081;
	
	siTempVal = ((t - 20)/100);
	
    % Before the recursion routine, the error is set to an unacceptably
    % high value, the tolerance is set to decribe the desired degree of
    % convergence for the model, and the count is reset to 1 (for determining 
    % the success of convergence).
    err = 1;
    tol = 1e-8;
    count = 1;
    convergence_limit = 1000;
    
    % Recursive model routine.
    while (err > tol)
		scNew = sc*0.01;
		scNew2 = scNew^2;
		scNew3 = scNew^3;
		scNew4 = scNew^4;
		scNew5 = scNew^5;
		scNew6 = scNew^6;
		siTempVal2 = siTempVal^2;
		siTempVal3 = siTempVal^3;
		siTempVal4 = siTempVal^4;
		
		firstTerm =    a1 * scNew   ...
                     + a2 * scNew2  ...
                     + a3 * scNew3  ...
                     + a4 * scNew4  ...
                     + a5 * scNew5  ...
                     + a6 * scNew6;
                 
		secondTerm =  (b1 * scNew  ...
                     + b2 * scNew2 ...
                     + b3 * scNew3 ...
                     + b4 * scNew4 ...
                     + b5 * scNew5) * siTempVal;
                 
		thirdTerm =   (c1 * scNew  ... 
                     + c2 * scNew2 ...
                     + c3 * scNew3 ...
                     + c4 * scNew4) * siTempVal2;
                 
		fourthTerm =  (d1 * scNew  ...
                     + d2 * scNew2 ...
                     + d3 * scNew3) * siTempVal3;
                 
		fifthTerm =   (e1 * scNew ...
                     + e2 * scNew2) * siTempVal4;
				
		siDensitySolution = firstTerm + secondTerm + thirdTerm + fourthTerm + fifthTerm;
		
        % Before computing the new solution density, record the last value
        % for determining error from last fit.
        dlast = d;
        
        d = siDensityWater + siDensitySolution;     % new solution density
        sc = (100 * ms * sucrose_molar_conc) / d;   % new solution concentration in percent

        err = abs(d - dlast);
        
        if count > convergence_limit
            error('The solution density model has suffered from a failure to converge.');
        end
        
        count = count + 1;
        
	end
    
	rho = d;

% This function determines the maximum solubility of sucrose in percent given 
% an input sucrose concentration in percent and an input temperature in 
% degrees Celsius.  The model used here is a polynomial fit described in
% the following reference:  Sucrose solubility; Z.Bubnik and P.Kadlec pp. 101-125
% in SUCROSE Properties and Applications, M.Mathlouthi and P. Reiser eds., 
% Blackie Academic & Professional 1995.
function sol = sucrose_solubility(sc, t)

	sol =   64.447          ...
          + 0.08222   * t   ... 
          + 0.0016169 * t^2 ...
          - 1.558e-6  * t^3 ...
          - 4.63e-8   * t^4;

          
