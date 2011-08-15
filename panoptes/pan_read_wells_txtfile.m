function outs = pan_read_wells_txtfile( wellsfile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% set delimiter to be a "space"
dlim = ' ';
cmntstr = '//';

if ~isempty(dir(wellsfile))
    [ndlim, len, outl] = count_dlim(wellsfile, dlim, cmntstr);
else
    error('file not found');
end

% Finding the EOF section and shifting everything beneath that immediately
% to comments field.
EOFlocs = strfind(outl, 'EOF');
for k = 1:length(EOFlocs)
    if EOFlocs{k} == 1
        end_of_wells = k;
    end
end
outs.comments = outl(end_of_wells+1:end);

% eliminate comments section of the wells.txt file
outl = outl(1:end_of_wells-1);
ndlim = ndlim(1:end_of_wells-1);

% beginning of wells section
WELLSlocs = strfind(outl, 'wells');
for k = 1:length(WELLSlocs)
    if WELLSlocs{k} == 1
        beg_of_wells = k+1;
    end
end

outs.well_list = str2num(char(outl(beg_of_wells:end)));
outs.well_list = outs.well_list(:)';

% eliminate "wells" section of the wells.txt file
outl = outl(1:beg_of_wells-2);
ndlim = ndlim(1:beg_of_wells-2);

% eliminate empty lines
idx = find(ndlim < 1);
outl(idx) = [];
ndlim(idx) = [];

% Handle a random number of offsets in the "offsets" section
count = 1;
OFFSETSlocs = strfind(outl, 'offset');
% offset_lines = [];
for k = 1:length(OFFSETSlocs)
    if ~isempty(OFFSETSlocs{k})
        [str myoffset] = strtok(outl{k}, dlim);
        offsets(count,:) = str2num(myoffset);
        if count == 1
            beg_offsets = k;
        end
        count = count + 1;
    end
end
outs.offsets = offsets;

outl = outl(1:beg_offsets-1);
ndlim = ndlim(1:beg_offsets-1);

% everything else should just be a parameter/value pair
for k = 1:length(outl)
    [fieldname, value] = strtok(outl, dlim);
end

value = strtrim(value);

for k = 1:length(fieldname)
    if sum(regexp(value{k}, '[0-9]')) > 0 && sum(regexp(upper(value{k}), '[A-Z]')) == 0
        outs.(fieldname{k}) = str2num(value{k});
    else
        outs.(fieldname{k}) = value{k};        
    end
end

return;


