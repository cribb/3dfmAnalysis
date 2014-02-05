function array_out = pan_plate2array(plate_in)
% PAN_PLATE2ARRAY converts a Panoptes plate-shaped matrix to a linear array.
%
% Panoptes function 
% 
% This function is used by the Panoptes analysis code to convert a 
% 'plate-shaped' matrix of data that corresponds with the multiwell plate 
% geometry into a 1x96 array used in the analysis code.
% 
% plateout = pan_array2plate(arrayin) 
%
% where "array_out" is the outputted data array used by the Panoptes analysis code.
%       "plate_in" is the inputted 8 row x 12 col matrix in plate format
%
% Notes:
% - This function is designed to work within the PanopticNerve software
% chain but can also be used manually from the matlab command line interface.
%

if size(plate_in,1) ~= 8 && size(plate_in,2) ~= 12
    error('This is not a well-defined plate matrix');
end

array_out = reshape(transpose(plate_in), 1, 96);

