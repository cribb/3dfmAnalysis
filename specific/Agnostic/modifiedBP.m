function res = modifiedBP(d,boolactive)
% d is the output of load_agnostic_tracking
% Calcuates beadposition vs. time
% Uses the post-jacobian to calculated the positionError during blip
if (nargin < 2 | isempty(boolactive))   boolactive = 'no'; end
jacType = 'UNDEFINED';

res = [];
if(isfield(d,'jilin') & isfield(d,'ji2nd'))
    disp('Error: both, linear and quadratic jacobians are present in the same file. Dont know how to process this data');
    return;
end

if(isfield(d,'jilin'))
    disp('Linear Jacobian estimates are present in the data file');
    jac = d.jilin;
    jacType = 'Linear';  
    if(isfield(d,'jalin')& isequal(boolactive,'yes'))
        jaca = d.jalin;
    end    
end
if(isfield(d,'ji2nd'))
    disp('2nd Order Jacobian estimates are present in the data file');
    jac = d.ji2nd;
    jacType = '2ndOrder';
    if(isfield(d,'ja2nd')& isequal(boolactive,'yes'))
        jaca = d.ja2nd;
    end
end

% in the input structure d,
% the field 'peidle' is calculated by vrpnLogToMatlab program using the most recent jacobian estimate
% Now recalculate them during the "blips" (the periods when noise was being
% injected)
modpei = d.peidle;
if(isequal(boolactive,'yes'))
    modpea = d.peactive.xyz;
end
for c = 1:size(jac,1)
    istart = jac(c).iblip(1,1); iend = jac(c).iblip(1,2);
    modpei(istart:iend,:) = quadTOpos(d.qpd(istart:iend,:),jac(c), jacType);
    if(isequal(boolactive,'yes'))
        % now find if there is any active jacobian updated near to this blip
        tnow = d.t(iend);
        for ca = 1:size(jaca,1);    
            if abs(jaca(ca).tupdate - tnow) <= 1
                modpea(istart:iend,:) = modpei(istart:iend,:);
                break;
            end
        end
    end
end
res.modbpi = modpei - (d.ssense - repmat(d.ssense(1,:), size(d.ssense,1), 1));
if(isequal(boolactive,'yes'))
    res.modbpa = modpea - (d.ssense - repmat(d.ssense(1,:), size(d.ssense,1), 1));
end
res.t = d.t;
res.info = d.info;
 



