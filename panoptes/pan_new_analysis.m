function DataOut = pan_new_analysis(filepath, systemid, platetype)


% (0) Load in the experiment's metadata
d.metadata = pan_load_metadata(filepath, systemid, platetype);

% (1) Load in run metadata and tracking data from a panoptes directory. 
d.VidTable = pan_mk_video_table(filepath, systemid, platetype);

% (2) Load in imaging data
d.ImageTable = vst_mk_ImageTable(d.VidTable);

% (3) Load in the tracking data
d.TrackingTable = vst_load_tracking(d.VidTable);

% (4) Summarize Tracking information
d.TrackingSummary = vst_summarize_traj(d.TrackingTable);
d.FileSummary = vst_summarize_files(d.TrackingSummary);

% (5) Filter tracking data and put eliminated data into a "Trash" table.
filtin.tcrop      = 3;
filtin.min_frames = floor(d.metadata.instr.fps_fluo/2);

[FilteredTrackingTable, Trash] = vst_filter_tracking(d.TrackingTable, filtin);

d.TrackingTable = FilteredTrackingTable;
d.Trash = Trash;

% (6) Deal with drift separately from traditional "filtering" operation.
COMtable = vst_common_motion(d.TrackingTable); %%% REMEMBER THIS IS FILTERED TRACKING
d.TrackingTable = join(d.TrackingTable, COMtable);

% (7) Identify salient groups in the dataset: beadGroups, fileGroups,
% SampleNameGroups, SampleInstanceGroups, FovIDGroups

% (8) Calculate basic statistics & put into data structure

% (9) Calculate displacements & put into data structure

% (10) Calculate MSD on beadGroups and put into data structure

% (11) Save dataset

DataOut = d;

bigTable = join(d.TrackingTable, d.VidTable);

bigTable.RegionSize = log10(bigTable.RegionSize);
bigTable.Sensitivity = log10(bigTable.Sensitivity);
bigTable.ForegroundSize = log10(bigTable.ForegroundSize);

column_names = {'X', 'Y', 'CenterIntensity', 'Sensitivity', 'ForegroundSize', 'RegionSize'};

% [gS, groups] = findgroups(myTable.SampleName);
% groups = cellstr(char(groups(:,1)));

% to compress back to a single group tag (not really what we want)
[gS, groups(:,1), groups(:,2), groups(:,3), groups(:,4)] = findgroups(bigTable.SampleName, bigTable.SampleInstance, bigTable.FovID, bigTable.ID);
foo = [cellstr(char(groups(:,1))), cellstr(char(groups(:,2))), cellstr(char(groups(:,3))), cellstr(char(groups(:,4)))];
for k = 1:size(foo,1)
    tmp{k,1} = [foo{k,1} '_' foo{k,2} '_' foo{k,3} '_' foo{k,4}]; 
end
groups = tmp;

Fps = d.metadata.instr.fps_fluo;

Ngroups = length(groups);
Ncolumns = length(column_names);

% repmat(42,size(gS))
% msd1sec = splitapply(@(x1,x2,x3){msd(x1,x2,x3)}, myTable.Frame.*Fps, [myTable.X myTable.Y].*myTable.Calibum, [], gS);
msd1sec = splitapply(@(x1,x2){msd(x1,x2)}, bigTable.Frame.*Fps, [bigTable.X bigTable.Y].*bigTable.Calibum, gS);
% taulist = msd_gen_taus(max(myTable.Frame), 

for c = 1:Ncolumns
    [say, sax] = splitapply(@ksdensity, bigTable(:,column_names{c}), gS);
    
    
    
    for g = 1:Ngroups
        kdens(g,1).(column_names{c}) = [sax(g,:)', say(g,:)'];
    end    
    
end
Dout = struct2table(kdens);
Dout.Properties.RowNames = groups;

% foomsd = splitapply(@(x1,x2){msd(x1,x2)}, foobar.Frame./foobar.Fps, [foobar.X foobar.Y].*foobar.Calibum, g);

figure;
count = 1;
for c = 1:Ncolumns
    subplot(1, Ncolumns, count);
    for g = 1:Ngroups
        mydata = table2array(Dout{groups(g), column_names(c)});
        hold on;
        plot(mydata(:,1), mydata(:,2));
%         if c >=4 && c <= 6
%             set(gca, 'XScale', 'log');
%         end
        xlabel(column_names{c})
        ylabel('PDE');
        hold off;       
    end    
    count = count + 1;
end

if length(groups) < 10 
    legend(groups, 'Interpreter', 'none'); %, 'Location', 'eastoutside');
end







