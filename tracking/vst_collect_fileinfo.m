function outs = vst_collect_fileinfo(mypath, basename_prefix, fps, calibum, varargin)
% Given filename tags, this function confirms existence of data for
% tracking experiment and outputs table structure with info. This should
% work for -optes datasets at the moment.

% ASSUME ALL VIDEO DATA FOR THIS COLLECTION IS IN THE SAME PATH

% maybe it would be better to use a cell array input for video file names.
% removes one level of automation/globbing, but makes this function more
% serviceable in the long run.

defaultVideoSuffix = '.avi';
% defaultVideoType = 'folder';
defaultTrackingSuffix = '_TRACKED.csv';
defaultFirstFrameSuffix = '.0001.pgm';
defaultMipSuffix = '.mip.pgm';

validFileList = @(x) ~isempty(dir([ '*' x '*']));
validRegexpFileList = @(x) checkTrackingFileList(mypath, x);
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x>0);
validVideoType = @(x) any(validatestring(x,expectedVideoTypes));

ins = inputParser;
addRequired(ins, 'mypath', @isfolder);
addRequired(ins, 'basename_prefix', validRegexpFileList);
% addRequired(ins, 'video_type', validVideoType);
addRequired(ins, 'fps', validScalarPosNum);
addRequired(ins, 'calibum', validScalarPosNum);
addOptional(ins, 'TrackingSuffix', defaultTrackingSuffix, validRegexpFileList);
addOptional(ins, 'VideoSuffix', defaultVideoSuffix, @ischar);
addOptional(ins, 'FirstFrameSuffix', defaultFirstFrameSuffix, validFileList);
addOptional(ins, 'MipSuffix', defaultMipSuffix, validFileList);
addOptional(ins, 'Width', validScalarPosNum);
addOptional(ins, 'Height', validScalarPosNum);
addOptional(ins, 'SampleName', @ischar);

parse(ins, mypath, basename_prefix, fps, calibum, varargin{:});

startpath = pwd;
cd(ins.Results.mypath);
mypath = pwd;

% parse(ins, basename_prefix, fps, calibum, varargin{:});

FOVid = 1;



allfiles = dir;

fname_tracking = [ins.Results.basename_prefix ins.Results.TrackingSuffix];
tracking_list = regexpi( [allfiles.name], fname_tracking, 'match');
tracking_list = tracking_list(:);
    
N = length(tracking_list);

[~,host] = system('hostname');
host = strip(host);

imageinfo = true;

% Paths and hostnames should all be the same per call to this function
path_list = repmat({mypath},N,1);
hostname_list = repmat({host},N,1);
fps_list = repmat(ins.Results.fps, N, 1);
calibum_list = repmat(ins.Results.calibum, N, 1);
samplename_list = repmat({ins.Results.SampleName}, N, 1);

% Pre-seeding lists for the for-loop
video_list = cell(N,1);
first_frame_list = cell(N,1);
mip_list = cell(N,1);
height = NaN(N,1);
width = NaN(N,1);
video_isdir = NaN(N,1);

for k = 1:N

    this_tracking = dir(tracking_list{k});
    
    this_basename = regexpi( this_tracking.name, ins.Results.basename_prefix, 'match');
    this_basename = this_basename{:};
    
    this_video = dir([this_basename ins.Results.VideoSuffix]);
    
    this_firstframe = dir([this_basename ins.Results.FirstFrameSuffix]);
    this_mip = dir([this_basename ins.Results.MipSuffix]);
    
    
%     fname_video    = [ins.Results.basename_prefix ins.Results.VideoSuffix];
%     video_list = regexpi( [allfiles.name], fname_video, 'match');
%     video_list = cellfun(@dir, video_list, 'UniformOutput', true);
    
    
    if ~isempty(this_video)
        video_list{k,1} = this_video.name;
        video_isdir(k,1) = this_video.isdir;
    else
        video_list{k,1} = '';
        video_isdir(k,1) = 0;
    end

    if ~isempty(this_firstframe)
        first_frame_list{k,1} = this_firstframe.name;
    else        
        first_frame_list{k,1} = '';
        logentry(['The file ''' this_firstframe.name ''' was not found'])
    end
    
    if ~isempty(this_mip)
        mip_list{k,1} = this_mip.name;
    else        
        mip_list{k,1} = '';
        logentry(['The file ''' this_mip.name ''' was not found'])
    end
    
    if ~isempty(first_frame_list{k,1})
        testimage = imread(first_frame_list{k,1});
    elseif ~isempty(mip_list{k,1})
        testimage = imread(mip_list{k,1});
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


% outs.VideoIsdir = video_isdir;
outs.SampleName = samplename_list;
outs.Path = path_list;
outs.Hostname = hostname_list;
outs.VideoFiles = video_list;
outs.VideoIsDir = video_isdir;
outs.TrackingFiles = tracking_list;
outs.FirstFrameFiles = first_frame_list;
outs.MipFiles = mip_list;
outs.Width = width;
outs.Height = height;
outs.Fps = fps_list;
outs.Calibum = calibum_list;

outs = struct2table(outs);

DHopt.Format = 'base64';
fovIDs = DataHash(outs, DHopt);

cd(startpath);

return;

function validTrackingFileList = checkTrackingFileList(mypath, tracking_files_regexp)

    validTrackingFileList = false;

    filenames = dir(mypath);
    
    fileinfo = regexpi( [filenames.name], tracking_files_regexp, 'match');
    
    if ~isempty(fileinfo)
        validTrackingFileList = true;
    end
    
return