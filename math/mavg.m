function v = moving_average(data, kernel_size)

    wn = kernel_size;
    
    for k = 1 : size(data, 2)
        filtdata(:,k) = conv(data(:,k), ones(wn,1).*1/wn);
    end
    
    v = filtdata(wn:end-(wn-1),:);
    
    