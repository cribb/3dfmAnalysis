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
% Last Modified: 05/17/06 -kvdesai

numerVec = [];
inum = find(isstrprop(str,'digit') ~= 0 );
if isempty(inum)
    disp('Warning: No numeric character was found in the string supplied to parse_csv_int.');    
    return;
end

if ~isempty(strfind(str,':'))
    icolon = strfind(str,':');
    imin = inum(max(find(inum < icolon(1))));
    dmin = str2num(str(imin));        
    if length(icolon) > 1
        istep = inum(max(find(inum < icolon(2) & inum > icolon(1))));
        dstep = str2num(str(istep));
        imax = inum(min(find(inum > icolon(2))));
        dmax = str2num(str(imax));
    else % length(icolon) = 1        
        dstep = 1;
        imax = inum(min(find(inum > icolon(1))));
        dmax = str2num(str(imax));
    end
%     disp(icolon); disp(inum); disp([dmin dstep dmax]);
    numerVec = dmin:dstep:dmax;
    if isempty(numerVec)
        disp('Warning: Strange arrangement of colon (:) operators.');
    end
else   
   for c = 1:length(inum)
       numerVec(c) = str2num(str(inum));
   end
end