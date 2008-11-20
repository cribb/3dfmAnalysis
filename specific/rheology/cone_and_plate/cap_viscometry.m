function v = cap_viscometry(file)
% CAP_VISCOMETRY Converts exported VISCOMETRY data from Bohlin Gemini cone-and-plate rheometer to a standard matlab structure/workspace 
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%
%  
% Converts exported VISCOMETRY data from Bohlin Gemini cone-and-plate 
% rheometer to a standard matlab structure/workspace.  The output structure
% contains all information regarding headers and values extracted from the
% XLS file, for possible debugging purposes later.
%  
%  [output] = cap_viscometry(file);  
%   
%  where "file" is a Excel (XLS) file constaining standard exported creep
%  data from Bohlin rheometer.

[data, headertext] = xlsread(file);

% column headers are determined by the Bohlin/Malvern rheology Software
% package.  For viscometry expts, these headers are:  time, temperature, 
% shear stress, shear rate, instantaneous viscosity, strain, normal force, 
% and normal force N1.Values with #N/A in the spreadsheets are converted 
% to NaN.

TIME             = 1;
TEMPERATURE      = 2;
SHEARSTRESS      = 3;
SHEARRATE        = 4;
VISCOSITY        = 5;
STEADYSTATE      = 6;
NORMALFORCE      = 7;
NORMALFORCEN1    = 8;

HEADERS = 3;
UNITS   = 4;

v.time              = data(:,TIME);
v.temperature       = data(:,TEMPERATURE);
v.shear_stress      = data(:,SHEARSTRESS);
v.shear_rate        = data(:,SHEARRATE);
v.viscosity         = data(:,VISCOSITY);
v.steady_state      = data(:,STEADYSTATE);
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
