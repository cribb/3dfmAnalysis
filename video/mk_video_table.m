function filetable = mk_video_table(filelist, fpslist, calibumlist, width, height, firstframefiles, mipfiles)
% This function helps the user assemble the file structure/table necessary
% to do tracking/trajectory analysis. It's a harsh taskmaster, because
% everything must be in the proper form in order to function properly as a
% database. Where assumptions can be made, this function makes them.
% Otherwise, you must provide the correct information.
%
% firstframe & mip are cell arrays with the first frame and mip images as
% 2-D array in each cell location.
%

    % handle the inputs    

    fpslist = fpslist(:);
    calibumlist = calibumlist(:);
    width = width(:);
    height = height(:);
    firstframefiles = firstframefiles(:);
    mipfiles = mipfiles(:); 
    
    % Handle whether or not the filename situation is what we need. 
    
    % First, the case where there are no files defined. 

    % Is filelist a string with just a filename in it? If not, is filelist 
    % a list of filenames embedded as a cell array? If so, get directory
    % listing for it.
    if ischar(filelist)
        filelist = dir(filelist);
    elseif iscell(filelist)
        for k = 1:length(filelist)
            tmp(k) = dir(filelist{k});
        end        
        filelist = tmp;
    elseif isempty(filelist)
        error('No tracking filenames defined.');
        % XXX Update this such that the return is an empty table 
        % with the proper table headings.
    else
        error('Unknown error.');
    end
    
    
    % Is firstframefiles a string with just a filename in it? If not, is firstframefiles
    % a list of filenames embedded as a cell array? If so, get directory
    % listing for it.
    if isempty(firstframefiles)
        warning('No first frame filenames defined. Removing column from VideoTable.');
        % XXX Update this to remove the firstframe column from the VideoTable
    elseif ischar(firstframefiles)
        firstframefiles = dir(firstframefiles);
    elseif iscell(firstframefiles)
        for k = 1:length(firstframefiles)
            tmp(k,1) = dir(firstframefiles{k});
        end        
        firstframefiles = tmp;
    else
        error('Unknown error.');
    end
    
    % Is mipfiles a string with just a filename in it? If not, is mipfiles
    % a list of filenames embedded as a cell array? If so, get directory
    % listing for it.
    if isempty(mipfiles)
        warning('No MIP filenames defined. Removing column from VideoTable.');
        % XXX Update this to remove the mipfiles column from the VideoTable
    elseif ischar(mipfiles)
        mipfiles = dir(mipfiles);
    elseif iscell(mipfiles)
        for k = 1:length(mipfiles)
            tmp{k,1} = dir(mipfiles{k});
        end        
        mipfiles = tmp;
    else
        error('Unknown error.');
    end        
    
    % If it's an incorrectly formed structure...
    if isstruct(filelist) && ~isfield(filelist, 'name')
        error('File structure, filelist, is constructed incorrectly. Consult help for dir command.');
    elseif isstruct(firstframefiles) && ~isfield(firstframefiles, 'name')
        error('File structure, firstframefiles, is constructed incorrectly. Consult help for dir command.');
    elseif isstruct(mipfiles) && ~isfield(mipfiles, 'name')
        error('File structure, firstframefiles, is constructed incorrectly. Consult help for dir command.');
    end
    
    % The time- and length-scales for the videos MUST be defined here for the table to
    % be useful.
    if isempty(fpslist)
        error('No frames per second defined.');
    end
    
    if isempty(calibumlist)
        error('No length scale calibration defined.');
    end
    
    % If the inputs were simple scalars, assume that means the values are
    % identical for all the filenames in filelist and tile them out for the table.
    if size(fpslist,1) == 1
        fpslist = repmat(fpslist, size(filelist));
    end

    if size(calibumlist,1) == 1
        calibumlist = repmat(calibumlist, size(filelist));
    end
    
    if size(width,1) == 1
        width = repmat(width, size(filelist));
    end
    
    if size(height,1) == 1
        height = repmat(height, size(filelist));
    end
    
%     if size(X,1) == 1
%         X = repmat(X, size(filelist));
%     end
%     
%     if size(Y,1) == 1
%         Y = repmat(Y, size(filelist));
%     end
    
    % Check to make sure the length of the filename list is consistent with
    % the entered values for time- and length-scales.
    if size(filelist,1) ~= size(fpslist,1) && size(filelist,1) ~= size(calibumlist,1)
        error('The number of filenames, frame rates, and/or size-scale calibrations are not the same. Check your dimensions.');
    end
    
    % Tricky part here, dealing with the MIPs and First Frames.
    if ~isempty(mipfiles) && iscell(mipfiles) && length(mipfiles) == size(filelist,1)
        Mipfile = mipfiles;  
    elseif ~isempty(mipfiles) && ~iscell(mipfiles)
        error('MIP images are not properly structured in a cell array. Consult documentation.');
    elseif isempty(mipfiles)
        logentry('No mip defined.');
        Mipfile = [];
    end
    
    % Tricky part here, dealing with the MIPs and First Frames.
    if ~isempty(firstframefiles) && iscell(firstframefiles) && length(firstframefiles) == size(filelist,1)
        Firstframefile = firstframefiles;  
    elseif ~isempty(firstframefiles) && ~iscell(firstframefiles)
        error('First-frame images are not properly structured in a cell array. Consult documentation.');
    elseif isempty(firstframefiles)
        logentry('No first-frames defined.');
        Firstframefile = [];
    end
    
    
%     % Tricky part here, dealing with the MIPs and First Frames.
%     if ~isempty(mipfiles) && iscell(mipfiles) && length(mipfiles) == size(filelist,1)
%         Mip = mipfiles;  
%     elseif ~isempty(mipfiles) && isnumeric(mipfiles) && size(mipfiles,3) == length(filelist)
%         Mip(k,:,:) = mipfiles(:,:,k); % table wants transpose
%     elseif ~isempty(mipfiles) && ~iscell(mipfiles)
%         error('MIP images are not properly structured in a cell array. Consult documentation.');
%     elseif isempty(mipfiles)
%         logentry('No mip defined.');
%         Mip = [];
%     end
    
    % Now that all the inputs are handled...
    for k = 1:length(filelist)
        Fid(k,1) = k;
        Path{k,1} = filelist(k).folder;
        Vidfile{k,1} = 0;
        Trackfile{k,1} = filelist(k).name;
        Fps(k,1) = fpslist(k);
        Calibum(k,1) = calibumlist(k);
        Width(k,1) = width(k);
        Height(k,1) = height(k);
        Firstframefile{k,1} = 0;
        Mipfile{k,1} = 0;
    end

% Need Firstframe and mip Mip to be FILE NAMES?
filetable = table(Fid, Path, Vidfile, Trackfile, Fps, Calibum, Width, Height, Firstframefile, Mipfile);
 

return;



    