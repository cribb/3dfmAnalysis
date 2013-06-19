function outs = get_TA_col(s, str, unt)
% last modified 3/1/2013 (cribb)

    [headers, units] = get_TA_column_headers(s);
    
    list = [headers,units];
    
    if isempty(unt)
        outs = find( strcmp(str, list(:,1)) );
    else
        outs = find(strcmp(str, list(:,1)) & strcmp(unt, list(:,2)) );
    end

        % to account for the case (that actually happens with TA datafiles)
        % where a column is repeated.
%         outs = outs(1);
    return;