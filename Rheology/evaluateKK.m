function ap = evaluateKK(omega_table, app_table)

eta = 1e-5;

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
   
%   alternative algorithm
%   ap    = (2/pi) * dct(dst(app_table));
end

