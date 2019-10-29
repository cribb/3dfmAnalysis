function zpos = ba_getz(h)
% BA_GETZ returns the current z-position of the Thorlabs z-motor
%

% Returns the current z-position of the Thorlabs z-motor, h. Get h by running
% ba_initz.
%


if nargin < 1 || isempty(h)
    fprintf('Grabbing new handle to z-motor...');    
    h = ba_initz;
    fprintf('done. \n');
end

zpos = h.GetPosition_Position(0);
% disp(['height: ', num2str(zpos)]);

return