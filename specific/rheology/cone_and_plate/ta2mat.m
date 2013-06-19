function v = ta2mat(filename, savemat)
% TA2MAT converts textual export of rheology datasets from the Ares G2 cone-and-plate rheometer to a matlab structure
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 5/15/2013 (cribb)
%  
% This function works to convert the textual export of rheology datasets 
% from the Ares G2 cone-and-plate (CAP) rheometer to a matlab structure.
%  
%  [output_struct] = ta2mat(filename, savemat);  
%   
%  where "filename" is the text file containing the rheology data.
%        'savemat' is either 'y' or 'n', where 'y' indicates saving the new
%                  structure as a cap.mat file.
%  

if nargin < 2 || isempty(savemat)
    savemat = 'n';
end

% set delimiter to be a "tab"
tab = sprintf('\t');

filename_root = filename(1:end-4);
filename_root = strrep(filename_root, '*', '');

% check for the existence of the filename(s)
filename = dir(filename);

if isempty(filename)
    error('file not found');
end

numfiles = length(filename);

% need to add in multiple files eventually
for f = 1:numfiles
    thisfile = filename(f).name;
    thisfile_root = thisfile(1:end-4);

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
    if ~exist('protocols')
        protocols = struct;
    end

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
            munged_sname = strrep(munged_sname, ',', '');
            munged_sname = strrep(munged_sname, '%', 'pct');
            
            % generate a list of section field_names (instead of labels)
            mlist{k,:} = munged_sname;

            % set the metadata structure
            metadata = extract_parameter_value_pair(outl, sectn_start, sectn_end);
            
            if ~isfield(protocols, munged_sname)
%                 foo.metadata = metadata;
                protocols = setfield(protocols, munged_sname, metadata);    
            else
% %                 if isfield(getfield(protocols, munged_sname), 'units')
% %                     logentry('Experiment-level metadata exists, not overwriting.');
% %                 else
% % %                     foo.metadata = metadata;
% %                     protocols = setfield(protocols, munged_sname, metadata);   
% % %                     logentry('YAYYYYYYYYYYYYYYYYYYYYY!');
                end
            end

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

    %
    % Sections 6-n. Data Sections
    % Start by iterating through available Data Sections
    %
    
    for k = 1:num_data_sections

        section_start = data_sections(k);

        % determine this section's position in sections list
        p = strmatch(data_section_label{k}, slist, 'exact');
        fprintf('%s is protocol section #%i in the experimental data.\n', slist{p}, p);

