function [msdout, taulist] = msd1d(data, taulist)
% MSD computes the mean-square displacements (via the Stokes-Einstein relation) for a single bead
%
% CISMM function
% specific\rheology\msd
%  
%  
% [tau, msd] = msd(data, taulist);   
%
% where "data" is the input matrix of data
%       "taulist" is a vector containing window-lagtime sizes of tau when computing MSD. 
%

%initializing arguments
if (nargin < 2) || isempty(taulist) || ismpty(data)
    logentry('Input data and taulist needed, returning empty set'); 
    msdout        = NaN(length(taulist),1);
    Nestimates = NaN(length(taulist),1);
end

r = difftau(data, taulist);
    %         n(w,:) = sum(isnan(d),1);        
r2 = r.^2;
msdout = mean(r2, 1, 'omitnan');

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
     headertext = [logtimetext 'msd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  