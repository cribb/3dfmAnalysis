function [ p_value_ranksum ] = bayes_ranksum( LOG10_msdDA_matrix, k_norm )


cond_of_int = LOG10_msdDA_matrix(:, k_norm);
cond_of_int(isnan(cond_of_int)) = [];  % removes NaN from array

clear h p_value
for i = 1:length(LOG10_msdDA_matrix(1,:))
    
    if i ~= k_norm
        current_cond = LOG10_msdDA_matrix(:,i);
        current_cond(isnan(current_cond)) = [];  % removes NaN from array
        [p_value_ranksum(i)] = ranksum(cond_of_int, current_cond);
    else
        p_value_ranksum(i) = NaN; 
    end
    
end


end