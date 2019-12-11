function map = vel_field(filename, xCol, yRow, video)

% function vel_field
%
%Loads an evt dataset and partitions the space into a user defined number
%of columns and rows. Returns an average x and y velocity for each of the
%partitions (weighted per tracker)
%
% function [xPosVal, yPosVal, sectorX, sectorY] = vel_field(filename, xCol, yRow, video)
%  
%  Outputs
%       
%      *Each output is in the form of a vector with each position
%      representing the "sector" (partition number). This number starts at
%      sector 1 for the top left most sector and increments across columns
%      and then goes to the next row. Example of a 5x5 grid below 
%
%                        1  2  3  4  5  
%                        6  7  8  9  10  
%                        11 12 13 14 15
%                        16 17 18 19 20
%                        21 22 23 24 25
% 
%      So the 19th position of the vector would represent Row 4, Col 4 in
%      this instance.
%        
%      Output is returned as the map structure with the following fields
%      xPosVal  : The x position of the center of a sector in pixels  
%      yPosVal  : The y position of the center of a sector in pixels  
%      sectorX  : The average x velocities of each sector  
%      sectorY  : The average y velocities of each sector  
%
%  Inputs       
%      filename: The filename of the evt data set   
%      xCol : The number of columns to partition the data into (defaults to
%      5)
%      yRow : The number of rows to partition the data into (defaults to 5)
%      video : A structure containing video information
%      video.xDim  movies's width in pixels (defaults to 656)
%      video.yDim  movie's height in pixels (defaults to 494)
%      video.fps   movie's frames per second (defaults to 90)  
%      video.pixelsPerMicron conversion factor for pixels per micron (defaults to .542) 
%
%

%% Manage Input Parameters, declarations,set constants 
video_tracking_constants;
if (nargin < 4 || isempty(video))
   video.xDim = 656;
   video.yDim = 494;
   video.fps = 90;
   video.pixelsPerMicron = .542;
end
if (nargin < 3 || isempty(yRow));       yRow=5;              end
if (nargin < 2 || isempty(xCol));       xCol=5;              end

xBinSize = video.xDim/xCol;
yBinSize = video.yDim/yRow;
micronsPerPixel = 1/video.pixelsPerMicron;
%Declare variables
table_data = [];

sectorList = [];
sectorX = zeros(1,xCol*yRow);
sectorY = zeros(1,xCol*yRow);
sectorCount = zeros(1,xCol*yRow);

%% Load Data
if ~isnumeric(filename)
    % load video data
    table_data = load_video_tracking(filename, video.fps, 'pixels', micronsPerPixel, 'absolute', 'no', 'table');

else
    % in this case, we assume that the incoming units are in their intended
    % form
    table_data = filename;
    % v(:,X:Z) = v(:,X:Z) * calib_um * 1e-6;
end

%% Convert to a bead struct
beads = convert_vidtable_to_beadstruct(table_data);
  
%% Convert to microns, Smooth the Data and make velocity columns assign a sector while we are at it
for i = 1:length(beads)
    
    %assign a sector based on the binning parameters. Sectors are numbered
    %sequentially with the top left sector being 1 and incrementing left to
    %right and then top to bottom. Because we are starting with 1,1, we
    %will round up 
    
    %note to self, watch out for x = "0"
    
    xBinVal = ceil(beads(i).x/xBinSize);
    yBinVal = floor(beads(i).y/yBinSize);
    beads(i).sector = yBinVal*xCol + xBinVal; 
        
    %Convert pixel values to microns
    beads(i).xmicron = beads(i).x/video.pixelsPerMicron;
    beads(i).ymicron = beads(i).y/video.pixelsPerMicron;
    
%     beads(i).xmicron = smooth(beads(i).xmicron,50);
%     beads(i).ymicron = smooth(beads(i).ymicron,50);

    if ~isempty(beads(i).xmicron)
        beads(i).xvel = CreateGaussScaleSpace(beads(i).xmicron,1,4).*video.fps;
        beads(i).yvel = CreateGaussScaleSpace(beads(i).ymicron,1,4).*video.fps;
    else
        beads(i).xvel = [];
        beads(i).yvel = [];
    end

%     beads(i).xvel = [];
%     beads(i).yvel = [];
    
%     beads(i).xvel = diff(beads(i).xmicron)*video.fps; 
%     beads(i).yvel = diff(beads(i).ymicron)*video.fps; 
%     
%     %kludgy hack to keep the vector the same size
%     beads(i).xvel = [beads(i).xvel(2);  beads(i).xvel];
%     beads(i).yvel = [beads(i).yvel(2);  beads(i).yvel]; 

end

%% Binning and averaging data
%start by iterating through all of the beads

for i = 1:length(beads)

 %For each bead we are going to find all the positions that share a sector
 %and determine an average velocity for the bead in that sector. We'll do
 %this for x and y components, maybe by sign in the future
 
 sectorList = unique(beads(i).sector); %let's get a list of the sectors, and get an average for each
    for j = 1:length(sectorList)
          indices = find(beads(i).sector == sectorList(j));
          tempXVel = beads(i).xvel;
          tempYVel = beads(i).yvel;
          
          %tempXVel(indices);
          xVelAvg = mean(tempXVel(indices));
          yVelAvg = mean(tempYVel(indices));
          sectorCount(sectorList(j)) = sectorCount(sectorList(j)) + 1;
          sectorX(sectorList(j)) = sectorX(sectorList(j)) + xVelAvg;
          sectorY(sectorList(j)) = sectorY(sectorList(j)) + yVelAvg;
          
    end
end

%Divide by the numbers to get the averages. (Could use NaN's to get rid of
%the loop and just do element by element div.
for k = 1:length(sectorCount)
    if (sectorCount(k)>0)
    sectorX(k) = sectorX(k)/sectorCount(k);
    sectorY(k) = sectorY(k)/sectorCount(k);

    end
end


%% Plot
%Lets generate the x and y positions for the quiver plot
%for x values we have a sequence of xCol that will repeat
xValMed = xBinSize/2;
yValMed = yBinSize/2;

xPosValOrig = [1:xCol];
xPosValOrig = xPosValOrig*xBinSize - xValMed;
xPosVal = [];
for i = 1:yRow
   xPosVal = [xPosVal xPosValOrig];
end

yPosValOrig = [1:yRow];
yPosValOrig = yPosValOrig*yBinSize - yValMed;


yPosVal = [];
for j = 1:xCol
      yPosVal = [yPosVal; yPosValOrig];
end

yPosVal = reshape(yPosVal,xCol*yRow,1);
yPosVal = yPosVal';

map.yPosVal = yPosVal;
map.xPosVal = xPosVal;
map.sectorX = sectorX;
map.sectorY = sectorY;
