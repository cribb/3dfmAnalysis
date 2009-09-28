function [time, stored_position, stored_velocity, stored_stress] = ...
                      RP_force_on_a_bead_surface(varargin)
%RP_FORCE_ON_A_BEAD_SURFACE computes force on bead embedded in ROLIE-POLY material.
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%  
% This is a code which simulates the response of a bead to a step force in
% a VE fluid which behaves by the Rolie-Poly constitutive law.  The
% experimental scenario is a micro-bead in an entangled polymer soln is
% exposed to a step magnetic force.  Position vs. time is measured with
% video microscopy. 
%  
% There is a background viscosity which is higher than, but on the order of
% magnitude of water.  We will use the infinite shear viscosity for this
% value
%
% The polymer starts out in equilibrium and is deformed along the surface
% of the bead (and elswhere in space) as governed by the rate of strain
% tensor for Stokes Creeping Flow past a sphere.
%
% At each time step, the polymer stress at the surface of the sphere is
% calculated (via RP) and the polymer contribution to drag is calculated.
%
% The net drag force (background viscosity + polymer stress) is calculated
% and used to calculate dv/dt=Fnet/m  for the bead at each time step.
%
% dv/dt is integrated twice to give the spatial (r vs t) response of the
% bead which we expect via video microscopy.
%
% Notes.  Stress is integrated with an RK4 algorithm.  a->v->r is done with
% simple Euler.
%
%  [time, stored_position, stored_velocity, stored_stress] = ...
%                                    RP_force_on_a_bead_surface(RP_params);
%   
%  
% where RP_params is a structure that contains fields for the different 
% tunable parameters for the RP modeling.  
%
% Running this function without any inputs will generate a model with
% default (and probably useless) parameter values.
%
% Components of the structure:           
%             a        = bead radius in [m]
%             rho      = bead density in [kg/m^3];
%             m        = bead mass in [kg] (auto-calculable in code); 
%             Ge       = plateau modulus in [Pa]
%             tr       = time scale, retraction in [s]
%             td       = time scale, diffusive reptation in [s]
%             eta_bg   = background viscosity in [Pa s]
%             delta    = ROLIE-POLY parameter, usually set to -0.5
%             beta     = ROLIE-POLY parameter, usually set to 1
%             F        = force applied to the bead in [N]
%             x0       = initial position in [m]
%             v0       = initial velocity in [m]
%             t0       = initial time in [s]
%             stress0  = initial stress in [Pa]
%             duration = length of model "experiment" in [s]
%

if nargin < 1
    RP_params = [];
elseif nargin == 1
    RP_params = varargin{1};
elseif nargin > 1;
    a        = varargin{1};
    rho      = varargin{2};
    m        = varargin{3};

    Ge       = varargin{4};
    tr       = varargin{5};
    td       = varargin{6};
    eta_bg   = varargin{7};
    delta    = varargin{8};
    beta     = varargin{9};

    F        = varargin{10};
    x0       = varargin{11};
    v0       = varargin{12};
    t0       = varargin{13};
    stress0  = varargin{14};
    duration = varargin{15};
end;

if exist('RP_params')    
    RP_params = RP_checkparams(RP_params);

    a        = RP_params.a;
    rho      = RP_params.rho;
    m        = RP_params.m;

    Ge       = RP_params.Ge;
    tr       = RP_params.tr;
    td       = RP_params.td;
    eta_bg   = RP_params.eta_bg;
    delta    = RP_params.delta;
    beta     = RP_params.beta;

    F        = RP_params.F;
    x0       = RP_params.x0;
    v0       = RP_params.v0;
    t0       = RP_params.t0;
    stress0  = RP_params.stress0;
    duration = RP_params.duration;   
end




%--------              
% DOMAIN
%--------

% angular resolution in radians
dtheta = pi/10;  

% we leave out the first and last dtheta so that we can not deal with any
% singularities.  Their contribution is minimal in any event. 
Theta  = dtheta:dtheta:pi-dtheta; 

% radial resolution in bead radii, for now, we will just look at the
% surface but we may want to investigate a field later so the architecture
% is in place.
dr = a;     
R  = a:dr:2*a;

% defines mesh which we can evolve stress on.  Advection along streamlines
% is not included at this point since we are just looking at the bead surface.
[r theta] = meshgrid(R, Theta);  



%-----------------
% TIME MANAGEMENT
%-----------------

% Because we will be taking very small steps, it is inefficient and
% impractical to record them all in a list for memory reasons, so we must
% pick out a data point every so often and record it.  We will decide this
% based on the total number of recorded iterations we want.
record_iterations=1000;

