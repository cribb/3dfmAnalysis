function mcumap = pan_compute_MCU_heatmap(metadata)

    % MCU parameter heatmap
    mcumap = NaN(1,96);
    for wellIDX = 1:96
        mywell = find(metadata.mcuparams.well == wellIDX);
        if ~isempty(mywell)
            mcumap(wellIDX) = mean( metadata.mcuparams.mcu(mywell) );
        else
            mcumap(wellIDX) = NaN;
        end
    end
    
    mcumap = pan_array2plate(mcumap);
    
return;