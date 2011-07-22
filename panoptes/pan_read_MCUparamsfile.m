function outs = pan_read_MCUparamsfile( infile )

    if isstruct(infile)
        infile = infile.name;
    end

    WELL = 1;
    PASS = 2;
    MCUNUM = 3;

    % set delimiter to be a "space"
    dlim = ' ';
    cmntstr = '//';

    if ~isempty(dir(infile))
        data = dlmread(infile, dlim, 1, 0);
    else
        error('file not found');
    end

    outs.well = data(:,WELL);
    outs.pass = data(:,PASS);
    outs.mcu  = data(:,MCUNUM);

return;