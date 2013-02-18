function [headers, units]= get_TA_column_headers(s)
    
    dlim = sprintf('\t'); %the 'tab' is the delimiter here.
    th = s.table_headers;
    un = s.table_units;
    
    q = regexp(th, dlim);
    v = regexp(un, dlim);
    
    % Create an indexed list of table headers
    for k = 1:length(q)
        if k == 1
            headers{k,1} = strtrim( th( 1:q(k) ) );
        elseif k > 1 && k < length(q)
            headers{k,1} = strtrim( th( q(k-1):q(k) ) );
        elseif k == length(q)
            headers{k+1,1} = strtrim( th( q(k):end ) );
        end
    end
    
    % Create an indexed list of units for each header.
    for k = 1:length(v)
        if k == 1
            units{k,1} = strtrim( un( 1:v(k) ) );
        elseif k > 1 && k < length(v)
            units{k,1} = strtrim( un( v(k-1):v(k) ) );
        elseif k == length(v)
            units{k+1,1} = strtrim( un( v(k):end ) );
        end
    end
% % 
% %     list = [headers,units]
% %     
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