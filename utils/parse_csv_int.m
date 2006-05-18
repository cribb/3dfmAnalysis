function numerVec = parse_csv_int(str)
% 3DFM Function
% Utility
%
% This function parses a string which contains positive integers separated by 
% non-numeric characters (e.g. comma, white space, dot, minus sign etc).
% If the string contains 1 colon (:), then the nearest numeric characters
% before and after the colon are considered to make the matlab format array.
% e.g. 'x y 2z : a b4 c' is parsed as [2:1:4] 
% If the string contains 2 colons, then the nearest numeric characters before both the colons and
% just after 2nd colon are considered to make the matlab format array e.g.
% '1x 2 yz : x1y 3 c : 4 e' is parsed as [2:3:4]
% 
% Created: ??/??/2005     -kvdesai
% Last Modified: 05/18/06 -kvdesai

numerVec = [];
digflags = isstrprop(str,'digit');
inum = find(digflags ~= 0 );
if isempty(inum)
    disp('Warning: No numeric character was found in the string supplied to parse_csv_int.');    
    return;
end

if ~isempty(strfind(str,':'))
    icolon = strfind(str,':');
    imin = getneighbors(inum(max(find(inum < icolon(1)))),digflags);    
    dmin = str2num(str(imin));        
    if length(icolon) > 1
        istep = getneighbors(inum(max(find(inum < icolon(2) & inum > icolon(1)))),digflags);
        dstep = str2num(str(istep));
        imax = getneighbors(inum(min(find(inum > icolon(2)))),digflags);
        dmax = str2num(str(imax));
    else % length(icolon) = 1        
        dstep = 1;
        imax = getneighbors(inum(min(find(inum > icolon(1)))),digflags);
        dmax = str2num(str(imax));
    end
%     disp(icolon); disp(inum); disp([dmin dstep dmax]);
    numerVec = dmin:dstep:dmax;
    if isempty(numerVec)
        disp('Warning: Strange arrangement of colon (:) operators.');
    end
else   
   for c = 1:length(inum)
       thisnum = str2num(str(getneighbors(inum(c),digflags)));
       if any(numerVec == thisnum)
           continue; % This is a duplication caused because of considering neighbors
       else
           numerVec = [numerVec,thisnum];
       end
   end
end
%---------------
function ingh = getneighbors(i,digflags)
ingh = [];
if digflags(i) == 0
    error('Array parsing code is messed up. Tell some programmer to fix');
    return;
end
ibef = max(find(digflags(1:i-1) == 0)); 
if isempty(ibef)
    ibef = 1;
else
    ibef = ibef + 1;
end
iaft = min(find(digflags(i+1:end) == 0));
if isempty(iaft)
    iaft = length(digflags) - i;
else
    iaft = iaft - 1;
end
ingh = ibef:i+iaft;