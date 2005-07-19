function utc = unixUTC(time,fDLS)
% 3DFM function
% Utilities
% last modified 07/19/2005 ; jcribb
%
% unixUTC( [YEAR, MONTH, DAY, HOUR, MINUTE, SECOND], DLS) converts to unix-type 
% timestamp (total number of seconds elapsed since 00:00:00 1970-01-01
%
% **OR**
%
% unixUTC( UNIX_TIMESTAMP, DLS )
% 
% WARNING: The output is adjusted assuming that the input is the local time in 
% NC, USA or Eastern Time Zone.
%
% OTHER PARAMETERS:
% "DLS": [{'yes'} | 'no'] specifies if we are on Day-light Savings time. 
%  Providing 'yes' GMT -4 (4 hours behind standard UTC, in England)
%  Providing 'no'  GMT -5 (5 hours behind standard UTC, in England)
%
%  EXAMPLE: 
%  Let us convert the time 2004-June-15, 12:28:02.40859 pm
%  uct = unixUtc( [2004,6,15,12,28,2.40859], 'yes' )
%  uct = 1087316882.4086
% 
if (nargin < 2 | isempty(fDLS))
    fDLS = 'yes';
end

[row col] = size(time);

switch col
    case 1
        [yyyy,mm,dd,hour,minute,second] = unixsecs2date(time);

        if strfind(fDLS,'y')
            gmt_hour = hour + 4;
		else
            gmt_hour = hour + 5;
		end
        
        utc = [yyyy,mm,dd,gmt_hour,minute,second];
        
    case 6
		yyyy   = time(:,1);
		mm     = time(:,2);
		dd     = time(:,3);
		hour   = time(:,4);
		minute = time(:,5);
		second = time(:,6);

		if strfind(fDLS,'y')
            gmt_hour = hour + 4;
		else
            gmt_hour = hour + 5;
		end
 
		utc = date2unixsecs(yyyy,mm,dd,gmt_hour,minute,second);
        
    otherwise
        error('There is something funky with the time vector.');
end

    



  