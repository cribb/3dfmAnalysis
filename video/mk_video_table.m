function filetable = mk_video_table(filelist, fpslist, calibumlist, width, height, firstframes, mip)
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
    L = filelist;
    P = fpslist(:);
    C = calibumlist(:);
    W = width(:);
    H = height(:);
    F = firstframes(:);
    M = mip; 
    
    % Handle whether or not the filename situation is what we need. 
    
    % First, the case where there are no files defined. XXX Update this
    % such that the return is an empty table with the proper table
    % headings.
    if isempty(L)
        error('No filenames defined.');
    end

    % Is L a string with just a filename in it? If not, is L a list of 
    % filenames embedded as a cell array? If so, get directory
    % listing for it.
    if ischar(L)
        L = dir(L);
    elseif iscell(L)
        for k = 1:length(L)
            tmp(k) = dir(L{k});
        end        
        L = tmp;
    end
    
    % If it's an incorrectly formed structure...
    if isstruct(L) && ~isfield(L, 'name')
        error('File structure, L, is constructed incorrectly. Consult help for dir command.');
    end
    
    % The time- and length-scales for the videos MUST be defined here for the table to
    % be useful.
    if isempty(P)
        error('No frames per second defined.');
    end
    
    if isempty(C)
        error('No length scale calibration defined.');
    end
    
    % If the inputs were simple scalers, assume that means the values are
    % identical for all the filenames in L and tile them out for the table.
    if size(P,1) == 1
        P = repmat(P, size(L));
    end

    if size(C,1) == 1
        C = repmat(C, size(L));
    end
    
    if size(X,1) == 1
        X = repmat(X, size(L));
    end
    
    if size(Y,1) == 1
        Y = repmat(Y, size(L));
    end
    
    % Check to make sure the length of the filename list is consistent with
    % the entered values for time- and length-scales.
    if size(L,1) ~= size(P,1) && size(L,1) ~= size(C,1)
        error('The number of filenames, frame rates, and/or size-scale calibrations are not the same. Check your dimensions.');
    end
    
    % Tricky part here, dealing with the MIPs and First Frames.
    if ~isempty(M) && iscell(M) && length(M) == size(L,1)
        Mip = mip;  
    elseif ~isempty(M) && isnumeric(M) && size(M,3) == length(L)
        Mip(k,:,:) = mip(:,:,k); % table wants transpose
    elseif ~isempty(M) && ~iscell(M)
        error('MIP images are not properly structured in a cell array. Consult documentation.');
    elseif isempty(M)
        logentry('No mip defined.');
        Mip = [];
    end
    
    % Now that all the inputs are handled...
    for k = 1:length(filelist)
        Fid(k,1) = k;
        Path{k,1} = 0;
        Vidfile{k,1} = 0;
        Trackfile{k,1} = 0;
        Fps(k,1) = P(k);
        Calibum(k,1) = C(k);
        Width(k,1) = 0;
        Height(k,1) = 0;
    end


filetable = table(Fid, Path, Vidfile, Trackfile, Fps, Calibum, Width, Height, Firstframe, Mip);
 

return;



    