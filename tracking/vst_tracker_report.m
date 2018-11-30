function outs = vst_tracker_report(DataIn)


T = join(DataIn.TrajImageTable, DataIn.VidTable{'Fid', 'SampleName', 'SampleInstance'});

tracker_report