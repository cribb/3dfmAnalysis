function varargout = msd(t, data, window)
% MSD computes the mean-square displacements (via the Stokes-Einstein relation) for a single bead
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
%  
% [tau, msd] = msd(t, data, window);   
%
% where "t" is the time
%       "data" is the input matrix of data
%       "window" is a vector containing window sizes of tau when computing MSD. 
%
% Notes: - No arguments will run a 2D msd on all .mat files in the current
%          directory and use default window sizes.
%        - Use empty matrices to substitute default values.
%        - default window = [1 2 5 10 20 50 100 200 500 1000]
%
% [tau, msd, r2out] = msd

%initializing arguments
if (nargin < 3) || isempty(window)  
    window = [1 2 5 10 20 50 100 200 500 1000 1001]; 
end;

if (nargin < 1) || isempty(t) || isempty(data)
    logentry('Input data needed, returning empty set'); 
    tau        = NaN(length(window),1);
    msd        = NaN(length(window),1);
    Nestimates = NaN(length(window),1);
end;


% for every window size (or tau)
warning('off', 'MATLAB:divideByZero');

% preinitialize all output variables to maintain sizein == sizeout
tau        = NaN(length(window),1);
msd        = NaN(length(window),1);
Nestimates = NaN(length(window),1);

if nargout == 4
    r2out = NaN(length(window),1);
end
    
    Rout = NaN(size(data,1),size(data,2),length(window));
    numpoints = size(data,1);

    if numpoints == 1
        logentry('Insufficient points to compute any MSD value');
        varargout{1} = tau;
        varargout{2} = msd;
        varargout{3} = Nestimates;
        if nargout == 4
            varargout{4} = r2out;        
        end
        return;
    end
    
    % set tau early according to average time step 
    tau = window * mean(diff(t));
    
    for w = 1:length(window)
    
        if isnan(window(w))
            continue;
        end
        
      % for x,y,z (k = 1,2,3) directions  
      for k = 1:cols(data)
  
        % for all frames
        A = data(1:end-window(w), k);
        B = data(window(w)+1:end, k);
    
        r = (B - A);
        % var_r = sum((mean(r) - r).^2) / size(r,1);
        
        if k == 1
            r2 = r.^2;
            n = size(B,1);
        elseif k > 1
            r2 = r2 + r.^2;
            n = n + size(B,1);
        end
        
        if nargout == 4
            Rout(1:size(r,1),k,w) = r;
        end
      end
      
        
        msd(w, :)        = mean(r2);
        Nestimates(w, :) = n;        

    end

    varargout{1} = tau;
    varargout{2} = msd;
    varargout{3} = Nestimates;
    if nargout == 4
        varargout{4} = Rout;
    end
    
warning('on', 'MATLAB:divideByZero');

return;



% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  