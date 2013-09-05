function [out, X,Y] = fBmXY_HD(viscosity, bead_radius, sampling_rate, duration, tempK, numpaths, alpha)

% MSD Simulator function
% yingzhou/desktop/MSD Bayes/Functions
% last modified 08/19/13 (yingzhou)
%
%fBmXY_HD simulates an anomalous bead diffusion experiment for a bead with an alpha (or slope value) of H.
%
%  
%  [displacement] = sim_newt_fluid(viscosity, bead_radius, sampling_rate,
%                                  duration, temp, dim, numpaths, seed);  
%   
%  where "viscosity" is in [Pa sec] 
%        "bead_radius" is in [m] 
%		 "sampling_rate" is in [Hz] 
%        "duration" is in [s]
%        "tempK" is in [K]
%        "numpaths" is the number of particle paths to be simulated
%        "H" is the anomalous exponent*2
%        
%  Notes:  
%

out = [];

H = alpha/2;
Np=numpaths; %number of paths
N = duration*sampling_rate; % number of points in the path
Tf = duration;  % total time [s]  
% One can use total time and dt instead
  % N = Tf/dt;  

k = 1.3806e-23;
kT = k*tempK; % kBoltzman x T @ 300K
DfBm = kT/(6*pi*viscosity*bead_radius);  
  
%% Set up time vector and covariance matrix  
% Vector for time
  t =linspace(0,Tf,N);

% Construction covariance matrix
  t1=repmat(t,N,1);
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

for i_spot = 1:numpaths
    out(:, :, i_spot) = [X(:, i_spot) Y(:, i_spot)];
end
% calib_um = 0.152;
% 
% frames = repmat([1:frame]',1,Np);
% ids=repmat([1:Np],frame,1);
% tr = [frames(:)*time/frame-time/frame ids(:) frames(:) x(:) y(:) zeros(Np*frame,4)];
% outfile = save_evtfile(['DA_D=' num2str(D) '_alpha=' num2str(alpha) '_N=30_' num2str(time) 's'], tr, 'm', calib_um);
