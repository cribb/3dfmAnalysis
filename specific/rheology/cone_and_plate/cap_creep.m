function v = cap_creep(file)
% 3DFM function  
% Rheology::cone_and_plate
% last modified 05/09/2005
%  
% Converts exported CREEP data from Bohlin Gemini cone-and-plate 
% rheometer to a standard matlab structure/workspace.  The output structure
% contains all information regarding headers and values extracted from the
% XLS file, for possible debugging purposes later.
%  
%  [output] = cap_creep(file);  
%   
%  where "file" is a Excel (XLS) file constaining standard exported creep
%  data from Bohlin rheometer.
%   
%  03/31/05 - created; jcribb.
%  05/09/05 - added documentation.  
%
[data, headertext] = xlsread(file);

TRUE = 1;
FALSE = 0;

% column headers are determined by the Bohlin/Malvern rheology Software
% package.  For creep experimeents these headers are:  temperature, 
% creep time, creep angle, creep compliance, recovery time, recovery angle, 
% recovery compliance, normal force, normal force N1.  Values with #N/A 
% in the spreadsheets are converted to NaN.
TEMPERATURE = 1;
CREEPTIME = 2;
CREEPANGLE = 3;
CREEPCOMPLIANCE = 4;
RECOVERYTIME = 5;
RECOVERYANGLE = 6;
RECOVERYCOMPLIANCE = 7;
NORMALFORCE = 8;
NORMALFORCEN1 = 9;

HEADERS = 3;
UNITS = 4;

% take care of the creep data first.
creepnans = isnan(data(:,CREEPTIME));
creep = find(creepnans == FALSE);

v.creep.temperature = data(creep,TEMPERATURE);
v.creep.time = data(creep,CREEPTIME);
v.creep.angle = data(creep,CREEPANGLE);
v.creep.compliance = data(creep,CREEPCOMPLIANCE);
v.creep.normalforce = data(creep,NORMALFORCE);
v.creep.normalforceN1 = data(creep,NORMALFORCEN1);

% now for the recovery data...
recoverynans = isnan(data(:, RECOVERYTIME));
recovery = find(recoverynans == FALSE);

v.recovery.temperature = data(recovery,TEMPERATURE);
v.recovery.time = data(recovery,RECOVERYTIME);
v.recovery.angle = data(recovery,RECOVERYANGLE);
v.recovery.compliance = data(recovery,RECOVERYCOMPLIANCE);
v.recovery.normalforce = data(recovery,NORMALFORCE);
v.recovery.normalforceN1 = data(recovery,NORMALFORCEN1);

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