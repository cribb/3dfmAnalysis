function h = plot_vel_field(map ,video, h )
%   function h = plot_vel_field(map ,video, h )
%
%    This function takes the output of the vel_field program and plots it
%  The inputs are
%     Map: a structure with the following fields 
%           xPosVal  The x coordinate for the horizontal center of each bin
%           yPosVal  The y coordinate for the vertical center of each bin
%           sectorX  A vector of the average x velocities for each sector
%           sectorY  A vector of the average y velocities for each sector
%
%     Video:  A structure that we are using to pass video parameters
%         for this function we only need the xDim and yDim fields     

if nargin < 3 || isempty(h)
    h = figure;
end

if nargin < 2 || isempty(video)
    video.xDim = 656;
    video.yDim = 494;
end
quiver(map.xPosVal,map.yPosVal,map.sectorX,map.sectorY,0);
set(gca,'YDir','reverse'); 
xlim([0 video.xDim]);
ylim([0 video.yDim]);

end

