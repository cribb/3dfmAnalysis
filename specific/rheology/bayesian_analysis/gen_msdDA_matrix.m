function [ LOG10_msdDA_matrix ] = gen_msdDA_matrix( bayes_model_output )

spec_tau = 1;

for k = 1:length(bayes_model_output)

    vmsd = bayes_model_output(k,1).DA_curve_struct;
    msd_struct = msdstat(vmsd);
    
    [minval, minloc] = min( sqrt((msd_struct.mean_logtau ...
                                          - log10(spec_tau)).^2) );
    
    if isfield(msd_struct, 'msd')
        new_column = msd_struct.msd(minloc(1),:);
        
        if length(new_column) <= 500
            a = 500 - length(new_column);
            dummy_matrix = NaN(1,a);
            new_column = horzcat(new_column, dummy_matrix);   
        else
            fprintf('There are more than 500 beads.  Need to change the dummy_matrix limits.');
        end
        new_column = new_column';
    else
        new_column = NaN(1,500)';
    end
    msdDA_matrix(:,k) = new_column(:);
end


LOG10_msdDA_matrix = log10(msdDA_matrix);



end

