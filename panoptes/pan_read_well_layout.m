function outs = pan_read_well_layout( csvfile , plate_type )
% PAN_WELL_LAYOUT_TO_STRUCT convers a well layout CSV file for Panoptes to a matlab structure.
%   
%  outs = pan_well_layout_to_struct( csvfile , plate_type )
%
%  where "csvfile" defines the file that contains the well layout
%  information from the Well_Layout interface for PanopticNerve.  The
%  plate_type can be either '96well' or '384well'.
%



switch plate_type
    case '96well'
        plate_length = 96;
    case '384well'
        plate_length = 384;
    otherwise
        error('Unknown plate type.');
end

% set delimiter to be a comma
dlim = sprintf(',');

fname_root = csvfile(1:end-4);
fname_root = strrep(fname_root, '*', '');

% COLUMN headings for well_layout.csv
ROW = 1;
COL = 2;
WELLID = 3;
OBJID = 4;
OBJNAME = 5;
FIELDNAME = 6;
VALUE = 7;

% check for the existence of the filename(s)
fname = dir(csvfile);


if ~isempty(fname)
    fid = fopen(fname.name);
else
    error('file not found');
    % trying to use this in counting instances in the file or just operating on the file
    % already opened
end

[ndlim, len, outl] = count_dlim(fname.name, dlim);

numcols = ndlim(1) + 1;

% extract out each column
for m = 1:numcols
    [coldata, outl] = strtok(outl, dlim);    
    datatable(:,m) = coldata;
end
    
% pull out column headings
tabheader = strtrim(datatable(1,:));

% remove column headings from data table
datatable = datatable(2:end,:);

% remove any data labels that have no data
values = datatable(:,VALUE);
vidx = ~cellfun('isempty', values);

% datatable = datatable(vidx,:);

wellID_data = str2double(datatable(:,WELLID));
objID_data = str2double(datatable(:,OBJID));

% datatable = sortrows(datatable, WELLID);

% how many different objects do we have
objids = unique(objID_data)';
objnamelist = unique(datatable(:, OBJNAME));

% bind objID to objName
for k = 1:length(objids)
    idx = find( objID_data == objids(k) );
    objname(k) = unique( datatable(idx, OBJNAME) )';
end

q.well_map = repmat(cellstr(''), 96, 1);

welllist = unique(wellID_data(vidx));

q.well_map(welllist) = cellstr(num2str(welllist));

% A limited number of object names (or object types) exist in the
% WELL_LAYOUT csv file. More than one instance of each object name can
% exist in a file (e.g. more than one celltype or additive solution could
% exist in a well). We have to separate the name/type of the object from
% the instance of the object. In other words, one object type might have
% more than one object id in the file.
for k = 1:length(objids)
    myobj_name = objname{k};
    
    if isfield(q, myobj_name)        
        index = length(getfield(q,myobj_name))+1;
    else
        index = 1;
    end
    
    kidx = find(objID_data == objids(k));
    fnames = unique( datatable(kidx, FIELDNAME) )';
    
    for m = 1:length(fnames)

        foo = strcmp(datatable(:,FIELDNAME), fnames(m));
        midx = find( str2double(datatable(:,OBJID)) == objids(k)  & foo);
        
        tmp = values(midx);
        q.(objname{k})(index).(fnames{m}) = tmp(:);
    end        
end

fclose(fid);

outs = q;

return;

