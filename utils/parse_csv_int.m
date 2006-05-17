function numerVec = parse_csv_int(str)
% 3DFM Function
% Utility
% This function parses the comma separated list and extracts
% out the numbers from that. It is flexible enough that as long as user
% puts one comma AND/OR one space between consequtive frequencies, it works.
% Created: 05/17/06     -kvdesai

if(isempty(str))
    error('Error: Frequency vector can not be left empty');
elseif isempty(str2num(str(1)))
    error('Error: First element of the string must be numeric (check for whitespace)');
end
itrue = 1;
waiting_for_char = 1;
first_dig_index = 1;
for i = 2:length(str)
    if isempty(str2num(str(i)))%this means the element is not a numeric character
        if waiting_for_char 
            numerVec(itrue) = str2num(str(first_dig_index:i-1));
            waiting_for_char = 0;
            itrue = itrue+1;
        end
    else
        if ~waiting_for_char %atleast one char before, so this is the first digit 
            first_dig_index = i;
            waiting_for_char = 1;
        end
    end
end
if(waiting_for_char)%this means last element is numeric character
    numerVec(itrue) = str2num(str(first_dig_index:end));
end