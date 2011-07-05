function outs = get_TA_col(s, str, unt)
    if nargin < 3
        unt = '';
    end
    
    dlim = sprintf('\t'); %the 'tab' is the delimiter here.
    th = s.table_headers;
    un = s.table_units;
    
    p = regexp(th, str);
    q = regexp(th, dlim);
    
    u = regexp(un, unt);
    v = regexp(un, dlim);
    
    % Create an indexed list of table headers
    for k = 1:length(q)
        if k == 1
            headers{k,1} = strtrim( th( 1:q(k) ) );
        else
            headers{k,1} = strtrim( th( q(k-1):q(k) ) );
        end
    end
    
    % Create an indexed list of units for each header.
    for k = 1:length(v)
        if k == 1
            units{k,1} = strtrim( un( 1:v(k) ) );
        else
            units{k,1} = strtrim( un( v(k-1):v(k) ) );
        end
    end

    list = [headers,units];
    
    if isempty(unt)
        outs = find( strcmp(str, list(:,1)) );
    else
        outs = find(strcmp(str, list(:,1)) & strcmp(unt, list(:,2)) );
    end

        % to account for the case (that actually happens with TA datafiles)
        % where a column is repeated.
        outs = outs(1);
    return;