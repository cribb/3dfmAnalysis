function cap = tareport(filename, nametag)
% TAREPORT Generates an html report file(s) for rheology tests done on a particular sample
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
%  
% Generates an html report file(s) for rheology tests done on a particular sample.
% Includes all TA txt files that match 'filename' and reports the results
% in a root html file with figures saved in several formats (.fig for matlab 
% manipulation, .png as raster image for quick insertion into reports, and 
% .svg as vectorized image for ease of making publication quality images).
% 
%  cap = tareport(filename, nametag) 
%   
% where "cap" is the output cone and plate data structure
% "filename" is the name of a text file outputted from TA software package 
%            where wildcards can be used (*.rsl.txt).
%  "nametag" is a string with generic title for tested sample.
%

% load data from cone and plate
cap = ta2mat(filename);

% generate plots as indicated by data
figs = taplot(cap, nametag);

% make figures presentable w.r.t. relative font sizes, etc...
% filename conditioning
outf = cap.global_protocol.results_file_name;
outf = strrep(outf, ' ', '_');


for k = 1:length(figs)
    gen_pub_plotfiles(outf, figs(k), 'normal');
    close(figs(k));
end

fn = fieldnames(cap.experiments);

% % START REPORT GENERATION TO HTML PAGE
outfile = [outf '.html'];
fid = fopen(outfile, 'w');

