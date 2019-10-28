function DataOut = ba_combine_runs(DataInA, DataInB)

repeatFID = intersect(DataInA.FileTable.Fid, DataInB.FileTable.Fid);

if isempty(repeatFID)
    DataOut.FileTable = [DataInA.FileTable; DataInB.FileTable];
    DataOut.ForceTable = [DataInA.ForceTable; DataInB.ForceTable];
    DataOut.BeadInfoTable = [DataInA.BeadInfoTable; DataInB.BeadInfoTable];
else
    error('Repeat FID. Likely the data are already combined. Data cannot be further combined.');
end
