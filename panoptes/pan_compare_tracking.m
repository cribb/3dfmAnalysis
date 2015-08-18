function outs = pan_compare_tracking(pathA, pathB, filetype, filteryn)

if nargin < 4 || isempty(filetype)
    filteryn = 'n';
end

if nargin < 3 || isempty(filetype)
    filetype = 'csv';
end

% column headers for output datatable
PASS = 1;
WELL = 2; 
IDA  = 3;
IDB  = 4;
MATCHERR_AB = 5;
NA = 6;
NB = 7;
MAXDIFFX = 8;
MAXDIFFY = 9;
MEANDIFFX = 10;
MEANDIFFY = 11;
STDDIFFX = 12;
STDDIFFY = 13;


metadataA = pan_load_metadata(pathA, 'panoptes', '96well');
metadataB = pan_load_metadata(pathB, 'panoptes', '96well');

fpsA = metadataA.instr.fps_imagingmode;
fpsB = metadataB.instr.fps_imagingmode;

if fpsA ~= fpsB
    error('ERROR! Frame rates between the two datasets are not identical!');
end

filelistA = dir([pathA filesep '*TRACKED.' filetype]);
% filelistA = dir([pathA filesep '*TRACKED.vrpn.mat']);
filelistB = dir([pathB filesep '*TRACKED.vrpn.' filetype]);

if length(filelistA) ~= length(filelistB)
    error('the same files do not exist in both folders');
end

table = ones(0,13);

for k = 1:length(filelistA)

    fileA = [pathA filesep filelistA(k).name];
    fileB = [pathB filesep filelistB(k).name];
    
    id_error_thresh = 1; % pixel distance between Atracker and the closest Btracker
    xy_error_thresh = 0.1; % on average s
    
    ct = compare_tracking(fileA, fileB, id_error_thresh, xy_error_thresh, filteryn);

    if strcmpi(filteryn, 'y')
%         filtered_filename = [filelistB(k).name(1:end-3) 'evt.mat'];
        filtered_filename = fileB;
        save_evtfile(filtered_filename, ct.filteredB, 'pixels', 1, fpsA, 'csv');
    end
    
    [mywell, mypass] = pan_wellpass(filelistA(k).name);
    
    well = repmat(mywell, size(ct.pairedAB_IDs,1),1);
    pass = repmat(mypass, size(ct.pairedAB_IDs,1),1);
        
    % only accept cases where both IDs (A & B) are real values (Not NaN)
    if ~isnan(ct.pairedAB_IDs(1,1)) && ~isnan(ct.pairedAB_IDs(1,2))
        
        tmp = [pass well ct.pairedAB_IDs ct.match_err ct.nPointsAB ct.maxABdiffXY ct.meanABdiffXY ct.stdABdiffXY];
        table = [table ; tmp];
    end
    
end

% set up outputs
failed_matches_NaN = isnan(table(:, MATCHERR_AB));
failed_matches_ID  = table(:,MATCHERR_AB) >= id_error_thresh;

failed_matches = or(failed_matches_NaN, failed_matches_ID);

outs.results  = table;
outs.mismatch = table( failed_matches, : );
outs.filtered = table(~failed_matches, : );
outs.maxerrXY = max(outs.filtered(:,MAXDIFFX:MAXDIFFY),[],1);
    
return;
