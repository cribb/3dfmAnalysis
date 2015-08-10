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

filelistA = dir([pathA filesep '*TRACKED' '.' filetype]);
filelistB = dir([pathB filesep '*TRACKED.vrpn' '.' filetype]);

if length(filelistA) ~= length(filelistB)
    error('the same files do not exist in both folders');
end

table = [];

for k = 1:length(filelistA)

    fileA = [pathA filesep filelistA(k).name];
    fileB = [pathB filesep filelistB(k).name];
    
    ct = compare_tracking(fileA, fileB, 1, 0.1, filteryn);

    if strcmpi(filteryn, 'y')
        %function outfile = save_evtfile(filename, tracking_in, xyzunits, calib_um, fps)
        save_evtfile(filtered_file, ct.filtered, 'pixels', 1, );
    end
    
    [mywell, mypass] = pan_wellpass(filelistA(k).name);
    
    well = repmat(mywell, size(ct.pairedAB_IDs,1),1);
    pass = repmat(mypass, size(ct.pairedAB_IDs,1),1);
        
    % only accept cases where both IDs (A & B) are real values (Not NaN)
    if ~isnan(ct.pairedAB_IDs(1,1)) && ~isnan(ct.pairedAB_IDs(1,2))
        
        tmp = [pass well ct.pairedAB_IDs ct.match_err ct.nPointsAB ct.maxABdiffXY ct.meanABdiffXY ct.stdABdiffXY];
        table = [table ; tmp];
    end
    
    outs.results  = table;
    outs.mismatch = table( isnan(table(:, MATCHERR_AB)), : );
    outs.filtered = table(~isnan(table(:, MATCHERR_AB)), : );
    outs.maxerrXY = max(outs.filtered(:,MAXDIFFX:MAXDIFFY),[],1);
end

return;
