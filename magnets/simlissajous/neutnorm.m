function norm = neutnorm(a,pairs, s)
% 3DFM function Last modified 07/16/04 - kvdesai
% 
% Performs neutralization and normalization (in that sequence) of the input magnet excitation vectors.
% USAGE: res = neutnorm(a,pairs,s)
% PARAMETER DESCRIPTION:
% "a": matrix with dimensions (Nsample,Ncoil), each raw containing  a set of excitations
% "pairs": [Ncoil/2, 2] matrix containing indices of pairs of two poles opposite to each other. For
% example, if the geometry is laid out as shown below
%                             1
%                        2         6
%                        
%                        3         5
%                             4
%   then, pairs should be [1, 4; 2, 5; 3, 6]
%   defaulted to [1,4; 2,5; 3,6]
% "s": a constant used for normalization, usually saturation limit of pole
% "res" : resulted excitations after doing neutralization and normalization
if isempty(pairs) pairs = [1,4; 2,5; 3,6]; end
svec = size(a);
Nsample = svec(1,1);
Npole = svec(1,2);
%Now neutralize the excitations: Make sum = 0;
for i = 1:Nsample;
    sumi = sum(a(i,:),2);
    neut(i,:) = a(i,:) - sumi/Npole;
end
%Now normalize the excitations: 

% % METHOD 1: Make sum of squares to be a constant = s^2
% for i = 1:Nsample
%     sum = a(i,:)*a(i,:)';%sum of squares of the elements in this raw
%     factor = sqrt(s.^2/sum);
%     norm(i,:) = factor*neut(i,:);
% end

% % METHOD 2: Make maximum absolute pole strength to be a constant = s
% for i = 1:Nsample
%     mp = max(abs(neut(i,:)));
%     factor = s/mp;
%     norm(i,:) = factor*neut(i,:);
% end

% METHOD 3: Find the excitation which will give the highest force without
% changing the direction. Actually, this is what we want for comparison of
% various directions in terms of magnitude of forces.

%Reference lab-book pages 28-28-29.
for i = 1:Nsample
    p = a(i,:); %current set of excitation short-hand
    for j = 1:Npole/2
        d(j) = abs(p(pairs(j,1))^2 - p(pairs(j,2))^2);
    end
    [mdiff mi] = max(d);
    %mi is the index of pair with highest force
    id = pairs(mi,1); ir = pairs(mi,2); %short-hand
    drv = abs(p(id)); ret = abs(p(ir));
    if drv > ret
        q(id) = s;
        q(ir) = 0;
    elseif drv < ret
        q(id) = 0;
        q(ir) = s;
    else % this means drv = ret, and since this was supposed to 
%          be the highest force pair, force for all pairs = 0.
        norm(i,:) = 0;
        continue;
    end
    % coming here ensures that p(id) =~ +/- p(ir); so
    % p(id) + p(ir) ~= 0 AND p(id) - p(ir) ~= 0;
        
    C = (q(id)^2 - q(ir)^2)/(p(id)^2 - p(ir)^2);
    K = (q(id) + q(ir))/(p(id) + p(ir));
    
    for j = 1:Npole/2
        id = pairs(j,1); ir = pairs(j,2);
        if(p(id) + p(ir) == 0)
            norm(i,id) = 0; %conserving current
            norm(i,ir) = 0;
        else
            % refer lab-book page 29 for equations
            norm(i,id) = (0.5/K)*(C*(p(id) - p(ir)) + K^2*(p(id) + p(ir)));
            norm(i,ir) = (0.5/K)*(-C*(p(id) - p(ir)) + K^2*(p(id) + p(ir)));
        end
    end 
    %finally check for saturation
    icross = find(abs(norm(i,:)) > s);
    if ~isempty(icross)
        factor = s/norm(i,icross);
        norm(i,:) = factor*norm(i,:);
    end
end