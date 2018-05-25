function outs = vst_mk_ImageTable(VidTable)

N = size(VidTable,1);

video_files = fullfile(VidTable.Path, VidTable.VideoFiles);
fframe_files = fullfile(VidTable.Path, VidTable.FirstFrameFiles);
mip_files = fullfile(VidTable.Path, VidTable.MipFiles);

for f = 1:N
    
        Fid(f,1) = VidTable.Fid(f);
        FirstFrames{f,1} = imread(fframe_files{f});
        Mips{f,1} = imread(mip_files{f});
        
end

outs = table(Fid, FirstFrames, Mips);
