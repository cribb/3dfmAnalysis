function varargout = percent_recovery(x)
% 3DFM function  
% Rheology 
% last modified 08/10/05 (jcribb)
%  
% This function computes the percent recovery of the vector, x.
%  
%  [pct_rec, xmax, xrec] = percent_recovery(x);
%   
%  07/16/05 - created (jcribb) 
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
    