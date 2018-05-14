function outs = vst_collect_video_metadata(VidFileInfoTable, fps, calibum, varargin)
% ASSUME THE MIP AND FIRSTFRAME AND TRACKING DATA HAVE SAME SHAPE IMAGES

%    defaultHeight = 1;
%    defaultUnits = 'inches';
%    defaultShape = 'rectangle';
%    expectedShapes = {'square','rectangle','parallelogram'};
% 
%    p = inputParser;
%    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
%    addRequired(p,'width',validScalarPosNum);
%    addOptional(p,'height',defaultHeight,validScalarPosNum);
%    addParameter(p,'units',defaultUnits,@isstring);
%    addParameter(p,'shape',defaultShape,...
%                  @(x) any(validatestring(x,expectedShapes)));
%    parse(p,width,varargin{:});
%    
%    a = p.Results.width*p.Results.height; 

% handle the inputs
defaultX = 0;
defaultY = 0;

ins = inputParser;

validTable = @(x) istable(x) && ~isempty(x);
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x>0);


addRequired(ins, 'VidFileInfoTable', validTable);
addRequired(ins, 'fps', validScalarPosNum);
addRequired(ins, 'calibum', validScalarPosNum);
addOptional(ins, 'Width', validScalarPosNum);
addOptional(ins, 'Height', validScalarPosNum);
addOptional(ins, 'X', validScalarPosNum);
addOptional(ins, 'Y', validScalarPosNum);
parse(ins,VidFileInfoTable, fps, calibum, varargin{:});

N = size(VidFileInfoTable,1);


height = NaN(N,1);
width = NaN(N,1);

for k = 1:N
    
    imageinfo = true;
    
    if ~isempty(VidFileInfoTable.FirstFrameFiles{k})
        testimage = imread(VidFileInfoTable.FirstFrameFiles{k});
    elseif ~isempty(VidFileInfoTable.MipFiles{k})
        testimage = imread(VidFileInfoTable.MipFiles{k});
%     elseif ~isempty(VidFileInfoTable.VideoFiles{k})
    else
        imageinfo = false;
    end

    if imageinfo
        [height(k,1), width(k,1)] = size(testimage);
    else
        [height(k,1), width(k,1)] = NaN(1,2);
    end
    
end

outs.Height = height;
outs.Width = width;

