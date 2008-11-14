function p = poleflat(gap_distance)
% POLEFLAT Returns pole locations for pole-flat 3dfm pole geometry using gap_distance   
%
% 3DFM Function 
% magnets/simforces
% last modified 11/14/08 (krisford)
%  
% Returns pole locations for pole-flat 3dfm pole geometry with
% gap_distance being the distance between the poletip and the flat
% and the origin located halfway between the two.
%  
%  [p] = poleflat(gap_distance);  
%   
%  where "gap_distance" is in units of [meters] 

  

    flat_width = 0.008;               % standard flat-width in meters = 0.024m, but 
                                      % there's prob not anything exciting happening 
                                      % far away from poletip.
    ratio_poleflat_to_flatflat = 2;  % a guess at the ratio between gap distance and 
                                     % flat's-monopoles distances

	distance_between_flats_monopoles = (gap_distance / ratio_poleflat_to_flatflat);
	number_of_flat_monopoles = floor(flat_width/distance_between_flats_monopoles);
	
	p = zeros(number_of_flat_monopoles + 1, 3);
	
	% assume that the origin is aligned halfway between the location of the pole's
	% monopole and the flat's monopoles.  Thus the inital location of the pole's 
	% monopole is [0,-gap_distance/2,0].
	p(1,:) = -gap_distance/2 * [1 0 0];
	
	% The remaining monopoles are located on the flat-piece and thus have the 
	% same x-location, as they are aligned vertically.  
	p(2:end, 1) = gap_distance - gap_distance/2;
	
	% Their y-values are incremented from -flatwidth/2 to flatwidth/2.
	ylocs = repmat(distance_between_flats_monopoles, number_of_flat_monopoles, 1);
	ylocs = cumsum(ylocs) - flat_width/2;
	p(2:end, 2) = ylocs;
