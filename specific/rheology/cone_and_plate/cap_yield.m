function v = cap_yield(file)
% 3DFM function  
% Rheology::cone_and_plate
% last modified 05/09/2005
%  
% Converts exported VISCOMETRY:YIELD data from Bohlin Gemini cone-and-plate 
% rheometer to a standard matlab structure/workspace.  The output structure
% contains all information regarding headers and values extracted from the
% XLS file, for possible debugging purposes later.
%  
%  [output] = cap_yield(file);  
%   
%  where "file" is a Excel (XLS) file constaining standard exported creep
%  data from Bohlin rheometer.
%   
%  03/31/05 - created; jcribb.
%  05/09/05 - added documentation.  
%
[data, headertext] = xlsread(file);

% column headers are determined by the Bohlin/Malvern rheology Software
% package.  For yield stress expts, these headers are:  time, temperature, 
% shear stress, shear rate, instantaneous viscosity, strain, normal force, 
% and normal force N1.Values with #N/A in the spreadsheets are converted 
% to NaN.

TIME             = 1;
TEMPERATURE      = 2;
SHEARSTRESS      = 3;
SHEARRATE        = 4;
INSTANTVISCOSITY = 5;
STRAIN           = 6;
NORMALFORCE      = 7;
NORMALFORCEN1    = 8;

HEADERS = 3;
UNITS   = 4;

v.time              = data(:,TIME);
v.temperature       = data(:,TEMPERATURE);
v.shear_stress      = data(:,SHEARSTRESS);
v.shear_rate        = data(:,SHEARRATE);
v.instant_viscosity = data(:,INSTANTVISCOSITY);
v.strain            = data(:,STRAIN);
v.normalforce       = data(:,NORMALFORCE);
v.normalforceN1     = data(:,NORMALFORCEN1);

% deal with units and headers
for k = 1 : size(headertext,2)  
    str = headertext{UNITS,k};
    idx = find((str ~= '(') & (str ~= ')') & str ~= '''');    
    str = str(idx);
	v.units{k} = str;
    
    str = headertext{HEADERS,k};
    idx = find((str ~= '(') & (str ~= ')') & str ~= '''');    
    str = str(idx);
	v.headers{k} = str;
end