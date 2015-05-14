function [ p_value ] = bayes_ttest2( LOG10_msdDA_matrix, k_norm )


cond_of_int = LOG10_msdDA_matrix(:, k_norm);

clear h p_value
for i = 1:length(LOG10_msdDA_matrix(1,:))
    
    if i ~= k_norm
        current_cond = LOG10_msdDA_matrix(:,i);
        [h(i), p_value(i)] = ttest2(cond_of_int, current_cond);
    else
        h(i) = NaN;
        p_value(i) = NaN; 
    end
    
end


end

