function dmbr_adjust_report(name, topdir)
%
% Christian Stith <chstith@ncsu.edu> and Jeremy Cribb, 06-28-2012
% dmbr_adjust_report.m
% Auto-generates a GUI, Sequence Selector, that allows users to
% select/deselect individual sequences from a previous
% dmbr_multi_file_report for inclusion in a new, smaller one. Once the user
% has selected sequences and input a new analysis name, the program will
% call dmbr_multi_file_report with the new parameters.
% 
% Required Parameters:
%   name: the root name of the analysis to adjust
% Returns:
%   N/A
%
% Command Line Syntax:
%   dmbr_adjust_report(<Analysis_Name>)
% Example:
%   dmbr_multi_file_report('DataAnalysis')
%

if(nargin>1)
    cd(topdir);
end
% Open the HTML file for viewing
web([name '.html'], '-browser');
%open([name '.xlsx']);

% Create GUI figure
h.f = figure('units','pixels','position',[200,200,730,550], 'toolbar','none','menu','none', 'Name', ['Sequence Selector: ' name]);

% Open sequence data file
infile = [name '.seqdat.txt'];
fid = fopen(infile);

% Panel to which all checkboxes are relative
h.panel=uipanel(h.f, 'Units', 'pixels', 'Position',[100 540 1260 1]);

h.sideline=uipanel(h.f, 'Units', 'pixels', 'Position',[100 -5 1 560]);


% Number of checkboxes
checkelements = 0;
% Number of rows
elements = 0;

% Scan the .seqdat.txt file and create the GUI
tline = fgetl(fid);
tline2 = fgetl(fid);
line=0;
while(ischar(tline))
    line = line + 1;
    %Read in filename and bead data
    numbeads = textscan(tline2, '%d');
    checks = numbeads{:};
    checks = checks(3:end);
    numbeads = numbeads{:};
    seqs = numbeads(2);
    numbeads = numbeads(1);
    
    
    % Load filename
    fname = tline;
    if strcmp(fname, '')
        break;
    end
    % Add the filename to the file array
    filearray(line) = cellstr([fname '.vfd.mat']);

    % iterate counter
    elements = elements + 1;
    pre_elements = elements;
    % Filename display
    
    [junk fname_root ~] = fileparts(fname);
    vidID = ['vid' num2str(sscanf(fname_root, 'vid%f')) ' | (' strtrim(fname) ')'];
    
    
    % Checkbox initialization & display
    empty_file = 1;
    for b=1:numbeads
    	elements = elements + 1;
        field = ['Bead ' num2str(b) ' Sequences: '];
        empty_bead = 1;
        for c=1:seqs
            checkelements = checkelements + 1;
            if(c<=checks(b))
                h.c(checkelements) = uicontrol('Parent', h.panel, 'Value', 1, 'style','checkbox','units','pixels', 'position',[150+50*(c-1), -30*elements,45,15],'string',num2str(c));
                empty_bead = 0;
                empty_file = 0;
            else
                h.c(checkelements) = uicontrol('Value', 0, 'style','checkbox','units','pixels', 'position',[-50,-50,45,15]);
            end                
        end
        if(empty_bead)
            elements = elements - 1;
        else
            h.l(elements) = uicontrol('Parent', h.panel, 'HorizontalAlignment', 'left', 'BackgroundColor', 'yellow', 'Style', 'text', 'String', field, 'Position', [40,-30*elements, 105,15]);
        end
        
    end
    
    if(empty_file)
        elements = elements-1;
    else
        h.l(elements) = uicontrol('Parent', h.panel, 'HorizontalAlignment', 'left', 'BackgroundColor', [0.22333, 0.87, 0.11],'Style', 'text', 'String', vidID, 'Position', [20, -pre_elements*30, 1200, 15]);
    end

    
    
    tline = fgetl(fid);
    tline2 = fgetl(fid); 
end
fclose('all');



% Create slider if needed
if(elements>16)
    h.pop = uicontrol('Style', 'slider', 'Units', 'pixels', 'Position', [40 120 20 200], 'callback', @slider);
    % Get initial hpanel value for sliding
    pos=get(h.panel,'Position');   
    set(h.pop,'Value',1);
end

% Create filename input slot
h.footer = uicontrol(h.f, 'HorizontalAlignment', 'left','Style', 'text', 'String', '', 'Position', [100 0 1260 50]);
h.text = uicontrol(h.f, 'HorizontalAlignment', 'left','Style', 'text', 'String', 'Enter new filename (no extension): ', 'Position', [115 25 300 20]);
h.fname = uicontrol(h.f, 'Style', 'edit', 'String', '', 'BackgroundColor', 'white', 'HorizontalAlignment', 'left', 'Position', [115, 5, 200, 20]);


% Create Compute and Cancel pushbuttons 
h.submit = uicontrol('style','pushbutton','units','pixels', 'position',[15,15,70,20],'string','Compute','callback',@p_call);
h.cancel = uicontrol('style','pushbutton','units','pixels', 'position',[15,45,70,20],'string','Cancel','callback',@p_cancel);

    % Compute callback
    function p_call(varargin)
        checked = get(h.c,'Value');
        m = cell2mat(checked);
        if isempty(find(m, 1))
            msgbox('Please select at least one sequence.');
            return;
        end
        filename = get(h.fname, 'String');
        while isempty(filename)
            temp = inputdlg('Please enter a new filename: ');
            if(isempty(temp) || isempty(temp{1}))
                return;
            end
            filename = temp{1};
        end
        close(gcf);
        pause(0.1);
        % Compute new report, with new filename
        dmbr_multi_file_report(filename, checked, filearray);
    end

    % Cancel callback
    function p_cancel(varargin)
        close(gcf);
        pause(0.1);
    end

    % Slider callback
    function slider(varargin)
        % read the value of the slider
        slidervalue=get(h.pop,'Value');
        % scale adjustments to length of GUI
        scale = 30*(elements-16);
        slidervalue = slidervalue * scale;
        set(h.panel,'Position',[pos(1) pos(2)-slidervalue+scale pos(3) pos(4)]);
    end

end
