function filetable = vst_mk_file_table(filelist, fpslist, calibumlist, width, height, firstframes, mip)
% This function helps the user assemble the file structure/table necessary
% to do tracking/trajectory analysis. It's a harsh taskmaster, because
% everything must be in the proper form in order to function properly as a
% database. Where assumptions can be made, this function makes them.
% Otherwise, you must provide the correct information.
%
% mip is a cell array with the mip-image as a 2-D array in each cell array
% location.

    % handle the inputs    
    F = filelist;
    P = fpslist(:);
    C = calibumlist(:);
    W = width(:);
    H = height(:);
    M = mip; 
    
    % Handle whether or not the filename situation is what we need. 
    
    % First, the case where there are no files defined. XXX Update this
    % such that the return is an empty table with the proper table
    % headings.
    if isempty(F)
        error('No filenames defined.');
    end

    % Is F a string with just a filename in it? If not, is F a list of 
    % filenames embedded as a cell array? If so, get directory
    % listing for it.
    if ischar(F)
        F = dir(F);
    elseif iscell(F)
        for k = 1:length(F)
            tmp(k) = dir(F{k});
        end        
        F = tmp;
    end
    
    % If it's an incorrectly formed structure...
    if isstruct(F) && ~isfield(F, 'name')
        error('File structure, F, is constructed incorrectly. Consult help for dir command.');
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
    % identical for all the filenames in F and tile them out for the table.
    if size(P,1) == 1
        P = repmat(P, size(F));
    end

    if size(C,1) == 1
        C = repmat(C, size(F));
    end
    
    if size(X,1) == 1
        X = repmat(X, size(F));
    end
    
    if size(Y,1) == 1
        Y = repmat(Y, size(F));
    end
    
    % Check to make sure the length of the filename list is consistent with
    % the entered values for time- and length-scales.
    if size(F,1) ~= size(P,1) && size(F,1) ~= size(C,1)
        error('The number of filenames, frame rates, and/or size-scale calibrations are not the same. Check your dimensions.');
    end
    
    % Tricky part here, dealing with the MIPs and First Frames.
    if ~isempty(M) && iscell(M) && length(M) == size(F,1)
        Mip = mip;  
    elseif ~isempty(M) && isnumeric(M) && size(M,3) == length(F)
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



    