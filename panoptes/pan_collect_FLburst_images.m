function outs = pan_collect_FLburst_images(panoptes_resultsfile, order_var)

if ~exist('panoptes_resultsfile', 'var')
    error('No file defined.'); 
end

if nargin < 2 || isempty(order_var)
    order_var = 'visc'; 
end

% other parameter settings
plate_type = '96well';
freqtype = 'f';

data = load(panoptes_resultsfile);

metadata = data.metadata;

% the viscosities are going to include all passes and so every viscosity
% for a particular well will be constant for all passes.
visclist = data.visclist;

% start working on the fluorescence burst (FLburst) files outtputed by the metadata structure
if ~isempty(metadata.files.FLburst)
    filelist = metadata.files.FLburst;
else
    error('No FLburst files to be found.');
end

collection_dir = 'FL_burst_collection';
mkdir(collection_dir);

metadata_dir = [collection_dir '/metadata'];
mkdir(metadata_dir);

order_var_dir = [metadata_dir '/' order_var];
mkdir(order_var_dir);

collection_file = [metadata.instr.experiment '_' collection_dir];

% fid = fopen([collection_dir '/' collection_file '.txt'], 'w');
fid = fopen([order_var_dir '/' order_var '.txt'], 'w');
fid2 = fopen([order_var_dir '/' 'AllNames'], 'w');

% fprintf(fid, 'image_filename, pass, well, channel, MCU_parameter, visc_Pa.s\n');
png_files = dir([collection_dir '/*.png']);
logentry('Not writing over PNG files that already exist.');

for k = 1:length(filelist)
    

    mydir = filelist(k).name;
    myfile = 'frame0001.pgm';
      
    
    old_FLburst_filename = [mydir '/' myfile];
    new_FLburst_filename = [mydir];
        
    if isempty(png_files)
        im = imread(old_FLburst_filename, 'PGM');    
        imwrite(im, [collection_dir '/' new_FLburst_filename,'_group_1_ellipses', '.png'] , 'PNG');
    end
    
    [mywell mypass] = pan_wellpass( mydir );
    
    mychannel = pan_get_channel_id(mywell);
    
    myMCU = metadata.mcuparams.mcu(metadata.mcuparams.well == mywell & ...
                                   metadata.mcuparams.pass == mypass );
                               
    myvisc = visclist(mywell);

    metadata_out(k,:) = [mypass, mywell, mychannel, myMCU, myvisc];
    filelist_out{k,1} = new_FLburst_filename;
end

[sorted_metadata, idx] = sortrows(metadata_out, [1 2]);
sorted_filelist = filelist_out(idx);

switch order_var
    case 'channel'
        values = num2str(sorted_metadata(:,3));
    case 'pass'
        values = num2str(sorted_metadata(:,1));
    case 'well'
        values = num2str(sorted_metadata(:,2));
    case 'MCU'
        values = num2str(sorted_metadata(:,4));
    case 'visc'
        values = num2str(sorted_metadata(:,5), '%10.2e\n');
    otherwise
        error('unknown order_var');        
end


for k = 1:length(filelist)
    fprintf(fid, '%s,%s,channel %s#pass %s#well %s#MCU %s#vsc_Pa.s %s\n', ...
                 [sorted_filelist{k} '_group_1'], ...
                 values(k,:), ...
                 num2str(sorted_metadata(k,3)), ...
                 num2str(sorted_metadata(k,1)), ...
                 num2str(sorted_metadata(k,2)), ...
                 num2str(sorted_metadata(k,4)), ...
                 num2str(sorted_metadata(k,5),'%10.2e\n'));
             
     fprintf(fid2, '%s,%s\n', ...
                 sorted_filelist{k}, ...
                 order_var);
end

fclose(fid);
fclose(fid2);
outs = 0;

return;
 
    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_collect_FLburst_images: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    
