function poles = coils2poles(coils)
%Converts coil currents to pole excitations for tetrahedral
%geometry. Equations used as of 13th September 2003.

poles(:,1) = coils(:,1) + coils(:,2);
poles(:,2) = coils(:,3) + coils(:,4);
poles(:,3) = -coils(:,1) - coils(:,3);
poles(:,4) = -coils(:,2) - coils(:,4);

return