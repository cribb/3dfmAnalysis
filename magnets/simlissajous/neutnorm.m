function norm = neutnorm(a, c)
% 3DFM function Last modified 07/13/04
% 
% Performs neutralization and normalization (in that sequence) of the input magnet excitation vectors.
% USAGE: res = neutnorm(a,c)
% PARAMETER DESCRIPTION:
% "a": matrix with dimensions (Nsample,Ncoil) containing excitations for all coils
% "c": a constant used for normalization
% "res" : resulted excitations after doing neutralization and normalization

s = size(a);
Nsample = s(1,1);
Npole = s(1,2);
%Now neutralize the excitations: Make sum = 0;
for i = 1:Nsample;
    sumi = sum(a(i,:),2);
    neut(i,:) = a(i,:) - sumi/Npole;
end
%Now normalize the excitations: 

% % OLD METHOD: Make sum of squares to be a constant = c^2
% for i = 1:Nsample
%     sum = a(i,:)*a(i,:)';%sum of squares of the elements in this raw
%     factor = sqrt(c.^2/sum);
%     norm(i,:) = factor*neut(i,:);
% end

% NEW METHOD: Mame maximum absolute pole strength to be a constant = c
for i = 1:Nsample
    mp = max(abs(neut(i,:)));
    factor = c/mp;
    norm(i,:) = factor*neut(i,:);
end
