function outs = save_bin_on_nvme(data, basefilename)

   [rows, cols, rgb, frames] = size(data);
   datatype = class(data);
   
   if rgb ~= 1
       error('Incorrect format for input. Must be X x Y x RGB x FRAMES, RGB = 1.');
   end
   
   switch datatype
       case 'uint8'
           depth = '8';
       case 'uint16'
           depth = '16';
       otherwise
           error('Type not found.');
   end
   
   [mypath, myname, myext] = fileparts(basefilename);
   
   filename = strcat([myname, '_', ...
                      num2str(cols), 'x', ...
                      num2str(rows), 'x', ...
                      num2str(frames), 'x', ...
                      depth, '-bit', ...
                      '.bin']);
   
   rootpath = pwd;
   filepath = cd(mypath);
                  
   fid = fopen(filename, 'w+');
   fwrite(fid, data);
   fclose(fid);
 
   disp(['Saved ' mypath filesep filename '.']);
   cd(rootpath);
   outs = filename;

return
