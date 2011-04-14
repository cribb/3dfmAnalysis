function outfilelist = SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels,maxPixelRange, tcrop, xycrop)

%USAGE:
%     SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels, tcrop,
%     xycrop)
%     
if(nargin < 4)
    minPixels = 0;
end

video_tracking_constants;
files = dir(filemask);

count = 1;
for i = 1:length(files)
    filename = files(i).name;
    
    fprintf('Loading %g of %g \n', i, length(files));
    d = load_video_tracking(filename, frameRate, [], [], 'absolute', 'no', 'table', minFrames, minPixels,maxPixelRange, tcrop, xycrop);
    
    if(~isempty(d))
        tracking.spot3DSecUsecIndexFramenumXYZRPY = d;

        fprintf('\t%g trackers in ', length(unique(d(:,ID))));
        fprintf(filename);

        append = 'evt.mat';
        outfile = [filename(1:end-3) append];
        save(outfile, 'tracking');
        
        outfilelist(count) = dir(outfile);
        count = count + 1;
    else
        fprintf('No trackers. No .evt.mat created.');
    end
    fprintf('\n');
end

