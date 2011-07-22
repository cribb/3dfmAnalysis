function outs = pan_cell2well(coord, plate_type)

    if ischar(coord)
        coord = cellstr(coord);
    end
   
    coordROWc = regexpi(coord, '[A-Z]*', 'match');
    for k =1:length(coordROWc); coordROWc(k) = coordROWc{k}; end
   
    coordCOLc  = regexpi(coord, '[0-9]*', 'match');
    for k =1:length(coordCOLc); coordCOLc(k) = coordCOLc{k}; end
    
    for k =1:length(coordROWc); 
        coordROWn(k)  = double(upper(coordROWc{k})) - double('A') + 1;
    end
    
    for k =1:length(coordCOLc);
        coordCOLn(k)  = str2num(coordCOLc{k});    
    end
    
    switch plate_type
        case '96well'
            list = reshape(1:96, 12, 8)';
        case '384well'
            list = reshape(1:384, 24, 16)';
    end
    
    for k = 1:length(coordROWn)
        outs(k) = list(coordROWn(k), coordCOLn(k));
    end