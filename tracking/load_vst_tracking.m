function [v, calout] = load_vst_tracking(filelist, fpslist, calibumlist)


% new_video_tracking_constants;

% handle the argument list
[filelist, fpslist, calibumlist] = process_inputs(filelist, fpslist, calibumlist);

% check for proper filepath
orig_directory = pwd;

% We need to handle the case that an absolute filename is used (complete 
% with path). I've put this into a try:catch block because matlab's fileparts 
% requires a char array for input and dir outputs a struct. If dir is used
% then there won't be any path information anyway. And if there's no path
% on the input then it won't hurt anything.
try
    [pathstr, name, ext] = fileparts(filelist); %#ok<ASGLU>
catch
end

if exist('pathstr', 'var') && ~isempty(pathstr)
    cd(pathstr);
end
% 
% if length(filelist) < 1
%     logentry(['No files found matching ' filelist ', returning empty set.']);
%     v = NULLTRACK;
%     calout = NaN;
%     return;
% end


% Now, for every file...
filetable = table;
trajtable = table;
for fid = 1:length(filelist)
    
    file = filelist(fid).name;    
    
    filetable(fid).fid = fid;
    filetable(fid).path = pwd;
    filetable(fid).name = file;
    filetable(fid).height = height;
    filetable(fid).width = width;
    filetable(fid).xloc  = xloc;
    filetable(fid).yloc  = yloc;
    filetable(fid).fps   = fps;
    filetable(fid).calibum = calibum;
    filetable(fid).mip  = mip;
    
    % construct entry into file id table
    
    % Handle the incoming data for whatever type it is...
    % First, check if it's a csv file
    dd = readtable(file);

    Fid = repmat(fid, size(dd,1), 1);
    tmpfidtable = table(Fid);        

    % rename the headers to something more easily coded/read
    dd.Properties.VariableNames{'FrameNumber'} = 'Frame';
    dd.Properties.VariableNames{'SpotID'}      = 'ID';

    % Z data and remaining values are nonexistant (These can be added back if needed in a
    % later version
    dd.Z = [];
    dd.Orientation_ifMeaningful_ = [];
    dd.Length_ifMeaningful_ = [];
    dd.FitBackground_forFIONA_ = [];
    dd.GaussianSummedValue_forFIONA_ = [];
    dd.MeanBackground_FIONA_ = [];
    dd.SummedValue_forFIONA_ = [];


    dd = [tmpfidtable dd];
end

trajtable = [trajtable;dd];


trajtable.Properties.VariableUnits = {'', '', '', 'pixels', 'pixels', 'pixels', 'Intensity-16-bit', 'pixels^2', '', 'pixels^2'};
    
        

    
    

    logentry(['Loaded *' filelist(fid).name '* which contains ' num2str(max(data(:,ID))) ' initial trackers.']);
    
    % now do all of the bead specific things
    IDlist = unique(trackerID)';
    for k = 1 : length(IDlist)
        
        % select rows in table that correspond only to the k-th bead
        idx = find(trackerID == IDlist(k));
        this_tracker  = data(idx,:);
        
        % handle the case for which a trackerID was used, but no points
        % were retained in the dataset.
        if(isempty(this_tracker)); 
            continue;
        end;

        % select x&y coords for only the kth bead
        this_x = x(idx);
        this_y = y(idx);

        


    end


    
end






% now, settle our outputs, and move on....
if ~isempty(data)
    switch table
        case 'table'
            v = data;
        otherwise
            v.id= data(:,ID);    
            v.t = data(:,TIME);
            v.frame = data(:,FRAME);
            v.x = data(:,X);
            v.y = data(:,Y);
            v.z = data(:,Z);		
            if exist('AREA');    v.area = data(:,AREA);    end;
            if exist('SENS');    v.sens = data(:,SENS);    end;
            if exist('CENTINTS');v.centints = data(:,CENTINTS);  end;           

    end
else
    v = NULLTRACK;
end 
    
    cd(orig_directory);
return;




function data = convert_csv(dd)
    video_tracking_constants;

    CSVFRAME = 1;
    CSVID    = 2;
    CSVX     = 3;
    CSVY     = 4;
    CSVZ     = 5;

    if size(dd,2) >= 7
        CSVCENTINTS = 7;
    end
    
    if size(dd,2) >= 14
        CSVAREA = 14;
    end

    if size(dd,2) >= 15
        CSVSENS = 15;
    end

    data(:,TIME)  = zeros(rows(dd),1);
    data(:,FRAME) = dd(:,CSVFRAME);
    data(:,ID)    = dd(:,CSVID);
    data(:,X)     = dd(:,CSVX);
    data(:,Y)     = dd(:,CSVY);
    data(:,Z)     = dd(:,CSVZ);
    data(:,ROLL)  = zeros(rows(dd),1);
    data(:,PITCH) = zeros(rows(dd),1);
    data(:,YAW)   = zeros(rows(dd),1);

    if size(dd,2) >= 7
        data(:,CENTINTS) = dd(:,CSVCENTINTS);
    else
        data(:,CENTINTS) = 0;
    end    
        
    if size(dd,2) >= 14
        data(:,AREA) = dd(:,CSVAREA);
    else
        data(:,AREA) = 0;
    end

    if size(dd,2) >= 15
        data(:,SENS) = dd(:,CSVSENS);
    else
        data(:,SENS) = 0;
    end
        
    return;
    
    
function data = convert_videoTrackingSecUsecZeroXYZ(dd)
    video_tracking_constants; 

    data = dd.tracking.videoTrackingSecUsecZeroXYZ;

    data = axe_vrpn_timestamps(data);


    % set up variables for easy tracking of table's column headings
    myTIME = 1; myID = 2; myX = 3; myY = 4; myZ = 5; 

    data(:,TIME) = data(:,myTIME);
    data(:,ID)   = data(:,myID);
    data(:,FRAME)= 1:rows(data);
    data(:,X)    = data(:,myX);
    data(:,Y)    = data(:,myY);
    data(:,Z)    = data(:,myZ);
    data(:,ROLL) = zeros(rows(data),1);
    data(:,PITCH) = zeros(rows(data),1);
    data(:,YAW) = zeros(rows(data),1);
    
    return;
    
function data = convert_spot2DSecUsecIndexXYZ(dd)
        
    video_tracking_constants;
    mydata = dd.tracking.spot2DSecUsecIndexXYZ;

    % Let's axe the VRPN "time-stamps"... they don't mean anything here
    mydata(:,2) = zeros(size(mydata, 1),1);  
    mydata = mydata(:,2:end);

    video_tracking_constants; 

    % set up variables for easy tracking of table's column headings
    myTIME = 1; myID = 2; myX = 3; myY = 4; myZ = 5; 

    data(:,TIME) = mydata(:,myTIME);
    data(:,ID)   = mydata(:,myID);
    data(:,FRAME)= zeros(rows(mydata),1);
    data(:,X)    = mydata(:,myX);
    data(:,Y)    = mydata(:,myY);
    data(:,Z)    = mydata(:,myZ);
    data(:,ROLL) = zeros(rows(mydata),1);
    data(:,PITCH) = zeros(rows(mydata),1);
    data(:,YAW) = zeros(rows(mydata),1);
    
    return;

