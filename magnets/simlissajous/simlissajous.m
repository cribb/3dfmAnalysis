function data = simlissajous(mags)
%Simulates velocities visualization using Leandra's equations
%Needs coil currents as input
TETRA = 0; %Switch to select which geometry to simulate
HEXA = 1;
if (TETRA)
    excitation = coils2poles(mags.analogs); %need only for tetra poles
    %pole_locations = tetra(1);
    pole_locations = [-300, 0 ,300; 300, 0 ,300; 0 , -300, -300; 0,300,-300];
elseif (HEXA)
    excitation = mags.analogs; %for 6 poles coils current are same as pole currents
     R = 60; %um
    H = R*2*cos(pi/6); %um
    P(1,1:3) = [0, R, H/2];
    P(2,:) = [-0.866*R, R/2, -H/2];
    P(3,:) = [-0.866*R, -R/2, H/2];
    P(4,:) = [0, -R, -H/2];
    P(5,:) = [0.866*R, -R/2, H/2];
    P(6,:) = [0.866*R, R/2, -H/2];
    pole_locations = P;
%     pole_locations = R.*[-1,0,0;1,0,0;0,-1,0;0,1,0;0,0,-1;0,0,1];
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

visVelocities(data,pole_locations,'colors');


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
