function v = rms(d)
% computes the root-mean-square of d
%    v = rms(d)

  v = sqrt(mean(d.^2));