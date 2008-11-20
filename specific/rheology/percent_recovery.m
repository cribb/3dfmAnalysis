function varargout = percent_recovery(x)
% PERCENT_RECOVERY This function computes the percent recovery of the vector, x.   
%
% 3DFM function
% specific/rheology
% last modified 11/20/08 (krisford)
%  


    x = x - x(1);
    
	xrec = max(x) - x(end);    
    pct_rec = xrec / max(x) * 100;
    

    
    switch nargout
        case 1
            varargout{1} = pct_rec;
        case 2
            varargout{1} = pct_rec;
            varargout{2} = max(x);
        case 3
            varargout{1} = pct_rec;
            varargout{2} = max(x);
            varargout{3} = xrec;
    end    
    
