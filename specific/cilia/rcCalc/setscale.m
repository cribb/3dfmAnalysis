%This function takes user input and sets the scale for radius
%curvature calculations


function [units, p_ratio] = setscale()

    %Dialog Box for units and scale bar length
    prompt = {'Enter units:','Enter scale bar length:'};
    dlg_title = 'Set scale';
    num_lines = 1;
    def = {'units','scale bar length'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
     
    units = answer{1};
    sblength = str2num(answer{2});

    %Get scale bar image length
    waitfor(msgbox('Click both ends of scale bar'));
    points = ginput(2);
    sbimage = sqrt((points(1,1)-points(2,1))^2+(points(1,2)-points(2,2))^2);

    %Set p_ratio
    p_ratio = sblength/sbimage;

