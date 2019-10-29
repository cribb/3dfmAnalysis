function update_livehistogram_display(obj,event,hImage)
% This callback function updates the displayed frame and the histogram.

% Copyright 2007-2017 The MathWorks, Inc.
%

% Display the current image frame.
set(hImage, 'CData', event.Data);

% Select the second subplot on the figure for the histogram.
subplot(1,2,2);

% Plot the histogram. Choose 128 bins for faster update of the display.
imhist(event.Data, 128);

% Refresh the display.
drawnow

