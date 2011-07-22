function [mypass, mywell] = pan_wellpass(filenamein)
% PAN_WELLPASS extracts the well and pass values in the filename for a PanopticNerve run.
%
%
%  [mypass, mywell] = pan_wellpass(filenamein) 
%   
%  where "mypass" is pass value
%        "mywell" is the well value
%        "filenamein" is the input filename
%  


    chunk  = regexp(filenamein, '_pass[0-9]*', 'match');
    mypass = regexp(chunk, '[0-9]*', 'match');
    mypass = str2double(mypass{:});
    
    
    chunk  = regexp(filenamein, '_well[0-9]*', 'match');
    mywell = regexp(chunk, '[0-9]*', 'match');
    mywell = str2double(mywell{:});    
      
  return;
  
