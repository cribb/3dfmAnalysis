function [headers, units]= get_TA_column_headers(s,t)
% last modified 3/13/2013 (cribb)


    dlim = sprintf('\t'); %the 'tab' is the delimiter here.
          
    if nargin < 2 || isstruct(s)
        th = s.table_headers;
        un = s.table_units;        
    else
        th = s;
        un = t;
    end
            
% %     % sanitize table headers and units
% %     th = strrep(th, '|G*|.sin(delta)', 'Gstar_times_sin_delta');
% %     th = strrep(th, '|G*|/sin(delta)', 'Gstar_over_sin_delta');
% %     th = strrep(th, '|G*|', 'G_star');
% %     th = strrep(th, '|J*|', 'J_star');
% %     th = strrep(th, 'ang. frequency', 'ang__frequency');
% %     th = strrep(th, 'G''''', 'G_double_prime');
% %     th = strrep(th, 'G''', 'G_prime');
% %     th = strrep(th, 'osc. stress', 'osc_stress');

    
        
    q = regexp(th, dlim);
    v = regexp(un, dlim);

% Create an indexed list of table headers
    for k = 1:length(q)+1
        if k == 1
            headers{k,1} = strtrim( th( 1:q(k) ) ); %#ok<AGROW>
            disp('1');
        elseif k > 1 && k <= length(q)
            headers{k,1} = strtrim( th( q(k-1):q(k) ) ); %#ok<AGROW>
            disp('2');          
        elseif k > length(q)
            headers{k,1} = strtrim( th( q(k-1):end ) ); %#ok<AGROW>
            disp('3');
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