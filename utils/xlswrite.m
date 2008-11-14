function xlswrite(m,header,colnames,filename)
% XLSWRITE Easily create an Excel spreadsheet from MATLAB
%
%  xlswrite(m,header,colnames,filename) creates a Microsoft Excel spreadsheet using
%  the MATLAB ActiveX interface.  Microsoft Excel is required.
%
%Inputs:
%    m          Matrix to write to file
% (Optional):
%    header     String of header information.  Use cell array for multiple lines
%                  DO NOT USE multiple row character arrays!!
%    colnames   (Cell array of strings) Column headers.  One cell element per column
%    filename   (string) Name of Excel file.  If not specified, contents will
%                  be opened in Excel.
%
% ex:
%   m = rand(100,4);
%   header = 'my data';
%   %header{1} = 'first line';      %This will give
%   %header{2} = 'second line';     % 2 header lines
%   colnames = {'Ch1','Ch2','Ch3','Ch4'};
%
%   xlswrite(m,header,colnames,'myfile.xls');
%        will save the spreadsheet as myfile.xls.  The user
%           will never see Excel
%   xlswrite(m,header,colnames);
%        will open Excel with these contents in a new spreadsheet.
%      


% Scott Hirsch
% The MathWorks
% This is provided free, no warranty, ...

% Copied from ActiveX example in documentation

[nr,nc] = size(m);
if nc>256
    error('Matrix is too large.  Excel only supports 256 columns');
end;

% Open Excel, add workbook, change active worksheet, 
% get/put array, save.
% First, open an Excel Server.
Excel = actxserver('Excel.Application');


%If the user does not specify a filename, we'll make Excel visible
%If they do, we'll just save the file and quit Excel without ever making
% it visible
if nargin<4
    set(Excel, 'Visible', 1);      %You might want to hide this if you autosave the file
end;

% Insert a new workbook.
Workbooks = Excel.Workbooks;
Workbook = invoke(Workbooks, 'Add');

% Make the first sheet active.
Sheets = Excel.ActiveWorkBook.Sheets;
sheet1 = get(Sheets, 'Item', 1);
invoke(sheet1, 'Activate');

% Get a handle to the active sheet.
Activesheet = Excel.Activesheet;

%Write header
if nargin<2 | isempty(header)
    nhr=0;
elseif iscell(header)
    nhr = length(header);       %Number header rows
    for ii=1:nhr
        ActivesheetRange = get(Activesheet,'Range',['A' num2str(ii)],['A' num2str(ii)]);
        set(ActivesheetRange, 'Value', header{ii});
    end;
else
    nhr = 1;                    %Number header rows
    ActivesheetRange = get(Activesheet,'Range','A1','A1');
    set(ActivesheetRange, 'Value', header);
end;


%Add column names
if nargin>2 & ~isempty(colnames)
    nhr = nhr + 1;      %One extra column name
    ncolnames = length(colnames);
    for ii=1:ncolnames
        colname = localComputLastCol('A',ii);
        %    cellname = [char(double('A')+ii-1) num2str(nhr+1)];
        cellname = [colname num2str(nhr)];
        ActivesheetRange = get(Activesheet,'Range',cellname,cellname);
        set(ActivesheetRange, 'Value', colnames{ii});
    end;
end;


% Put a MATLAB array into Excel.
FirstRow = nhr+1;           %You can change the first data row here.  I start right after the headers
LastRow = FirstRow+nr-1;
FirstCol = 'A';         %You can change the first column here
LastCol = localComputLastCol(FirstCol,nc);
ActivesheetRange = get(Activesheet,'Range',[FirstCol num2str(FirstRow)],[LastCol num2str(LastRow)]);
set(ActivesheetRange, 'Value', m);

% If user specified a filename, save the file and quit Excel
if nargin==4
    invoke(Workbook, 'SaveAs', [pwd filesep filename]);
    invoke(Excel, 'Quit');
    
    [pathstr,name,ext] = fileparts(filename);
    disp(['Excel file ' name '.xls has been created.']);
end;

%Delete the ActiveX object
delete(Excel)

function LastCol = localComputLastCol(FirstCol,nc);
% Comput the name of the last column where we will place data
%Input
%  FirstCol  (string) name of first column
%  nc        total number of columns to write

%Excel's columns are named:
% A B C ... A AA AB AC AD .... BA BB BC ...
FirstColOffset = double(FirstCol) - double('A');    %Offset from column A
if nc<=26-FirstColOffset       %Easy if single letter
    %Just convert to ASCII code, add the number of needed columns, and convert back
    %to a string
    LastCol = char(double(FirstCol)+nc-1);
else
    ng = ceil(nc/26);       %Number of groups (of 26)
    rm = rem(nc,26)+FirstColOffset;        %How many extra in this group beyond A
    LastColFirstLetter = char(double('A') + ng-2);
    LastColSecondLetter = char(double('A') + rm-1);
    LastCol = [LastColFirstLetter LastColSecondLetter];
end;