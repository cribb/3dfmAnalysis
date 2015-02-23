function fileList = recursiveFindFile(searchPath,filePattern,patternMode,fileList)
% FUNCTION files = RECURSIVEFINDFILE(searchPath,filePattern)
% A case insensitive search to find files with in the folder _searchPath_ 
% (if specified) whos file name matches the pattern _filePattern_ and add 
% the results to the list of files in the cell array _fileList_. 
%
% The search can be either a wild-card or regular expression search and is
% case insenstive
%
%
% INPUTS (all are optional
%    searchPath  - Default ask user
%                - directory or string to search can be either a absolute 
%                  or relative path.
%                
%    filePattern - Default: *.* (All files)
%                - List of file wildcard file patterns to search
%                - Wild-card examples
%                     filePattern = '*.xls' % find Excel files
%                     filePattern = {'*.m' *.mat' '*.fig'}; % MATLAB files
%
%                - Regular expression examples (See regexpi help for more)
%                     filePattern = '^[af].*\.xls' % Excel files beginning
%                                                  % with either A,a,F or f
%
%    patternMode - Default: 'Wildcard'
%                - 'Wildcard' for wild-card searches or 
%                - 'Regexp' for regular expression searches
%    fileList    - list of files (nx1 cell). Default is an empty cell.
   
%
%
% author: Azim Jinha (2011)


% Copyright (c) 2012, Azim All rights reserved. Redistribution and use in source and 
% binary forms, with or without modification, are permitted provided that the 
% following conditions are met:
%   * Redistributions of source code must retain the above copyright
%     notice, this list of conditions and the following disclaimer.
   
% Redistributions in binary form must reproduce the above copyright notice, this 
% list of conditions and the following disclaimer in the documentation and/or other 
% materials provided with the distribution

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
% OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
% GOODS OR SERVICES; LOSS OF % USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%% Test inputs

%*** searchPath ***
if ~exist('searchPath','var') || isempty(searchPath) || ~exist(searchPath,'dir')
    searchPath = uigetdir('Select Path to search');
end

% *** filePattern ***
if ~exist('filePattern','var') || isempty(filePattern), filePattern={'*.*'}; end

if ~iscell(filePattern)
    % if only one file pattern is entered make sure it 
    % is still a cell-string.
    filePattern = {filePattern};
end

% *** patternMode ***
if ~exist('patternMode','var')||isempty(patternMode),patternMode = 'wildcard'; end
switch lower(patternMode)
case 'wildcard'
    % convert wild-card file patterns to regular expressions
    fileRegExp=cell(length(filePattern(:)));
    for i=1:length(filePattern(:))
        fileRegExp{i}=regexptranslate(patternMode,filePattern{i});
    end
otherwise
    % assume that the file pattern(s) are regular expressions
    fileRegExp = filePattern;
end

% *** fileList ***
% test input argument file list
if ~exist('fileList','var'),fileList = {}; end % does it exist

% is fileList a nx1 cell array
if size(fileList,2)>1, fileList = fileList'; end 
if ~isempty(fileList) && min(size(fileList))>1, error('input fileList should be a nx1 cell array'); end


%% Perform file search
% Get the parent directory contents
dirContents = dir(searchPath);

for i=1:length(dirContents)
    if ~strncmpi(dirContents(i).name,'.',1)
        newPath = fullfile(searchPath,dirContents(i).name);
        if dirContents(i).isdir
            fileList = recursiveFindFile(newPath,filePattern,patternMode,fileList);
        else
            foundFile=false;
            for jj=1:length(fileRegExp)
                foundFile = ~isempty(regexpi(dirContents(i).name, ...
                                             fileRegExp{jj}));
                if foundFile, break; end
            end
            if foundFile
                fileList{end+1,1} = newPath; %#ok<AGROW>
            end
        end
    end
end