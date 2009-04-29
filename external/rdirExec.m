function rdirExec(rootdir,varargin)
% Calls a function handle for each matching file found. 
% 
% rdirExec(ROOT,EXECFUN,OPTEXECFUNARGS)
%
% Recursive directory walk. execFun is a function handle that gets called
% for each matching file found.The first input argument being the full 
% path of the file, followed by the optional OPTEXECFUNARGS
%
% ROOT is the directory starting point and includes the 
% wildcard specification.
% Pathnames and wildcards may be used. Wild cards can exist
% in the pathname too. A special case is the double * that
% will match multiple directory levels, e.g. c:\**\*.m. 
% Otherwise a single * will only match one directory level.
% e.g. C:\Program Files\Windows *\
%
% EXECFUN is a function handle which takes at least one input argument
%
% OPTEXECFUNARGS are optional input arguments to EXECFUN
%
% See also DIR
%
% examples:
% 
%   % To create a file list
%   fid=fopen('fileList.txt','wt');
%   rdirExec('c:\program files\windows *\**\*.dll',@callBack,fid)
%   fclose(fid);
%
%   %The callBack function has the following signature
%   function callBack(varargin)
%   fileName=varargin{1};
%   fid=varargin{2};
%   fprintf(fid,'%s\n',fileName);
%   end

% use the current directory if nothing is specified
if ~exist('rootdir','var'),
  rootdir = '*';
end;

callBack=varargin{1};
if(nargin>2)
    otherArgs=varargin{2:end};
else
    otherArgs={};
end


% split the file path around the wild card specifiers
prepath = '';       % the path before the wild card
wildpath = '';      % the path wild card
postpath = rootdir; % the path after the wild card
I = find(rootdir==filesep,1,'last');
if ~isempty(I),
  prepath = rootdir(1:I);
  postpath = rootdir(I+1:end);
  I = find(prepath=='*',1,'first');
  if ~isempty(I),
    postpath = [prepath(I:end) postpath];
    prepath = prepath(1:I-1);
    I = find(prepath==filesep,1,'last');
    if ~isempty(I),
      wildpath = prepath(I+1:end);
      prepath = prepath(1:I);
    end;
    I = find(postpath==filesep,1,'first');
    if ~isempty(I),
      wildpath = [wildpath postpath(1:I-1)];
      postpath = postpath(I:end);
    end;
  end;
end;
% disp([' "' prepath '" ~ "' wildpath '" ~ "' postpath '" ']);


if isempty(wildpath),
  % if no directory wildcards then just get file list
  D = dir([prepath postpath]);
  % clear out the dirs
  D([D.isdir]==1) = [];
  for ii = 1:length(D),
    if (~D(ii).isdir),
      D(ii).name = [prepath D(ii).name];
    end;
    
    if(isempty(otherArgs))
        feval(callBack,D(ii).name);
    else
        addArgs={D(ii).name,otherArgs};
        feval(callBack,addArgs{:});
    end
    clear D;
  end;

  % disp(sprintf('Scanning "%s"   %g files found',[prepath postpath],length(D)));

elseif strcmp(wildpath,'**'), % a double wild directory means recurs down into sub directories

  % first look for files in the current directory (remove extra filesep)
  rdirExec([prepath postpath(2:end)],callBack,otherArgs);

  % then look for sub directories
  tmp = dir([prepath '*']);
  % process each directory
  for ii = 1:length(tmp),
    if (tmp(ii).isdir && ~strcmpi(tmp(ii).name,'.') && ~strcmpi(tmp(ii).name,'..') ),
      rdirExec([prepath tmp(ii).name filesep wildpath postpath],callBack,otherArgs);
    end;
  end;

else
  % Process directory wild card looking for sub directories that match
  tmp = dir([prepath wildpath]);
  % process each directory found
  for ii = 1:length(tmp),
    if (tmp(ii).isdir && ~strcmpi(tmp(ii).name,'.') && ~strcmpi(tmp(ii).name,'..') ),
      rdirExec([prepath tmp(ii).name postpath],callBack,otherArgs);
    end;
  end;
end;

