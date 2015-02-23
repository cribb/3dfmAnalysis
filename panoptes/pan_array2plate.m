function plateout = pan_array2plate(arrayin)
% PAN_ARRAY2PLATE converts a linear array (1x96) to a proper plate format (8x12)
%
% Panoptes function 
% 
% This function is used by the Panoptes analysis code to convert a 1x96 array 
% of data into a 'plate-shaped' matrix that will correspond with the
% multiwell plate geometry used the Panoptes high-throughput system.
% 
% plateout = pan_array2plate(arrayin) 
%
% where "plateout" is the outputted 8 row x 12 col matrix in plate format
%       "arrayin" is the input data array obtained from the Panoptes analysis code.
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can also be used manually from the matlab command line interface.
%

% First, set up default values for input parameters in case they are empty 
% or otherwise do not exist.  
if length(arrayin) ~= 96
    error('This is not a well-defined array that describes a 96-well plate');
end

plateout = transpose(reshape(arrayin(:), 12, 8));

