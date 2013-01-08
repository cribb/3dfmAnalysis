function [a,b,G0,Rsq,t] = power_law_fitting(Time,Creep)

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

% Linear fit of log data: log(J)=b*log(t/t0)+log(a)
       %   p(1)=b
       %   p(2)=log(a)

p = polyfit(lt,lJ,1);
r = corrcoef(lt,lJ);
Rsq = r(2)^2;
b = p(1);
a = exp(p(2));
G0 = (2*pi).^b./(a.*gamma(1+b));
