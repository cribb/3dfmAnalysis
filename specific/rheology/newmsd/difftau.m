function diffout = difftau(data, taulist)
% MSD computes the displacements across a frame-window, tau 
%
% CISMM function
% specific\rheology\msd
%  
%  
% [diffout] = difftau(data, taulist)   
%
% where:  "data" is a N-column matrix containing trajectory information, 
%            agnostic of coordinate identification
%         "taulist" is a vector containing integer frame-window lag "times"
%

if nargin < 2 || isempty(taulist) || isempty(data)
    logentry('No taulist or input data defined. Returning empty set.');
    diffout        = NaN(length(taulist),1);
    Nestimates = NaN(length(taulist),1);
end

taulist = taulist(:);

% for every taulist size (or tau)
warning('off', 'MATLAB:divideByZero');

r = NaN(size(data,1), size(data,2), length(taulist));
    
    for w = 1:length(taulist)
    
        if isnan(taulist(w))
            continue;
        end
          
        A = data(1:end-floor(taulist(w)), :);
        B = data(floor(taulist(w))+1:end, :);
    
        d = B - A;
        
        r(1:end-floor(taulist(w)),:,w) = d;
%         n(w,:) = sum(isnan(d),1);        
        
    end                               

diffout = r;

warning('on', 'MATLAB:divideByZero');

return



% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'difftau: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  