function outs = pan_zip_origdata(zipfilename, datapath)
% PAN_ZIP_ORIGDATA
%
% Want to ZIP up all the datafiles and replace MOST of them. 
% In addition to the resulting MAT file that contains everything, I want 
% to keep the wells.txt and *_WELL_LAYOUT.csv file available for quick
% grepping.
%

cd([datapath filesep '..']);

outs = zip(zipfilename, datapath);


