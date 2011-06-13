function[] = separating_beads_by_FOV( basepath )
% This function re-assembles all the individual bead trajectories from the
% files in "Bead_Tracking\ddposum_files\individual_beads\" into one large
% matrix. Each field of view is separated from the others by 800um, so that
% the two point analysis does not try to correlate beads from different
% fields of view. This single matrix enables for more robust averaging
% between fields of view, as all the processing is done in one step.
% Follows "rg_matrix_many_single_beads".
%
% INPUTS
%
% basepath - the base path for the experiment. It looks for the bead files
% in "Bead_Tracking\ddposum_files\individual_beads\" and uses the
% "correspondance_rg" file to determine the FOV number and Rg of individual
% trajectories.
%
% OUTPUTS
%
% Creates a subfolder called "2pt_msd" where it creates a file called
% "beads_separated_by_FOV" containing "posstot", to be loaded in Matlab to send to twopoint.
%
% posstot matrix format:
% 1 row per bead per time
% columns:
% 1:2 - X and Y position (in micrometers) + 800um * FOV number
% 3   - frame #
% 4   - bead #

load([basepath 'Bead_Tracking\ddposum_files\individual_beads\correspondance'])
    % Correspondense: Matrix with columns [FOV #, bead #, row #]

% Make directory to place 2pt data
twoptpath = '2pt_msd';
[status, message, messageid] = mkdir([basepath twoptpath]);

% Initialize posstot matrices
posstot = [];
posstot1= [];

% For loop across all beads
for bead = 1:size(correspondance, 1)
    % load individual bead data (bsec) gotten from getting_individual_beads
    load([basepath 'Bead_Tracking\ddposum_files\individual_beads\bead_' num2str(bead)])
    % shifting space data by (FOV-1)*800 to not have interference
    bsec2(:,1:2) = bsec(:,1:2) + 800*(correspondance(bead,1)-1);
    % keep frame number from bsec
    bsec2(:,3) = bsec(:,3);
    % record which bead in column 4
    bsec2(:,4) = bead;
    posstot1 = [posstot1;bsec2];
    clear bsec2
    % clearing out posstot1 every 50 beads for speed
    if mod(bead,50) == 0
        posstot=[posstot; posstot1];
        posstot1=[];
        disp(['Finished adding bead ' num2str(bead) '.'])
    end
end

posstot=[posstot; posstot1];

save([basepath twoptpath '\beads_separated_by_FOV'],'posstot')

    