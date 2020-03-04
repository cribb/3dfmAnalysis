function [ space ] = CreateGaussScaleSpace( data, deriv, scales )
% space = CreateGaussScaleSpace( data, deriv, scales )
% Computes the Gaussian scale space of a 1D data set.  (Scale parameters
% are in data-spacing units.)
% Input:
%   data        One or more sets of equally-sampled 1D data, separated column-wise 
%   deriv       The order of Gaussian scale space to compute (e.g. 0 is a
%               smoothing scale space; 1 is an edge detecting scale space)
%   scales      A list (vector) of scales to compute
% Output:
%   space       A scale space representation of the input data

% defaults
if (nargin < 3)
    scales = 1:20;
end

if (nargin < 2)
    deriv = 0;
end

for j = 1:size(data,2)
    for i = 1:length(scales)
        scale = scales(i);

        % Find the gaussian kernel, convolve
        g = GaussianKernel1D(scale, deriv);

        % we have to pad the data to avoid the derivative blowing up at the
        % boundaries
        padData = [data(1,j)*ones(length(g),1); data(:,j); data(end,j)*ones(length(g),1)];
        fData = conv(padData, g);

        % Resize the filtered data
        offset = (length(fData) - size(data,1)) / 2;
        fData = fData(offset:offset+size(data,1)-1);
        space(:,j,i) = fData;
    end
end

space = squeeze(space);