% This is the time needed to reach steady state (95% Vss) in a newtonian
% fluid of viscosity eta_bg. This is the largest possible stable timestep.
% As such...we must take very small steps
timestep=-log(.05)*m/(6*pi*eta_bg*a);  

dt=floor(timestep/10^(floor(log10(timestep))))*10^floor(log10(timestep));

% number of true time steps
true_iterations = duration/dt; 

% this is what we will mod by to get the right number of data points.
mod_factor=floor(true_iterations/record_iterations); 

% Finally, the time vector.
time=0:mod_factor*dt:(duration - (1/mod_factor*dt));
time = time + t0;


%------------------
% Preparing output
%------------------

% The vectors we want to store are time, polymer drag, velocity and
% position.  These are the physical data we obtain.
stored_velocity=zeros(1,record_iterations+1);
stored_position=zeros(1,record_iterations+1);

% we will also refresh at each time step, stress field and deformation
% field. At the moment these are not stored, but if we wanted to visualize
% them at any point we could.

% I have defined the 3x3 stress tensor as a 9 element list at every point
% on a mesh. This results in a 3 dimensional array.  Dimensions 1 and 2 are
% spatial (theta and R) and the third is a vector which stores all nine
% components of the stress tensor in a list.  Provided below are 
% functions which do matrix multiplications, traces etc. on these lists.
identity = zeros(length(Theta),length(R),9);
identity(:,:,1:4:9) = 1;

% Set stress to equilibrium based on RP definition.
if exist('stress0')
    stress = stress0;
else
    stress = identity; 
end

% Pre define Kappa to prevent growth inside a loop
kappa = zeros(length(Theta),length(R),9);  

position = x0;

% inital velocity based on background viscosity
velocity = v0;  
stored_velocity(1)=velocity;
% stored_stress(:,:,1) = stress;

% this defines the deformation tensor as a function of bead velocity and
% Stokes newtonian creeping flow. Since this is the only non zero component
% at the surface, I have not included the other terms which would be
% relevant to the field around the bead. They can be easily added later but
% do not affect the surface sumulation at the moment.

% Coupled RK4 steps evolution of stress at all points in the domain and
% velocity of bead....Oh Boh
count = 0;
mod_factor_for_printing = floor(true_iterations/100);

for i=1:true_iterations    

    kappa(:,:,2)=3/(2*a)*velocity*sin(theta);

    [velocity stress] = RK4_RP_surface(m,a,F,Ge,eta_bg,td,tr,beta,delta,...
                        Theta,theta,R,velocity, kappa, stress, dt, dtheta);

    position = position + velocity*dt;

    if mod(i,mod_factor) == 0
        stored_velocity(floor(i/mod_factor)) = velocity;    
        stored_position(floor(i/mod_factor)) = position;
        % stored_stress is 4D array (R,theta,tensor_elements,i)
        stored_stress(:,:,:,floor(i/mod_factor)) = stress;  
    end
    
    if mod(i, mod_factor_for_printing) == 0
        fprintf('pct finished: %i, t_model(end): %f, %s \n', count, i*dt, datestr(now));
        count = count + 1;
    end
end


return;


function [V stress_out] = RK4_RP_surface(m,a,F,Ge,eta_bg,td,tr,beta,...
                          delta,Theta,theta,R,velocity, kappa, stress, dt, dtheta)


%you will need mymmulti, mymtrans, mymtrace functions in your directory

%theta is a polar grid of theta (from [theta, r]=meshgrid....)
%v is the bead velocity and needs to be a scalar
%kappa is a grid of tensor values (theta x r x 9)
%stress is a grid of tensor values dimensions (theta x r x 9)
%dt is the timestep

identity=zeros(length(Theta),length(R),9);
identity(:,:,1:4:9)=1;

k1 = Ge   * ( mymmulti(kappa,stress) + ...
              mymmulti(stress,mymtrans(kappa)) - ...
              1/td * ( stress - identity ) - ...
              2    * ( 1 - ((mymtrace(stress)/3) .^ (-1/2))) / ...
              tr  .* ( stress + beta*(mymtrace(stress)/3).^delta .* ...
                     ( stress - identity)) );
     
m1 = ( F - ( 2*pi*a^2*dtheta * ( sum( ( stress(:,1,1) - 1) .* ...
                                      cos(theta(:,1)) .* sin(theta(:,1))) + ...
                                 sum(stress(:,1,2) .* sin(theta(:,1)) .* ...
                                     sin(theta(:,1))))) - ...
            6*pi*eta_bg*a*velocity)/m;

