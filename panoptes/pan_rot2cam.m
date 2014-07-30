function newxy = pan_rot2stage(xy, wellid, fovwidth, fovheight, theta)
% PAN_ROT2STAGE rotates a vector to ludl stage orientation
%
% Panoptes function 
% 
% This function is used by the Panoptes analysis code to rotate a velocity
% vector inplace to coordinate directionality from the camera frame to the
% stage frame. The lower left corner of the stage (in the vicinity of
% optics channel 7) is considered the origin for both the X and Y
% coordinates.
% 
% newxy = pan_rot2stage(xy, wellid, theta) 
%
% where "newxy" is the 
%       "xy" is the 
%       "wellid" is the
%       "theta" is the
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can also be used manually from the matlab command line interface.
%

% First, set up default values for input parameters in case they are empty 
% or otherwise do not exist.

    if nargin < 5 || isempty(theta)
        theta = -pi/2;
    end
    
    if nargin < 4 || isempty(fovheight)
        fovheight = 648;
    end    
    
    if nargin < 3 || isempty(fovwidth)
        fovwidth = 484;
    end

    if nargin < 3 || isempty(wellid)
        error('No well ID defined.');
    end
    
    if nargin < 1 || isempty(xy)
        error('No input coords defined');
    end


    chan = pan_get_channel_id(wellid);

    if ~mod(chan,2) %even
        newxy = [-xy(:,1)  xy(:,2)];
        fprintf('Channel %i is even\n', chan);
    else % odd
        newxy = [ xy(:,1) -xy(:,2)];    
        fprintf('Channel %i is odd\n', chan);
    end

    % do the initial rotation
    theta = -pi/2;
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    rotxy = R * xy';
    
return;
