function F = Bforce(f, Q)
% F = Bforce(f, Q) -- Returns a list F of force vectors from a
% list Q of excitations for an n-pole geometry matrix f, which
% is structured as an (n x 3 x n) array where the middle index
% refers to the spatial axes, [x,y,z].
size(f);
n = ans(1); % the number of poles specified in f
size(Q);
if ans(2) ~= n
    error('number of poles: incompatibility between f and Q.');
end
m = ans(1); % the number of listed excitations
for i = 1:m % process the excitation list
    q = Q(i,:);
    for h = 1:3, F(i,h) = q*squeeze(f(:,h,:))*q'; 
    end    
end
return
% Example
% Bforce(fmatrix(tetra(1)), [[-1,1/3,1/3,1/3] % towards one pole
% [-1, 1, 0, 0] % halfway between two poles
% [-1,1/2,1/2, 0]]) % three poles excited