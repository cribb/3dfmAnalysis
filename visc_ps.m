function v = visc_ps(f, ps, a, cutoff)

% constants
k = 1.38e-23;
T = 298;

% determine if first frequency is zero
% if so, omit it
if f(1) == 0
    f = f(2:end);
    ps=ps(2:end);
end

% cutoff section of data I don't want (i.e. not linear)
data = find(f<=cutoff);
f = f(data);
ps = ps(data);

% Take log transform
f = log10(f);
ps= log10(ps);

p = polyfit(f, ps, 1);
fit = polyval(p, f);

B = p(end);
n = (k * T) / (6*pi^3*10^B*a);

figure; 
plot(f, [ps fit], f, -14.1027 - 2*f);
axis([0 1 -17 -13]);

v.visc = n;
v.slope = p(1);
v.icept = p(2);