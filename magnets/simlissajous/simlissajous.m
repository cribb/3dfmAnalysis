function force = simlissajous(mags)
% SIMLISSAJOUS Simulates velocities visualization using Leandra's equations. Needs coil currents as input
%
% 3DFM function  
% Magnets/simlissajous  
% last modified 11/17/08 (krisford)

TETRA = 0; %Switch to select which geometry to simulate
HEXA = 1;
THREEPOLE = 0;
if (TETRA)
    excitation = coils2poles(mags.analogs); %need only for tetra poles
    %pole_locations = tetra(1);
    pole_locations = [-300, 0 ,300; 300, 0 ,300; 0 , -300, -300; 0,300,-300];
elseif (HEXA)
    excitation = mags.analogs; %for 6 poles coils current are same as pole currents
    R = 60; % 0.5*separation between two diagonally opposite poles
%     P = R.*[-1 0 0; 0 -1 0; 0 0 -1;1 0 0;0 1 0;0 0 1];
% %     pole_locations = rotate_to_vector(P,pi/4,atan(1/sqrt(2)));
% %     
    H = 2*R/sqrt(3); %separation between two planes
    r = R*sqrt(2/3); %radius of inner circle described by poles in one plane
    %this gives r = H/sqrt(2)
    P(1,1:3) = [0, r, H/2];
    P(2,:) = [-0.866*r, r/2, -H/2];
    P(3,:) = [-0.866*r, -r/2, H/2];
    P(4,:) = [0, -r, -H/2];
    P(5,:) = [0.866*r, -r/2, H/2];
    P(6,:) = [0.866*r, r/2, -H/2];
    pole_locations = P;
elseif THREEPOLE;
    excitation = mags.analogs; %for 6 poles coils current are same as pole currents
    R = 60; % 0.5*separation between two diagonally opposite poles
%     P = R.*[-1 0 0; 0 -1 0; 0 0 -1;1 0 0;0 1 0;0 0 1];
% %     pole_locations = rotate_to_vector(P,pi/4,atan(1/sqrt(2)));
% %     
    H = 2*R/sqrt(3); %separation between two planes
    r = R*sqrt(2/3); %radius of inner circle described by poles in one plane
    %this gives r = H/sqrt(2)
    P(1,1:3) = [0, r, H/2];
    P(2,:) = [-0.866*r, -r/2, H/2];
    P(3,:) = [0.866*r, -r/2, H/2];
   
    pole_locations = P;
else
    error('Switch for pole-geometry selection is not defined properly');
end

fm = fmatrix(pole_locations);
disp('Doing force calculations...');
force = Bforce(fm,excitation);
disp('Force calculations done...Plotting visualization now!');

data.velx = force(:,1);
data.vely = force(:,2);
data.velz = force(:,3);
% save('Simulation_forces','data');

visVelocities(data,pole_locations,'both');


%coil configuration for 6 poles           looking from front & top 
%                                                 
%                                                        1
%                                                     
%                                                 2              6 
%                                                 
%                                                 
%                                                 3              5 
%                                                       
%                                                        4
% take R = radius of the circle formed by pole-tips
%      H = height difference between two planes
% P1 = [0, R, H/2];
% P2 = [-0.866*R, R/2, -H/2];
% P3 = [-0.866*R, -R/2, H/2];
% P4 = [0, R, -H/2];
% P5 = [0.866*R, -R/2, H/2];
% P6 = [0.866*R, R/2, -H/2];
