function save_evtfile(filename, tracking_in, xyzunits, calib_um, fps, outtype)
% SAVE_EVTFILE saves tracking data to the evt.vrpn.mat format 
%
% 3DFM function
% video
%
% This function saves tracking data (eg. from simulations, etc) to the
% evt.vrpn.mat format used in EVT_GUI.  This format retains the length scale
% calibration information provided in the function call as a field in the
% evt data structure (tracking.calib_um).
%
% [outfile] = save_evtfile(filename, data, xyzunits, calib_um)
%
% where "outfile" is the filename where save_evtfile saved the data.
%       "filename" is the filename where save_evtfile will save the data. 
%       "data" is a table of tracking data used in video_spot_tracker.  The
%              column id's can be found in the 'video_tracking_constants'
%              file, but are typically in this order: TIME, FRAME, ID, X,
%              Y, Z, ROLL, PITCH, YAW.
%       "xyzunits" defines the length scale units used in the "data" input,
%                  which can be 'm' (meters), 'um', 'nm', or 'pixels'
%       "calib_um" defines the length scale calibration in [um/pixel]
%       "fps"
%       "outtype" is a string that defines the output evt filetype, either 'mat' or 'csv'
%

    video_tracking_constants;
    
    if nargin < 6 || isempty(outtype)
        outtype = 'mat';
    end
    if nargin < 5 || isempty(fps)
        fps = NaN;
    end
    
    if nargin < 4 || isempty(calib_um)
        calib_um = NaN;
    end
 
   if istable(tracking_in)
        data = convert_TrackingTable_to_old_matrix(tracking_in, fps);
        myinfo = NaN;
   end
    
    if isstruct(tracking_in)
        data = tracking_in.spot3DSecUsecIndexFramenumXYZRPY;
        if isfield(tracking_in, 'info')
            myinfo = tracking_in.info;
        else
            myinfo = NaN;
        end
    elseif isnumeric(tracking_in)
        data = tracking_in;
        myinfo = NaN;
    end
          

    
    if isempty(data)
        logentry('Saving empty dataset.');
        data = NULLTRACK;    
    elseif strcmp(xyzunits,'m')
		data(:,X:Z) = data(:,X:Z) ./ calib_um * 1e6;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'um')
		data(:,X:Z) = data(:,X:Z) ./ calib_um;  % convert video coords from pixels to meters
    elseif strcmp(xyzunits,'nm')
		data(:,X:Z) = data(:,X:Z) ./ calib_um * 1e-3;  % convert video coords from pixels to nm
    elseif strcmp(xyzunits, 'pixel')
        % do nothing
    else
        units{X} = 'pixels';  units{Y} = 'pixels';  units{Z} = 'pixels';
    end
        
    switch outtype
        case 'mat'
            save_matfile(filename, data, fps, calib_um, myinfo);            
        case 'csv'
            save_csvfile(data, filename);
        otherwise
            error('Incorrect filetype specified for output filename.');
    end
    
return;


function outs = save_matfile(filename, data, fps, calib_um, myinfo)

    video_tracking_constants;
    
    tracking.spot3DSecUsecIndexFramenumXYZRPY = data;
    tracking.info = myinfo;
    tracking.calib_um = calib_um;       
    tracking.fps      = fps;

    filename = strrep(filename, '.vrpn', '');
    filename = strrep(filename, '.evt', '');
    filename = strrep(filename, '.mat', '');
    filename = strrep(filename, '.csv', '');    
    outfile = [filename '.vrpn.evt.mat'];

    save(outfile, 'tracking');  

    logentry(['Saved ' num2str(length(unique(data(:,ID)))) ' trackers in ' outfile]);
    
    outs = 0;
    
    return;

    
function outs = save_csvfile(data, filename)

     video_tracking_constants;
     
     CSVFRAME  = 1;
     CSVID     = 2;
     CSVX      = 3;
     CSVY      = 4;
     CSVZ      = 5;
     CSVRADIUS = 6;
     CSVCENTINTS = 7;
     CSVORIENT = 8;
     CSVLENGTH = 9;
     CSVFIT    = 10;
     CSVGAUSS  = 11;
     CSVMEAN   = 12;
     CSVSUMMED = 13;
     CSVAREA   = 14;
     CSVSENS   = 15;
     CSVFORE   = 16;

     dummyzeros = zeros(size(data,1),1);

     csv_data(:,CSVFRAME)    = data(:, FRAME);
     csv_data(:,CSVID)       = data(:, ID);
     csv_data(:,CSVX)        = data(:, X);
     csv_data(:,CSVY)        = data(:, Y);
     csv_data(:,CSVZ)        = data(:, Z);
     csv_data(:,CSVRADIUS)   = dummyzeros;
     csv_data(:,CSVCENTINTS) = dummyzeros; 
     csv_data(:,CSVORIENT)   = dummyzeros; 
     csv_data(:,CSVLENGTH)   = dummyzeros; 
     csv_data(:,CSVFIT)      = dummyzeros; 
     csv_data(:,CSVGAUSS)    = dummyzeros; 
     csv_data(:,CSVMEAN)     = dummyzeros; 
     csv_data(:,CSVSUMMED)   = dummyzeros; 
    if size(data,2) < CSVAREA
         csv_data(:,CSVAREA) = dummyzeros;
    else
         csv_data(:,CSVAREA)     = data(:, AREA);
    end

    if size(data,2) < CSVSENS
        csv_data(:,CSVSENS)     = dummyzeros;
    else
        csv_data(:,CSVSENS)     = data(:, SENS);
    end


    if size(data,2) < CSVFORE
        csv_data(:,CSVFORE)     = dummyzeros;
    else
        csv_data(:,CSVFORE)     = data(:, SENS);
    end

     csv_header = { 'FrameNumber' ...
                    'Spot ID' ...
                    'X' ...
                    'Y' ...
                    'Z' ...
                    'Radius' ...
                    'Center Intensity' ...
                    'Orientation (if meaningful)' ...
                    'Length (if meaningful)' ...
                    'Fit Background (for FIONA)' ...
                    'Gaussian Summed Value (for FIONA)' ...
                    'Mean Background (FIONA)' ...
                    'Summed Value (for FIONA)' ...
                    'Region Size' ...
                    'Sensitivity' ...
                    'Foreground Size'};

    filename = strrep(filename, '.vrpn', '');
    filename = strrep(filename, '.evt', '');
    filename = strrep(filename, '.mat', '');
    filename = strrep(filename, '.csv', '');    
    outfile = [filename '.evt.csv'];

    fid = fopen(outfile, 'w');
    fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',csv_header{:});
    fclose(fid);
    
%     if ~isempty(csv_data) &&  length(csv_data(:)) ~= sum(isnan(csv_data(:)))
    if size(csv_data,1) > 1 && ~isnan(csv_data(1,X))
        dlmwrite(outfile, csv_data, '-append', 'delimiter', ',', 'precision', '%10.5f');
    else
        logentry('No data to save.');
    end

    logentry(['Saved ' num2str(length(unique(data(:,ID)))) ' trackers in ' outfile]);
    
    outs = 0;
    
    return;
    
    
    