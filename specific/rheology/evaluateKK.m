function ap = evaluateKK(omega_table, app_table, algorithm)
% 3DFM function  
% Rheology 
% last modified 10/20/2003 
%  
% This function computes the storage modulus of a viscoelastic
% fluid, by means of the Kramers-Kronig relation.
%  
%  ap = evaluateKK(omega_table, app_table, algorithm);  
%   
%  where omega_table is [something] in units of [units] 
%        app_table   is [something] in units of [units] 
%		     algorithm   is 'f' or 's' or fast or slow algorithms respectively 
%  
%  Notes:  
%   
%  - Default algorithm is slow.
%   
%   
%  ??/??/?? - created
%  10/20/03 - added algorithm switch and help info.
%   
%  

if nargin < 3
    algorithm = 's';
end

if strcmp(algorithm,'f')
    
	% fast algorithm
    
    ap    = (2/pi) * dct(dst(app_table));
	eta = 1e-5;
    
else
    
    % slow algorithm
    
	ap = zeros(size(omega_table));
	
	for i = 1:length(ap)
      omega = omega_table(i);
      val = 0;
      if omega > omega_table(1)
        val = quad('kkint', omega_table(1), omega-eta, [], [], omega, ...
		       omega_table, app_table);
      end
      if omega < omega_table(end)
        val = val + quad('kkint', omega+eta, omega_table(end), [], [], omega, ...
			     omega_table, app_table);
      end

      ap(i) = val;
    end

end

