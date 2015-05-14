function [ skewnessDA_array, kurtosisDA_array, p_value_SW ] = bayes_normalityTest( LOG10_msdDA_matrix )


for i = 1:length(LOG10_msdDA_matrix(1,:))
   
    skewnessDA_array(i) = skewness(LOG10_msdDA_matrix(:,i), 0);
    kurtosisDA_array(i) = kurtosis(LOG10_msdDA_matrix(:,i), 0);
    
    current_col = LOG10_msdDA_matrix(:,i);
    current_col(isnan(current_col)) = [];  % removes NaN from array
    
    if length(current_col) > 3
        
        [h psw W] = swtest(LOG10_msdDA_matrix(:,i));
        p_value_SW(i) = psw;

    else
        p_value_SW(i) = NaN;
    end
end


end