%         try
%             myexp = getfield(exps, mlist{p}); %#ok<GFLD>
%         catch
%             logentry('Data section label was rewritten.  Do not know how to handle it.  Breaking out.');
%             break;
%         end
% 
%         if isfield(myexp, 'table')
%             logentry('Avoiding overwrite to datatable.  Breaking out.');
%             break;
%         end

        try
            section_end   = data_sections(k+1)-1;
        catch
            section_end   = last_line-1;
        end

        table_headers = outl{section_start+2};
        table_units   = outl{section_start+3};

        [table_headers, table_units]= get_TA_column_headers(table_headers,table_units);
        
        mycount = 1;
        for m = section_start+5:section_end
            foo = str2num(outl{m}); %#ok<ST2NM>
            if ~isempty(foo)
                table(mycount,:) = foo; %#ok<AGROW>                               
                mycount = mycount + 1;
            end                                           
        end
        
        if ~exist('data', 'var')
            data = struct; 
            units = struct;
        end
        
        if ~exist('results', 'var')
            results = struct;
        end
        
        oldvar = data;
        
        for u = 1:length(table_units);
            if ~isfield(data, table_headers{u})
                data = setfield(data, table_headers{u}, table(:,u));
            else %if strcmp(table_units{u}, oldvar.
                data = setfield(data, [table_headers{u} '_' mygenvarname(table_units{u})], table(:,u));
                logentry(['Almost clobbered the ' table_headers{u} ' data column']);
            end
                
            units = setfield(units, table_headers{u}, table_units{u});
        end
        
        temp.data = data;
        temp.units = units;
                
        results = setfield(results, mlist{p}, temp);    

        clear('table', 'data', 'units');

end

% Finally! Wrap it up and ship it out--
v.file_header     = file_header;
v.global_protocol = global_protocol;
v.geometry        = geometry;
v.rheometer       = rheometer;
v.protocols       = protocols;
v.results         = results;

if findstr(savemat, 'y')
    savefile = [filename_root '.cap.mat'];
    save(savefile, '-struct', 'v');    
end


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

function [headers, units]= get_TA_column_headers(s,t)
    
    dlim = sprintf('\t'); %the 'tab' is the delimiter here.
          
    if nargin < 2 || isstruct(s)
        th = s.table_headers;
        un = s.table_units;        
    else
        th = s;
        un = t;
    end
            
    % sanitize table headers and units
    th = strrep(th, '|G*|.sin(delta)', 'Gstar_times_sin_delta');
    th = strrep(th, '|G*|/sin(delta)', 'Gstar_over_sin_delta');
    th = strrep(th, '|G*|.time', 'Gstar_times_time');
    th = strrep(th, '|G*|', 'Gstar');
    th = strrep(th, '|J*|', 'Jstar');
    th = strrep(th, 'modulus G(t)', 'modulus_Gt');
    th = strrep(th, 'ang. frequency', 'ang_frequency');
    th = strrep(th, 'G''''', 'G_double_prime');
    th = strrep(th, 'G''', 'G_prime');
    th = strrep(th, 'J''''', 'J_double_prime');
    th = strrep(th, 'J''', 'J_prime');
    th = strrep(th, 'n''''', 'n_double_prime');
    th = strrep(th, 'n''', 'n_prime');
    th = strrep(th, '|n*|', 'nstar');
    th = strrep(th, 'osc. stress (sample)', 'osc_stress_sample');
    th = strrep(th, '% strain (sample)', 'percent_strain_sample');
    th = strrep(th, '% strain', 'percent_strain');
    th = strrep(th, 'strain (sample)', 'strain_sample');
    th = strrep(th, 'tan(delta)', 'tan_delta');
    th = strrep(th, 'osc. stress', 'osc_stress');
    th = strrep(th, 'osc. torque', 'osc_torque');
    th = strrep(th, '1/temperature', 'one_over_temperature');
    th = strrep(th, 'compliance J(t)', 'compliance_Jt');
    th = strrep(th, ' ', '_');
    th = strrep(th, ',', '');
    
    q = regexp(th, dlim);
    v = regexp(un, dlim);

    % Create an indexed list of table headers
    for k = 1:length(q)+1
        if k == 1
            headers{k,1} = strtrim( th( 1:q(k) ) ); %#ok<AGROW>
%             disp('1');
        elseif k > 1 && k <= length(q)
            headers{k,1} = strtrim( th( q(k-1):q(k) ) ); %#ok<AGROW>
%             disp('2');          
        elseif k > length(q)
            headers{k,1} = strtrim( th( q(k-1):end ) ); %#ok<AGROW>
%             disp('3');
        end
    end
   
    % Create an indexed list of units for each header.
    for k = 1:length(v)+1
        if k == 1
            units{k,1} = strtrim( un( 1:v(k) ) ); %#ok<AGROW>
        elseif k > 1 && k <= length(v)
            units{k,1} = strtrim( un( v(k-1):v(k) ) ); %#ok<AGROW>
        elseif k > length(v)
            units{k,1} = strtrim( un( v(k-1):end ) ); %#ok<AGROW>
        end
    end

    list = [headers,units];
    
% %     if isempty(unt)
% %         outs = find( strcmp(str, list(:,1)) );
% %     else
% %         outs = find(strcmp(str, list(:,1)) & strcmp(unt, list(:,2)) );
% %     end
% % 
% %         % to account for the case (that actually happens with TA datafiles)
% %         % where a column is repeated.
% %         outs = outs(1);
    return;
    
    
% Prints out a log message complete with timestamp.
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
