function pr = dmbr_percent_recovery(table)
% 3DFM function   
% Rheology
% last modified 03/21/08 (jcribb)
%  

    dmbr_constants;

                       
    ct = table(:,J);

    if ~isempty(ct)
        pr = percent_recovery(ct);
    else
        pr = NaN;
    end
            

return;
