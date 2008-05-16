function v = ta2mat(filename)
% 3DFM function  
% Rheology/cone_and_plate 
% last modified 06-May-2008 (jcribb)
%  
% This function works to convert the textual export of rheology datasets 
% from the Ares G2 cone-and-plate (CAP) rheometer to a matlab structure.
%  
%  [output_struct] = ta2mat(filename);  
%   
%  where "filename" is the text file containing the rheology data.
%  
  

% set delimiter to be a "tab"
tab = sprintf('\t');

% check for the existence of the filename(s)
filename = dir(filename);

if isempty(filename)
    error('file not found');
end

numfiles = length(filename);

% need to add in multiple files eventually
for f = 1:numfiles
thisfile = filename(f).name;

% Lines are tab delimited with several different section types
%  1. File Header
%  2. Global procedure header
%  3. Specific procedure headers
%  4. Geometry
%  5. Rheometer Settings
%  6-n. Data Sections, with header-lines that match 
%       Specific procedure header field named, "Step name"

% sequence of events (for each parameter in each header section)
%  1. The correct line needs to be extracted. To do this, we have to
%     identify these sections' locations in the datafile.
%  2. The parameter and value need to become separated
%  3. The parameter needs to have its capital letters reduced to lower case
%     and its spaces turned to underscores


% first, determine the lengths and number of delimiters that exist per line
[ndlim, len, outl] = count_dlim(thisfile, tab);

% Lines with zero length are just whitespace.
% Lines with no delimiters can be section titles.
lines_with_no_dlim = find((ndlim == 0) & (len > 0));
header_sections = lines_with_no_dlim(1:3);
data_sections = lines_with_no_dlim(4:end);

num_data_sections = length(data_sections);
last_line = length(ndlim); % the last line in the text file

% Identify data Sections and their locations
if ~isempty('data_section_label')
    for k = 1:length(data_sections)        
        data_section_label{k} = outl{ data_sections(k) };
%         fprintf('%i \t\t %s \n', data_sections(k), data_section_label{k});
    end
end
% Parse the file, section by section.

% Section 1. File Header
% There are three main header lines with no delimiters
% 1. Rheometer Company Identifier- "TA Instruments"
% 2. filename
% 3. date/time, format MM/DD/YYYY hh:mm:ss AP
%
% For the remainder of the entire file, with the exception of labels 
% elements 1, 2, and 3 of lines_with_no_dlim contain the file header info
% elements 4:end are the boundaries between actual datasets.
if ~exist('file_header', 'var')
    file_header.rheometer_manu = outl{header_sections(1)};
    file_header.filename       = outl{header_sections(2)};
    file_header.datetime       = outl{header_sections(3)};
else
    logentry('File header already exists, not overwriting.');
end

% Section 2. Global procedure header
% - contains the general protocol that applies to all experimental data
% - Probably very stable, with standard parameter-value pairs.
% - This section starts with the parameter <Sample name>
% - This section ends with the parameter <Procedure notes>
% 
if ~exist('global_protocol', 'var')
    global_protocol = extract_parameter_value_pair(outl, 'sample name', ...
                                                         'procedure notes');
else
    logentry('Global protocol already exists, not overwriting.');
end

% Section 3: Specific procedure headers
% - Probably also very stable, but is also dynamic, with different 
%   sections for different test types.
% - very important label, "step name" matches header label 
%   in data sections.
%
% Extract the specific procedures or "step name"
steps = regexp(lower(outl), 'step name');
steploc = find(cell2num(steps) > 0);

for k = 1:length(steploc) 
    mystring = outl{steploc(k)};
    [tok,rem] = strtok(mystring, tab);
    slist{k,1} = strrep(rem, tab, '');
end

% Parse each specific procedure section for metadata
if ~exist('exps')
    
    exps = struct;

    clear foo;
    
    for k = 1:(length(slist)-1)

        % Pull the current section name from the sections list
        sname  = slist{k,1};
        sectn_start = steploc(k);
        sectn_end   = steploc(k+1)-1;

        % adjust section names to be field_name_friendly
        munged_sname = lower(sname);
        munged_sname = strrep(munged_sname, ' ', '_');
        munged_sname = strrep(munged_sname, '-', '_');

        % generate a list of section field_names (instead of labels)
        mlist{k,:} = munged_sname;

        % set the metadata structure
        metadata = extract_parameter_value_pair(outl, sectn_start, sectn_end);

        foo.metadata = metadata;
        exps = setfield(exps, munged_sname, foo);    
    end
