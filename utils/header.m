function header(type)
% 3DFM function
% Utilities
% last modified on 07/29/2003
%
% This function outputs the header for writing new matlab functions for
% the 3DFM lab.
% 
% [no outputs] = header(type)
% 
% where type is a text string
% 'R'   Rheology 
% 'T'   Tracking
% 'U'   Utilities
% 'D'   Diagnostics
% 'M'   Math
% 'I'   Image Analysis
% else  Miscellaneous
%

if nargin < 1 | isempty(type)
    type = '';
end

switch upper(type)
    case 'R'
        subgroup = 'Rheology';
    case 'T'
        subgroup = 'Tracking';
    case 'U'
        subgroup = 'Utilities';
    case 'D'
        subgroup = 'Diagnostics';
    case 'M'
        subgroup = 'Math';
    case 'I'
        subgroup = 'Image Analysis';
    otherwise
        subgroup = 'Miscellaneous';
end
    
	
	fprintf( ' \n%% 3DFM function ');
    fprintf( ' \n%% %s', subgroup);
    fprintf([' \n%% last modified ' date]);
	fprintf( ' \n%% ');
	fprintf( ' \n%% This function does something ');
	fprintf( ' \n%% ');
	fprintf( ' \n%%  [outputs] = function_name(parameter1, parameter2, etc...); ');
	fprintf( ' \n%%  ');
	fprintf( ' \n%%  where "parameter1" is [something] in units of [units]');
	fprintf( ' \n%%        "parameter2" is [something] in units of [units]');
	fprintf( ' \n%%		 etc... ');
	fprintf( ' \n%% ');
	fprintf( ' \n%%  Notes: ');
	fprintf( ' \n%%  ');
	fprintf( ' \n%%  - Extra information goes here ');
	fprintf( ' \n%%  - For a good example, look at load_video_tracking');
	fprintf( ' \n%% ');
    fprintf( ' \n\n ');
    
    

   
