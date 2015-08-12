function newxy = pan_rot2stage(xy, wellid, theta)
% PAN_ROT2STAGE rotates a vector to ludl stage orientation
%
% Panoptes function 
% 
% This function is used by the Panoptes analysis code to rotate a velocity
% vector inplace to coordinate directionality from the camera frame to the
% stage frame. The upper left corner of the stage (in the vicinity of
% optics channel 1) is considered the origin for both the X and Y
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

    if nargin < 3 || isempty(theta)
        theta = pi/2;
    end

    if nargin < 2 || isempty(wellid)
        error('No well ID defined.');
    end 

    if nargin < 1 || isempty(xy)
        error('No input coords defined');
    end
    
    if size(xy,2) == 2
        xy = transpose(xy);
    end
    
    channelid = pan_get_channel_id(wellid);

    % do the initial rotation
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    rotxy = R * xy;

%     newxy = transpose(rotxy);
    
    rotxy = transpose(rotxy);
    
    
    
    if mod(channelid,2) % odd
        newxy = [-rotxy(:,1)  rotxy(:,2)];
    else % even
        newxy = [ rotxy(:,1) -rotxy(:,2)];    
    end

    
    
return;
