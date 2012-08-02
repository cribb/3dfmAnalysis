function [J0,beta,R_square] = power_law_fitting_fabry(Time,Creep)

% Input Variables
%     Time: Time data
%     Creep: Creep data

J = Creep;
t = Time;

% Removing zeros so log doesn't blow up
t = t(J~=0);
J = J(J~=0);

% Scale t with t0
t0 = 1;             %s
t = t/t0;

% Take the log of J and t for regression fit
lJ = log(J);
lt = log(t);

% Linear fit of log data: log(J)=beta*log(t/t0)+log(J0)
       %   p(1)=beta
       %   p(2)=log(J0)

p = polyfit(lt,lJ,1);
r = corrcoef(lt,lJ);
R_square = r(2)^2;
beta = (p(1));
J0 = exp(p(2));

