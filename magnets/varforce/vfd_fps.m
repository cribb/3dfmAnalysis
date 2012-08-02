% Christian Stith <chstith@ncsu.edu> and Jeremy Cribb, 06-28-2012
% vfd_fps.m
% 
% Updates .vfd.mat files to include an fps field that stores the value in
% myfps. Will not overwrite fps if stored already. Runs on the entire current
% directory, or on vfdfilein alone if given. Returns the number of files
% adjusted.
%
% Command Line syntax:  vfd_fps(<my_fps>)
%       OR              vfd_fps(<my_fps>, <my_filename>)
%
% Example:              vfd_fps(120)
%       OR              vfd_fps(120, 'vid16.vfd.mat')


function outs = vfd_fps(myfps, vfdfilein)
    if(nargin<2)
        files = dir('*.vfd.mat');
        flist = cell(numel(files),1);
        for i=1:numel(files)
            flist(i,1) = cellstr(files(i).name);
        end

        for i=1:numel(flist)
            params = open(flist{i});
            if(~isfield(params, 'fps'))
                params.fps = myfps;
            end
            save(flist{i}, '-struct', 'params');
        end
        outs = numel(flist);
    else
        params = open(vfdfilein);
        if(~isfield(params, 'fps'))
            params.fps = myfps;
        end
        save(vfdfilein, '-struct', 'params');
        outs = 1;
    end
end
