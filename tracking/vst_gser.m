function [ve_out, ve_err] = vst_gser(DataIn)
% VST_GSER computes viscoelastic moduli using MSDs outputted by VST_MSD.
%
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  



% Pull out the well numbers from the "wellXX" Sample Instance strings
pT = DataIn.VidTable;
tmp = cellfun(@(x1)(regexpi(x1, 'well(\d*)', 'tokens')), pT.SampleInstance);
pT.Well_ID = cellfun(@str2double, tmp);

% Build table that combines File ID and Solution and Bead parameters
bd = innerjoin(pT(:,{'Fid','Well_ID'}), DataIn.Plate.Bead(:,{'Well_ID','diameter'}));
bd.diameter = str2double(bd.diameter);

msdB = innerjoin(DataIn.MsdTable, bd);
msdFilt_um2 = msdB.MsdX + msdB.MsdY;
msdOrig_um2 = msdB.MsdXo + msdB.MsdYo;

% These are the 2D MSDs (Xmsd+Ymsd) for the "filtered" (drift-subtracted) and
% "original" trajectories.
msdFiltOrig_um2 = [msdFilt_um2, msdOrig_um2];

msdFiltOrig_m2 = msdFiltOrig_um2 * 1e-12;

bead_radius_m = (msdB.diameter / 2) * 1e-6;

ve_out = ve_calc_engine(msdB.Fid, msdB.ID, msdB.Tau_s, msdFiltOrig_m2, bead_radius_m);
ve_out = attach_table_metadata(ve_out);


return

function ve_err = calc_ve_err(ve_out, ve_min)

    ve_err(:, 3:22) = abs( table2array(ve_out(:,3:22)) - table2array(ve_min(:,3:22)));
    ve_err = array2table(ve_err);
    
return


function outs = ve_calc_engine(Fid, BeadID, Tau_s, msdFiltOrig_m2, bead_radius_m)

    [g, ~] = findgroups(Fid, BeadID);
    tmp = splitapply(@(x1,x2,x3,x4,x5){splitapply_ve(x1,x2,x3,x4,x5)}, ...
                                             Fid, ...
                                             BeadID, ...
                                             Tau_s, ...
                                             msdFiltOrig_m2, ...
                                             bead_radius_m, ...
                                             g); 
    tmp = cell2mat(tmp);                                     
    outs.Fid = tmp(:, 1);
    outs.ID = tmp(:,2);
    outs.Freq_Hz = 1 ./ tmp(:,3);
    outs.Alpha = tmp(:,4);
    outs.Gp = tmp(:,6);
    outs.Gpp = tmp(:,8);
    outs.Np = tmp(:,10);
    outs.Npp = tmp(:,12);
    outs.AlphaOrig = tmp(:,5);
    outs.GpOrig = tmp(:,7);
    outs.GppOrig = tmp(:,9);
    outs.NpOrig = tmp(:,11);
    outs.NppOrig = tmp(:,13);
    outs = struct2table(outs);

return

function outs = attach_table_metadata(outs)
    outs.Properties.Description = 'Complex Shear Modulus in [Pa]';
    outs.Properties.VariableNames = {'Fid', 'ID', 'Freq_Hz', ...
                                     'Alpha', 'Gp', 'Gpp', 'Np', 'Npp', ...
                                     'AlphaOrig', 'GpOrig', 'GppOrig', 'NpOrig', 'NppOrig'};
                                     
    outs.Properties.VariableDescriptions = { 'FileID (key)', ...
                                             'Bead ID', ...
                                             'Frequency',...
                                             'Power-law slope over frequency, filtered', ...
                                             'Storage Modulus over frequency, filtered', ...
                                             'Loss Modulus over frequency, filtered', ...
                                             'Real viscosity over frequency, filtered', ...
                                             'Elasticity over frequency, filtered', ...
                                             'Power-law slope over frequency, original', ...
                                             'Storage Modulus over frequency, original', ...
                                             'Loss Modulus over frequency, original', ...
                                             'Real viscosity over frequency, original', ...
                                             'Elasticity over frequency, original' };    
    
    alphaU = '[log_{10}(m^2)/log_{10}(s)]';

    outs.Properties.VariableUnits = {'', '', 'Hz', ...
                                     alphaU, '[Pa]', '[Pa]', '[Pa s]', '[Pa s]', ...
                                     alphaU, '[Pa]', '[Pa]', '[Pa s]', '[Pa s]'};

return


function q = splitapply_ve(fid, beadid, tau_s, msdXYXoYo_m2, bead_radius_m)   
    
    v = gser(tau_s, msdXYXoYo_m2, bead_radius_m);
    
    AlphaFiltOrig = v.alpha;
    GpFiltOrig = v.gp;
    GppFiltOrig = v.gpp;
    NpFiltOrig = v.np;
    NppFiltOrig = v.npp;
    
    q = [fid, beadid, tau_s, ...
         AlphaFiltOrig, GpFiltOrig, GppFiltOrig, ...
                      NpFiltOrig, NppFiltOrig ];
    
return

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'vst_gser: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    