% html code
fprintf(fid, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" ');
fprintf(fid, '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> \n');
fprintf(fid, '<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">\n\n');
fprintf(fid, '<head> \n');
fprintf(fid, '<title> CAP: %s </title>\n', nametag);
fprintf(fid, '</head>\n\n');
fprintf(fid, '<body>\n\n');

fprintf(fid, '<h1> CAP: %s </h1> \n\n', nametag);
fprintf(fid, '<p> \n');
fprintf(fid, '   <b>Sample Name:</b>  %s <br/>\n', nametag);
fprintf(fid, '   <b>Path:</b>  %s <br/>\n', pwd);
fprintf(fid, '   <b>Filename:</b>  %s \n', outfile);
fprintf(fid, '</p> \n\n');
fprintf(fid, '<p> \n');
fprintf(fid, '   <b>TA Procedure:</b>  %s <br/>\n', cap.global_protocol.procedure_name);
fprintf(fid, '   <b>Experiment Date/Time:</b>  %s \n', cap.file_header.datetime);
fprintf(fid, '</p> \n\n');

% Geometry summary
fprintf(fid, ' <p> \n');
fprintf(fid, '     <b>Geometry</b> <br/> \n');
fprintf(fid, '     <b>Type:</b> %s <br/> \n', cap.geometry.geometry_name);
fprintf(fid, '     <b>Sample Vol:</b> %s \n', cap.geometry.approximate_sample_volume);
fprintf(fid, ' </p> \n\n');

% Short list of tests in procedure
fprintf(fid, ' <p> \n');
fprintf(fid, '    <b> Procedure </b> <br/> \n');
for k = 1:length(fn)
    fprintf(fid, ' %s <br/> \n', strrep(fn{k},'_', ' '));
end
fprintf(fid, '</p>\n\n');



% Produce results from each procedural section
fprintf(fid, '<table border="2" cellpadding="6"> \n');
count = 1;
for k = 1 : length(fn)
   
    myfn = fn{k};
    
    if isfield(getfield(cap.experiments, myfn), 'table');

        % extract each table's information and plot
        st  = getfield(cap.experiments, myfn);
        
        testnum = myfn(regexp(myfn, '[0-9]'));
        if isempty(testnum); testnum='1'; end;
        exptype = lower(st.metadata.step_name);
        
        fprintf(fid, ' <tr>\n  <td align="left" width="200">\n    <b> %s </b> <br/> \n', st.metadata.step_name);
        
        if findstr(exptype, 'stress sweep');
            ssweepimg = [outf '-ssweep' testnum];
            sfreq = mean(st.table(:,get_TA_col(st, 'ang. frequency')));
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    <b> angular frequency: </b> %s rad/s (%s Hz) <br/> \n',num2str(sfreq),num2str(sfreq/(2*pi)));
            fprintf(fid, '    <b> temperature: </b> %s ºC <br/> \n', num2str(temp));
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [ssweepimg '.fig']);
            fprintf(fid, '      <img src="%s" width="400" height="300" border="0"></img> \n', [ssweepimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end
        
        if findstr(exptype, 'strain sweep')
            nsweepimg = [outf '-nsweep' testnum];
            sfreq = mean(st.table(:,get_TA_col(st, 'ang. frequency')));
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    <b> angular frequency: </b> %s rad/s (%s Hz) <br/> \n',num2str(sfreq),num2str(sfreq/(2*pi)));
            fprintf(fid, '    <b> temperature: </b> %s ºC<br/> \n', num2str(temp));
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [nsweepimg '.fig']);
            fprintf(fid, '      <img src="%s" width="400" height="300"></img> \n', [nsweepimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end
        
        if findstr(exptype, 'frequency sweep')
            freqimg = [outf '-fsweep' testnum];
            samp = st.table(:,get_TA_col(st, 'osc. stress'));
            namp = st.table(:,get_TA_col(st, 'strain'));       
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    <b> Stress amplitude: </b> %s +- %s Pa <br/> \n',num2str(mean(samp)),num2str(stderr(samp)));
            fprintf(fid, '    <b> Strain amplitude: </b> %s +- %s  <br/> \n',num2str(mean(namp)),num2str(stderr(namp)));
            fprintf(fid, '    <b> temperature: </b> %s ºC<br/> \n', num2str(temp));
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [freqimg '.fig']);
            fprintf(fid, '      <img src="%s" width="400" height="300"></img> \n', [freqimg '.svg']);
            fprintf(fid, '    </a>');            
            fprintf(fid, '  </td>\n </tr>\n\n');
        end

        if findstr(exptype, 'creep')
            appval = st.metadata.applied_value;
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            creepimg = [outf '-creep' testnum];
            fprintf(fid, '    <b> Applied Value: </b> %s <br/> \n',appval);
            fprintf(fid, '    <b> Temperature: </b> %s ºC<br/> \n', num2str(temp));
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [creepimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [creepimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end

        if findstr(exptype, 'recovery')
            appval = st.metadata.applied_value;
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            creepimg = [outf '-recov' testnum];
            fprintf(fid, '    <b> Applied Value: </b> %s <br/> \n',appval);
            fprintf(fid, '    <b> Temperature: </b> %s ºC<br/> \n', num2str(temp));
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [creepimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [creepimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end
        
        if findstr(exptype, 'flow');
            flowimg = [outf '-flow' testnum];
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    <b> Temperature: </b> %s ºC<br/> \n', num2str(temp));            
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [flowimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [flowimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end
        
        if findstr(exptype, 'temperature');
            tempimg = [outf '-temp' testnum];
            appval = st.metadata.controlled_variable;
            fprintf(fid, '     %s \n', appval);            
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [tempimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [tempimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end

        if findstr(exptype, 'peak hold');
            tempimg = [outf '-peakstrain' testnum];
            appval = st.metadata.controlled_variable;
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    %s \n', appval);            
            fprintf(fid, '    <b> Temperature: </b> %s ºC<br/> \n', num2str(temp));            
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [tempimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [tempimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end

        if findstr(exptype, 'relaxation');
            tempimg = [outf '-relax' testnum];
            appval = st.metadata.applied_value;
            temp = mean(st.table(:,get_TA_col(st, 'temperature')));
            fprintf(fid, '    <b> strain: </b> %s <br/> \n', appval);            
            fprintf(fid, '    <b> Temperature: </b> %s ºC<br/> \n', num2str(temp));            
            fprintf(fid, '  </td>\n  <td align="center" width="425">\n');
            fprintf(fid, '    <a href="%s">', [tempimg '.fig']);
            fprintf(fid, '     <img src="%s" width="400" height="300"></img> \n', [tempimg '.svg']);
            fprintf(fid, '    </a>');
            fprintf(fid, '  </td>\n </tr>\n\n');
        end
        
        count = count + 1;        
    end
        
end

fprintf(fid, '</table>\n\n');
fprintf(fid, '</body> \n');
fprintf(fid, '</html> \n\n');

fclose(fid);

return;


