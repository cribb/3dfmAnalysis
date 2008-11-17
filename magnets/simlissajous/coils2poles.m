function poles = coils2poles(coils)
% COILS2POLES Converts coil currents to pole excitations for tetrahedral geometry
%
% 3DFM function  
% Magnets/simlissajous  
% last modified 11/17/08 (krisford)

%Equations used as of 13th September 2003.

poles(:,1) = coils(:,1) + coils(:,2);
poles(:,2) = coils(:,3) + coils(:,4);
poles(:,3) = -coils(:,1) - coils(:,3);
poles(:,4) = -coils(:,2) - coils(:,4);

return