else
    logentry('Experiment-level metadata exists, not overwriting.');
end

% Section 4. Geometry
% - contains stable parameter-value pair info on specific geometry used 
%   in the experiment.
% - starts with field <Geometry name>
% - ends with field <Approximate sample volume?
%
if ~exist('geometry', 'var');
    geometry = extract_parameter_value_pair(outl, 'geometry name', ...
                                                  'approximate sample volume');
else
    logentry('Geometry metadata already exists, not overwriting.');
end

% Section 5. Rheometer
% - Also parameter-value pairs
% - section starts with <Sample compression>
% - section ends with <Temperature tolerance>
% - there are sections within that contain data delimited by commas. These 
%   "sub-sections" should be handled as such with the parent section 
%   defined in the line immediately prior to the sub-section.
% - Subsections can be readily identified as single-tab lines with the 
%   tab located at position 1.
%
if ~exist('rheometer', 'var')
    rheometer = extract_parameter_value_pair(outl, 'sample compression', ...
                                                   'temperature tolerance');
else
    logentry('Rheometer metadata already exists, not overwriting.');
end

% Sections 6-n. Data Sections
% Start by iterating through available Data Sections
clear table;
for k = 1:num_data_sections

    section_start = data_sections(k);
    
    % determine this section's position in sections list
    p = strmatch(data_section_label{k}, slist, 'exact');
    fprintf('%s is protocol section #%i in the experimental data.\n', slist{p}, p);

    try
        section_end   = data_sections(k+1)-1;
    catch
        section_end   = last_line-2;
    end

    table_headers = outl{section_start+2};
    table_units   = outl{section_start+3};
    
    mycount = 1;
    for m = section_start+5:section_end
        foo = str2num(outl{m}); %#ok<ST2NM>
        if ~isempty(foo)
            table(mycount,:) = foo; %#ok<AGROW>
            mycount = mycount + 1;
        end                                           
    end

% %     if isfield(data_section, 'table')
% %         break;
% %     end
    
    myexp = getfield(exps, mlist{p}); %#ok<GFLD>
    
    myexp.table_headers = table_headers;
    myexp.table_units   = table_units;
    myexp.table         = table;
    
    exps = setfield(exps, mlist{p}, myexp); %#ok<SFLD>

end

end

% Finally! Wrap it up and ship it out--
v.file_header     = file_header;
v.global_protocol = global_protocol;
v.geometry        = geometry;
v.rheometer       = rheometer;
v.experiments     = exps;

return;



% blah
function out_struct = extract_parameter_value_pair(outl, startp, endp)

    tab = sprintf('\t');
    dlim = tab;
    
    out_struct = struct;    
    pcount = 1;

    if ~isnumeric(startp)
        section_start = regexp(lower(outl), startp);
        section_start = find(cell2num(section_start) > 0);
        section_start = section_start(1);
    else
        section_start = startp;
    end
    
    if ~isnumeric(endp)
        section_end   = regexp(lower(outl), endp);
        section_end   = find(cell2num(section_end) > 0);
        section_end   = section_end(end);        
    else
        section_end = endp;
    end
    
        for k = section_start : section_end

            mystring = outl{k};

            [tok,rem] = strtok(mystring, dlim);

            if isempty(rem)
                rem = tok;
                tok = ['param' num2str(pcount)];
                pcount = pcount + 1;
            end

            param = strrep(tok, dlim, '');
            value = strrep(rem, dlim, '');

            munged_param = lower(param);
            munged_param = strrep(munged_param, ' ', '_');
            munged_param = strrep(munged_param, '-', '_');
            munged_param = strrep(munged_param, '(', '');
            munged_param = strrep(munged_param, ')', '');

            if ~isempty(munged_param)
                out_struct = setfield(out_struct, munged_param, value);
            else
                break;
            end

        end

    return;

    
%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ta2mat: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return