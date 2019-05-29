function outs = ba_discoverbeads(firstframe, lastframe, search_radius_low, search_radius_high)
% 
% calibum = 0.346; % [um/pixel]
% width = 1024;
% height = 768;
% bead_dia_um = 24;
% bead_dia_pix = bead_dia_um / calibum;
% bead_radius_pixels = bead_dia_pix / 2;
% 
% % Explain why
% disk_element_radius = floor(bead_radius_pix * 0.9);
% 
% SE = strel('disk', disk_element_radius);
% 
% search_radius_low  = floor(bead_radius_pixels * 0.4);
% search_radius_high =  ceil(bead_radius_pixels * 0.8);
% 

[imfcenters, imfradii] = imfindcircles(firstframe, ...
                                       [search_radius_low, search_radius_high], ...
                                       'ObjectPolarity', 'bright', ...
                                       'Sensitivity', 0.92);

[imlcenters, imlradii] = imfindcircles(lastframe, ...
                                       [search_radius_low, search_radius_high], ...
                                       'ObjectPolarity', 'bright', ...
                                       'Sensitivity', 0.92);

end
