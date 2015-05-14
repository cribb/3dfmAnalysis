function [model, prob] = bayes_assign_model(bayes_results)
%BAYES_ASSIGN_MODEL 
%   COMMENTS



model = [' '];
prob = NaN;


if bayes_results.mean_curve.N.PrM > 0.5
    model = 'N';
    prob = bayes_results.mean_curve.N.PrM;
end

if bayes_results.mean_curve.D.PrM > 0.5
    model = 'D';
    prob = bayes_results.mean_curve.D.PrM;
end

if bayes_results.mean_curve.DA.PrM > 0.5
    model = 'DA';
    prob = bayes_results.mean_curve.DA.PrM;
end

if bayes_results.mean_curve.DR.PrM > 0.5
    model = 'DR';
    prob = bayes_results.mean_curve.DR.PrM;
end

if bayes_results.mean_curve.V.PrM > 0.5
    model = 'V';
    prob = bayes_results.mean_curve.V.PrM;
end

% if bayes_results.mean_curve.DV.PrM > 0.5
%     model = 'DV';
%     prob = bayes_results.mean_curve.DV.PrM;
% end
% 
% if bayes_results.mean_curve.DAV.PrM > 0.5
%     model = 'DAV';
%     prob = bayes_results.mean_curve.DAV.PrM;
% end
% 
% if bayes_results.mean_curve.DRV.PrM > 0.5
%     model = 'DRV';
%     prob = bayes_results.mean_curve.DRV.PrM;
% end





end

