function hnd = ba_initz(visibleUI_TF)
% Prior to starting experiment, make sure the magnet is centered.  Lower
% the magnet to 0 and use the vertical micrometer to ensure the tips of the
% magnet will touch the top of a glass slide (to apply maximum force to
% bead).  Click on the apps tab and open image acquisition.  Use the
% horizontal micrometers to line up the magnet gap with the field of view.
% If done correctly, you will not see the tips of the magnets show up.  You
% may have to adjust the focus and increase the gain to see the gap with
% fluorescence.  Close image acquisition, then run the first two sections
% of this script.  Raise the motor back to 12mm by clicking the height box
% in the gui and typing the desired height.  Carefully place the sample
% under the magnet, making sure the magnet will not contact and edge of the
% chamber when it is lowered.  Close the gui, then reopen image acqusition.
% Find a region that has 20-40 beads.  Beads within a diameter from
% each other or an edge will probably not work well when tracking. Focus the region, then
% close image acquisition again.  Run the script.

if nargin < 1 || isempty(visibleUI_TF)
    visibleUI_TF = false;
end

%--- Create ActiveX Controller for the ThorLabs z-motor
% This section is mostly taken from Thorlabs APT Matlab Guide, located at:
% https://www.thorlabs.com/tutorials/APTProgramming.cfm (bottom link under
% "Matlab" section). More information can be found here: 
% http://www.mathworks.com/help/imaq/basic-image-acquisition-procedure.html

% The z-motor GUI gets docked into a matlab figure that's explicitly 
% constructed using the Matlab's default figure properties (i.e. figure '0').
fpos = get(0,'DefaultFigurePosition');
fpos(3) = 650; % Figure width
fpos(4) = 450; % Figure height
f = figure('Position', fpos, 'Menu', 'None', 'Name', 'APT GUI');

if visibleUI_TF
    f.Visible = 'on';
else
    f.Visible = 'off';
end

% Initialize Control GUI for Thorlabs z-motor control
% !regsvr64 /s C:\Program Files (x86)\Thorlabs\APT\APT Server\MG17Motor.ocx
hnd = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
hnd.StartCtrl;

% The serial number for the motor is 83829797. Must set it here and
% register/identify our connection to the motor.
set(hnd,'HWSerialNum', 83829797);
hnd.Identify; 
drawnow;

zpos = hnd.GetPosition_Position(0);

% close(f);

return