kappa(:,:,2) = 3 / (2*a) * (velocity+dt*m1/2) * sin(theta);


k2 = Ge   * ( mymmulti(kappa,stress+k1*dt/2) + ...
              mymmulti(stress + k1*dt/2,mymtrans(kappa)) - ...
              1/td * ( stress + k1*dt/2 - identity) - ...
              2    * (1-((mymtrace(stress+k1*dt/2)/3).^(-1/2))) / ...
              tr  .* ( stress + k1*dt/2 + ...
                       beta*(mymtrace(stress+k1*dt/2)/3).^delta .* ...
                     ( stress + k1*dt/2 - identity)));
                 
m2 = ( F - ( 2*pi*a^2*dtheta * ( sum( ( stress(:,1,1) + dt/2*k1(:,1,1) - 1) .* ...
                                      cos(theta(:,1)) .* sin(theta(:,1))) + ...
                                 sum( ( stress(:,1,2) + dt/2*k1(:,1,2)) .* ...
                                      sin(theta(:,1)) .* sin(theta(:,1))))) - ...
             6*pi*eta_bg*a*(velocity+dt/2*m1))/m;

kappa(:,:,2) = 3 / (2*a) * (velocity+dt*m2/2) * sin(theta);


k3= Ge    * ( mymmulti(kappa,stress+k2*dt/2) + ...
              mymmulti(stress + k2*dt/2,mymtrans(kappa)) - ...
              1/td * ( stress + k2*dt/2 - identity) - ...
              2    * (1-((mymtrace(stress+k2*dt/2)/3).^(-1/2))) / ...
              tr  .* ( stress + k2*dt/2 + ...
                       beta*(mymtrace(stress+k2*dt/2)/3).^delta .* ...
                     ( stress+k2*dt/2 - identity)));     
                 
m3= ( F - ( 2*pi*a^2*dtheta * ( sum( ( stress(:,1,1) + dt/2*k2(:,1,1) - 1) .* ...
                                      cos(theta(:,1)) .* sin(theta(:,1))) + ...
                                sum( ( stress(:,1,2) + dt/2*k2(:,1,2)) .* ...
                                      sin(theta(:,1)).*sin(theta(:,1))))) - ...
            6*pi*eta_bg*a*(velocity+dt/2*m2))/m;

kappa(:,:,2) = 3 / (2*a) * (velocity+dt*m3) * sin(theta);	


k4 = Ge   * ( mymmulti(kappa,stress+k3*dt) + ...
              mymmulti(stress + k3*dt,mymtrans(kappa)) - ...
              1/td * ( stress + k3*dt - identity) - ...
              2    * (1-((mymtrace(stress+k3*dt)/3).^(-1/2))) / ...
              tr  .* ( stress + k3*dt + ...
                       beta*(mymtrace(stress+k3*dt)/3).^delta .* ...
                     ( stress+k3*dt - identity)));
                 
m4 = ( F - ( 2*pi*a^2*dtheta * ( sum( ( stress(:,1,1) + dt*k3(:,1,1) - 1) .* ...
                                       cos(theta(:,1)) .* sin(theta(:,1))) + ...
                                 sum( ( stress(:,1,2) + dt*k3(:,1,2)) .* ...
                                       sin(theta(:,1)) .* sin(theta(:,1))))) - ...
            6*pi*eta_bg*a*(velocity+dt*m3))/m;


stress_out = stress   + dt/6*( k1 + 2*k2 + 2*k3 + k4);
V          = velocity + dt/6*( m1 + 2*m2 + 2*m3 + m4);

return;


function C = mymmulti(A,B)

    %A and B must be n by m by 9 3d arrays where slices 1-9 represent the nine
    %elements of a 3x3 matrix

    C(:,:,[1:9]) = A(:,:,[1,1,1,4,4,4,7,7,7]) .* B(:,:,[1,2,3,1,2,3,1,2,3]) + ...
                   A(:,:,[2,2,2,5,5,5,8,8,8]) .* B(:,:,[4,5,6,4,5,6,4,5,6]) + ...
                   A(:,:,[3,3,3,6,6,6,9,9,9]) .* B(:,:,[7,8,9,7,8,9,7,8,9]);
return;


function trace=mymtrace(A)
    trace=zeros(size(A));

    q = A(:,:,1)+A(:,:,5)+A(:,:,9);
    
    for i=1:9
        trace(:,:,i) = q;
    end
return;


function C=mymtrans(A)
    C(:,:,[1:9])=A(:,:,[1,4,7,2,5,8,3,6,9]);
return;

