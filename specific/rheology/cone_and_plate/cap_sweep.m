function v = cap_sweep(file)
% CAP_SWEEP Converts exported SWEEP data from Bohlin Gemini cone-and-plate rheometer to a standard matlab structure/workspace
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%  
% Converts exported SWEEP data from Bohlin Gemini cone-and-plate 
% rheometer to a standard matlab structure/workspace.  The output structure
% contains all information regarding headers and values extracted from the
% XLS file, for possible debugging purposes later.
%  
%  [output] = cap_sweep(file);  
%   
%  where "file" is a Excel (XLS) file constaining standard exported creep
%  data from Bohlin rheometer.
%   
%  03/31/05 - created; jcribb.
%  05/09/05 - added documentation.  
%

[data, headertext] = xlsread(file);

% column headers are determined by the Bohlin/Malvern rheology Software
% package.  For frequency and amplitude sweeps, these headers are:  time, 
% temperature, frequency, phase angle, complex modulus, elastic modulus, 
% viscous modulus, complex viscosity, shear stress, strain, normal force.
% Values with #N/A in the spreadsheets are converted to NaN.
TIME             = 1;
TEMPERATURE      = 2;
FREQUENCY        = 3;
PHASEANGLE       = 4;
COMPLEXMODULUS   = 5;
ELASTICMODULUS   = 6;
VISCOUSMODULUS   = 7;
COMPLEXVISCOSITY = 8;
SHEARSTRESS      = 9;
STRAIN           = 10;
NORMALFORCE      = 11;

HEADERS = 3;
UNITS   = 4;

v.time              = data(:,TIME);
v.temperature       = data(:,TEMPERATURE);
v.frequency         = data(:,FREQUENCY);
v.phaseangle        = data(:,PHASEANGLE);
v.complex_modulus   = data(:,COMPLEXMODULUS);
v.elastic_modulus   = data(:,ELASTICMODULUS);
v.viscous_modulus   = data(:,VISCOUSMODULUS);
v.complex_viscosity = data(:,COMPLEXVISCOSITY);
v.shear_stress      = data(:,SHEARSTRESS);
v.strain            = data(:,STRAIN);
v.normalforce       = data(:,NORMALFORCE);

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
