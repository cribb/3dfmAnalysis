function [X,Y,r,sigx1,sigy1,sigx2,sigy2,DD,HH] = fBmXY_HD(H,DfBm,Np)

% Generating Np paths given H and DfBm

%% Set up parameters
% number of points in the path
  N = 1800;
% total time
  Tf = 30;  % [s]  
% One can use total time and dt instead
  % N = Tf/dt;
  

%% Set up time vector and covariance matrix  
% Vector for time
  t =linspace(0,Tf,N);

% Construction covariance matrix
  t1=repmat(t,1800,1);
  t2=t1';
  dt12=abs(t2-t1);
  S=0.5*(t1.^(2*H)+t2.^(2*H)-dt12.^(2*H));
  
%% Find square root matrix of S
  [V,D] = eig(S);   % Diagonalization
  s1=sqrt(D);        
  r=V*s1*inv(V);    % r*r = S

%% Constructing fBm paths
  u = randn(Np,N);
  X = sqrt(DfBm)*(u*r)';
  u = randn(Np,N);
  Y = sqrt(DfBm)*(u*r)';

%% Calculate standard deviations
  dX=X(2:end,:)-X(1:end-1,:);
  dY=Y(2:end,:)-Y(1:end-1,:);
  [mu,sigx1]=normfit(dX);
  [mu,sigy1]=normfit(dY);
  
  dX=X(3:3:end,:)-X(1:3:end,:);
  dY=Y(3:3:end,:)-Y(1:3:end,:);
  [mu,sigx2]=normfit(dX);
  [mu,sigy2]=normfit(dY);

%% Calculate H and DfBm separately for X and Y  
  hx  = log(mean(sigx1)./mean(sigx2))/log(t(2)/t(3));
  ddx = ((mean(sigx1))^2-(mean(sigx2))^2)./(t(2)^(2*hx)-t(3)^(2*hx));

  hy  = log(mean(sigy1)./mean(sigy2))/log(t(2)/t(3));
  ddy = ((mean(sigy1))^2-(mean(sigy2))^2)./(t(2)^(2*hy)-t(3)^(2*hy));
  
  HH = [hx, hy];
  DD = [ddx, ddy];
