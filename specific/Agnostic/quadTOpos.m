function pos = quadTOpos(qpd, jac ,jacType)
% Converts QPD signals into PositionErrors using supplied jacobian. This
% functions is compatible to Laser Tracker version 03.02 to 04.00
dq = qpd - repmat(jac.qgoals,size(qpd,1), 1);
if(isequal(jacType,'Linear'))
    dqpoly = dq;
%  WARNING WARNING: THE CODE BELOW IS A MATLAB REPLICA OF
%  quadTOdeltaQpoly module in particle tracker 03.02 and later. DO NOT
%  CHANGE
elseif(isequal(jacType,'2ndOrder'))    
    dqpoly(:,[1,6,11,16]) = dq;
    
    dqpoly(:,2) = dq(:,1).*qpd(:,1);
    dqpoly(:,3) = dq(:,1).*qpd(:,2);
    dqpoly(:,4) = dq(:,1).*qpd(:,3);
    dqpoly(:,5) = dq(:,1).*qpd(:,4);
    
    dqpoly(:,7) = dq(:,2).*qpd(:,1);
    dqpoly(:,8) = dq(:,2).*qpd(:,2);
    dqpoly(:,9) = dq(:,2).*qpd(:,3);
    dqpoly(:,10) = dq(:,2).*qpd(:,4);
    
    dqpoly(:,12) = dq(:,3).*qpd(:,1);
    dqpoly(:,13) = dq(:,3).*qpd(:,2);
    dqpoly(:,14) = dq(:,3).*qpd(:,3);
    dqpoly(:,15) = dq(:,3).*qpd(:,4);
    
    dqpoly(:,17) = dq(:,4).*qpd(:,1);
    dqpoly(:,18) = dq(:,4).*qpd(:,2);
    dqpoly(:,19) = dq(:,4).*qpd(:,3);
    dqpoly(:,20) = dq(:,4).*qpd(:,4);
else
    disp('quadTOdeltaQpoly: Unrecognized Jacobian Type');
end

try
    % [N X 3] = [N X 20] * [20 X 3]
    %       or= [N X 4] * [4 X 3]
    pos = dqpoly*jac.jac;
catch
    disp(['quadTOpos Error: ',lasterr]);
    keyboard
end