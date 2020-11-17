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

msdE = innerjoin(DataIn.summary.msdEnsembleTable, bd);

logmsdXYXoYo_um = [msdE.logmsdX, msdE.logmsdY, msdE.logmsdXo, msdE.logmsdYo];
logerrXYXoYo_um = [msdE.errmsdX, msdE.errmsdY, msdE.errmsdXo, msdE.errmsdYo];

logmsderrh = (logmsdXYXoYo_um + logerrXYXoYo_um);
logmsderrl = (logmsdXYXoYo_um - logerrXYXoYo_um);

msdXYXoYo_um2 = 10 .^ (logmsdXYXoYo_um);
msderrLowXYXoYo_um2 = 10 .^ (logmsderrl);

msdXYXoYo_m2 = msdXYXoYo_um2 * 1e-12;
msderrLowXYXoYo_m2 = msderrLowXYXoYo_um2 * 1e-12;

bead_radius_m = (msdE.diameter / 2) * 1e-6;

ve_out = ve_calc_engine(msdE.Fid, msdE.Tau_s, msdXYXoYo_m2, bead_radius_m);
ve_out = attach_table_metadata(ve_out);

ve_min = ve_calc_engine(msdE.Fid, msdE.Tau_s, msderrLowXYXoYo_m2, bead_radius_m);
ve_min = attach_table_metadata(ve_min);

ve_err = calc_ve_err(ve_out, ve_min);
ve_err = attach_table_metadata(ve_err);

return

function ve_err = calc_ve_err(ve_out, ve_min)

    ve_err(:, 1:2) = table2array(ve_min(:,{'Fid', 'Freq_Hz'}));
    ve_err(:, 3:22) = abs( table2array(ve_out(:,3:22)) - table2array(ve_min(:,3:22)));
    ve_err = array2table(ve_err);
    
return


function outs = ve_calc_engine(Fid, Tau_s, msdXYXoYo_m2, bead_radius_m)

    [g, ~] = findgroups(Fid);
    tmp = splitapply(@(x1,x2,x3,x4){splitapply_ve(x1,x2,x3,x4)}, ...
                                             Fid, ...
                                             Tau_s, ...
                                             msdXYXoYo_m2, ...
                                             bead_radius_m, ...
                                             g); 
    tmp = cell2mat(tmp);                                     
    outs.Fid = tmp(:, 1);
    outs.Freq_Hz = 1 ./ tmp(:,2);
    outs.AlphaX = tmp(:,3);
    outs.AlphaY = tmp(:,4);
    outs.AlphaXo = tmp(:,5);
    outs.AlphaYo = tmp(:,6);
    outs.GpX = tmp(:,7);
    outs.GpY = tmp(:,8);
    outs.GpXo = tmp(:,9);
    outs.GpYo = tmp(:,10);
    outs.GppX = tmp(:,11);
    outs.GppY = tmp(:,12);
    outs.GppXo = tmp(:,13);
    outs.GppYo = tmp(:,14);
    outs.NpX = tmp(:,15);
    outs.NpY = tmp(:,16);
    outs.NpXo = tmp(:,17);
    outs.NpYo = tmp(:,18);
    outs.NppX = tmp(:,19);
    outs.NppY = tmp(:,20);
    outs.NppXo = tmp(:,21);
    outs.NppYo = tmp(:,22);
    outs = struct2table(outs);

return

function outs = attach_table_metadata(outs)
    outs.Properties.Description = 'Complex Shear Modulus in [Pa]';
    outs.Properties.VariableNames = {'Fid', 'Freq_Hz', ...
                                     'AlphaX', 'AlphaY', 'AlphaXo', 'AlphaYo', ...
                                     'GpX', 'GpY', 'GpXo', 'GpYo', ...
                                     'GppX', 'GppY', 'GppXo', 'GppYo', ...
                                     'NpX', 'NpY', 'NpXo', 'NpYo', ...
                                     'NppX', 'NppY', 'NppXo', 'NppYo' };
                                     
    outs.Properties.VariableDescriptions = { 'FileID (key)', ...
                                               'Frequency',...
                                                 'Power-law slope over frequency, X (filtered)', ...
                                                 'Power-law slope over frequency, Y (filtered)', ...                                                 'Mean-squared displacements over Tau, X (filtered)', ...
                                                 'Power-law slope over frequency, Xo (original)', ...
                                                 'Power-law slope over frequency, Yo (original)', ...                                                 'Mean-squared displacements over Tau, X (filtered)', ...
                                                 'Storage Modulus over frequency, X (original)', ...
                                                 'Storage Modulus over frequency, Y (original)', ...
                                                 'Storage Modulus over frequency, Xo (filtered)', ...
                                                 'Storage Modulus over frequency, Yo (filtered)', ...
                                                 'Loss Modulus over frequency, X (original)', ...
                                                 'Loss Modulus over frequency, Y (original)', ...
                                                 'Loss Modulus over frequency, Xo (filtered)', ...
                                                 'Loss Modulus over frequency, Yo (filtered)', ...
                                                 'Real viscosity over frequency, X (original)', ...
                                                 'Real viscosity over frequency, Y (original)', ...
                                                 'Real viscosity over frequency, Xo (filtered)', ...
                                                 'Real viscosity over frequency, Yo (filtered)', ...
                                                 'Elastic viscosity over frequency, X (original)', ...
                                                 'Elastic viscosity over frequency, Y (original)', ...
                                                 'Elastic viscosity over frequency, Xo (filtered)', ...
                                                 'Elastic viscosity over frequency, Yo (filtered)' };    
    
    alphaU = '[log_{10}(m^2)/log_{10}(s)]';

    outs.Properties.VariableUnits = {'', 'Hz', ...
                                       alphaU, alphaU, alphaU, alphaU, ...
                                       '[Pa]', '[Pa]', '[Pa]', '[Pa]', ...
                                       '[Pa]', '[Pa]', '[Pa]', '[Pa]', ...
                                       '[Pa s]', '[Pa s]', '[Pa s]', '[Pa s]', ...
                                       '[Pa s]', '[Pa s]', '[Pa s]', '[Pa s]' };

return


function q = splitapply_ve(fid, tau_s, msdXYXoYo_m2, bead_radius_m)   
    
    v = gser(tau_s, msdXYXoYo_m2, bead_radius_m);
    
    AlphaXYXoYo = v.alpha;
    GpXYXoYo = v.gp;
    GppXYXoYo = v.gpp;
    NpXYXoYo = v.np;
    NppXYXoYo = v.npp;
    
    q = [fid, tau_s, ...
         AlphaXYXoYo, GpXYXoYo, GppXYXoYo, ...
                      NpXYXoYo, NppXYXoYo ];
    
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