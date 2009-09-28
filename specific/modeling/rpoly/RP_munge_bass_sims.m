function sim_out = RP_munge_bass_sims(infile, outfile)
%RP_MUNGE_BASS_SIMS combines modeling .mat files from the UNC-CH BASS supercomputer
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%
% RP_MUNGE_BASS_SIMS will combine several single-parameter set ROLIE-POLY
% .mat files from the same batch sent to the BASS supercomputer. and 
% to the
% input parameters.  If one of the parameters is a vector, RP_MULTISIM will
% attempt to execute several runs concurrently.  On multi-processor
% machines this results in faster modeling for a suite of parameters.
%
% NOTE: for multi-threading, the Parallel Computing toolbox is required.
%
% [sim_out] = RP_munge_bass_sims(infile, outfile)
%
% where   "sim_out" is a structure containing the parameter and resulting
%                   modeling data.
%         "infile"  is the input filemask with '*' wildcard placed where the
%                   iterated numbers exist in the input filenames.
%         "outfile" is the output filename where the collected data are saved                  saved.
%                   (not mandatory)
%

filelist = dir(infile);

for k = 1:length(filelist)
    
    rp = open(filelist(k).name);
    
    if isfield(rp, 'sim')
        rp = rp.sim;
    end
    
    fields = fieldnames(rp);

    
    for m = 1:length(fields)
        
        if k == 1
            sim_out = rp;
        else
            foo = getfield(rp, fields{m});
            sz = size(foo);
            dim = size(sz,2);

            oldfield = getfield(sim_out, fields{m});

            sim_out = setfield(sim_out, fields{m}, cat(dim,oldfield,foo));
        end
        
        if exist(outfile)
            try
                save(outfile, '-STRUCT', 'sim_out');
            catch
                warning('File not saved.  Something wrong with filename?');
            end
        end
        
    end
end

