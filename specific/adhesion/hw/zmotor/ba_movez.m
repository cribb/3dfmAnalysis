function ba_movez(h, targetpos, zspeed)
% BA_MOVEZ moves the Thorlabs z-motor to the target position.
%

% Moves the Thorlabs z-motor, h, to target z-position. Get h by running
% ba_initz.
%

if nargin < 3 || isempty(targetpos)
    zspeed = 'slow';
end

if nargin < 2 || isempty(targetpos)
    error('No target position defined.');
end

if nargin < 1 || isempty(h)
    fprintf('Grabbing new handle to z-motor...');    
    h = ba_initz;
    fprintf('done. \n');
end    

% set velocity based on 'fast' or 'slow'
if contains(zspeed,'fast')
    % Last two numbers describe acceleration and velocity [mm/sec]
    h.SetVelParams(0, 0, 4, 2); 
else
    % set motor velocity to 0.2 mm/sec
    h.SetVelParams(0, 0, 1, 0.2); 
end
    
Zheight = h.GetPosition_Position(0);
disp(['Starting z-position: ', num2str(Zheight), ' [mm].']);
disp('Moving to final position...');

% move from start position to target position
h.SetAbsMovePos(0,targetpos);
h.MoveAbsolute(0,1==0);

while Zheight < 0.99*targetpos || Zheight > 1.01*targetpos
    Zheight = h.GetPosition_Position(0);
end

disp(['Final z-position: ', num2str(Zheight), ' [mm].']);
disp('If not exact, it will continue settling to target value.');

return
