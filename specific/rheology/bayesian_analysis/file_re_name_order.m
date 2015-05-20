function [ re_name_order ] = file_re_name_order( filepath )
%
%

cd(filepath)


% movefile('aggregated_data_noise.vrpn.evt.mat',   'aggregated_data_1.NF.vrpn.evt.mat');
% movefile('aggregated_data_HPDE.vrpn.evt.mat',    'aggregated_data_2.DE.vrpn.evt.mat');
% movefile('aggregated_data_HPDEcc.vrpn.evt.mat',  'aggregated_data_3.CC.vrpn.evt.mat');
% movefile('aggregated_data_H-ras.vrpn.evt.mat',   'aggregated_data_4.H-.vrpn.evt.mat');
% movefile('aggregated_data_Myr-AKT.vrpn.evt.mat', 'aggregated_data_5.My.vrpn.evt.mat');
% movefile('aggregated_data_TGFBR1.vrpn.evt.mat',  'aggregated_data_6.R1.vrpn.evt.mat');
% movefile('aggregated_data_Bcl2.vrpn.evt.mat',    'aggregated_data_7.B2.vrpn.evt.mat');
% movefile('aggregated_data_HPNE.vrpn.evt.mat',    'aggregated_data_8.NE.vrpn.evt.mat');

movefile('aggregated_data_A.vrpn.evt.mat',  'aggregated_data_1.A.vrpn.evt.mat');
movefile('aggregated_data_B.vrpn.evt.mat',  'aggregated_data_2.B.vrpn.evt.mat');
movefile('aggregated_data_C.vrpn.evt.mat',  'aggregated_data_3.C.vrpn.evt.mat');
movefile('aggregated_data_D.vrpn.evt.mat',  'aggregated_data_4.D.vrpn.evt.mat');
movefile('aggregated_data_E.vrpn.evt.mat',  'aggregated_data_5.E.vrpn.evt.mat');
movefile('aggregated_data_F.vrpn.evt.mat',  'aggregated_data_6.F.vrpn.evt.mat');
movefile('aggregated_data_G.vrpn.evt.mat',  'aggregated_data_7.G.vrpn.evt.mat');
movefile('aggregated_data_H.vrpn.evt.mat',  'aggregated_data_8.H.vrpn.evt.mat');

% movefile('aggregated_data_NE_1_FN.vrpn.evt.mat',   'aggregated_data_1.FN1.vrpn.evt.mat');
% movefile('aggregated_data_NE_2_FN.vrpn.evt.mat',    'aggregated_data_2.FN2.vrpn.evt.mat');
% movefile('aggregated_data_NE_1_CollI.vrpn.evt.mat',  'aggregated_data_3.Co1.vrpn.evt.mat');
% movefile('aggregated_data_NE_2_CollI.vrpn.evt.mat',   'aggregated_data_4.Co2.vrpn.evt.mat');


% movefile('aggregated_data_N1.vrpn.evt.mat',    'aggregated_data_01.NF1.vrpn.evt.mat');
% movefile('aggregated_data_N2.vrpn.evt.mat',    'aggregated_data_02.NF2.vrpn.evt.mat');
% movefile('aggregated_data_IF1.vrpn.evt.mat',   'aggregated_data_03.IF1.vrpn.evt.mat');
% movefile('aggregated_data_IF2.vrpn.evt.mat',   'aggregated_data_04.IF2.vrpn.evt.mat');
% movefile('aggregated_data_IC1.vrpn.evt.mat',   'aggregated_data_05.IC1.vrpn.evt.mat');
% movefile('aggregated_data_IC2.vrpn.evt.mat',   'aggregated_data_06.IC2.vrpn.evt.mat');
% movefile('aggregated_data_IP1.vrpn.evt.mat',   'aggregated_data_07.IP1.vrpn.evt.mat');
% movefile('aggregated_data_IP2.vrpn.evt.mat',   'aggregated_data_08.IP2.vrpn.evt.mat');
% movefile('aggregated_data_SF1.vrpn.evt.mat',   'aggregated_data_09.SF1.vrpn.evt.mat');
% movefile('aggregated_data_SF2.vrpn.evt.mat',   'aggregated_data_10.SF2.vrpn.evt.mat');
% movefile('aggregated_data_SC1.vrpn.evt.mat',   'aggregated_data_11.SC1.vrpn.evt.mat');
% movefile('aggregated_data_SC2.vrpn.evt.mat',   'aggregated_data_12.SC2.vrpn.evt.mat');
% movefile('aggregated_data_SP1.vrpn.evt.mat',   'aggregated_data_13.SP1.vrpn.evt.mat');
% movefile('aggregated_data_SP2.vrpn.evt.mat',   'aggregated_data_14.SP2.vrpn.evt.mat');



%%% RhoA Inhibition Experiment with Y-27632 %%%

% movefile('aggregated_data_NF.vrpn.evt.mat',        'aggregated_data_1.NF.vrpn.evt.mat');
% movefile('aggregated_data_Igrov.vrpn.evt.mat',     'aggregated_data_2.I.vrpn.evt.mat');
% movefile('aggregated_data_I_1uM_Y.vrpn.evt.mat',   'aggregated_data_3.I_1uM.vrpn.evt.mat');
% movefile('aggregated_data_I_5uM_Y.vrpn.evt.mat',   'aggregated_data_4.I_5uM.vrpn.evt.mat');
% movefile('aggregated_data_Skov.vrpn.evt.mat',     'aggregated_data_5.S.vrpn.evt.mat');
% movefile('aggregated_data_S_1uM_Y.vrpn.evt.mat',   'aggregated_data_6.S_1uM.vrpn.evt.mat');
% movefile('aggregated_data_S_5uM_Y.vrpn.evt.mat',   'aggregated_data_7.S_5uM.vrpn.evt.mat');


%%% Fall 2014 Pancreatic Construct Experiments

% movefile('aggregated_data_NF.vrpn.evt.mat',         'aggregated_data_01.NF.vrpn.evt.mat');
% movefile('aggregated_data_HPDE.vrpn.evt.mat',       'aggregated_data_02.DE.vrpn.evt.mat');
% movefile('aggregated_data_HPDEcc.vrpn.evt.mat',     'aggregated_data_03.CC.vrpn.evt.mat');
% movefile('aggregated_data_myrPIK3CA.vrpn.evt.mat',  'aggregated_data_04.PI.vrpn.evt.mat');
% movefile('aggregated_data_YAP2SSA.vrpn.evt.mat',    'aggregated_data_05.YP.vrpn.evt.mat');
% movefile('aggregated_data_RhebQ64L.vrpn.evt.mat',   'aggregated_data_06.Rh.vrpn.evt.mat');
% movefile('aggregated_data_GSK3betaDN.vrpn.evt.mat', 'aggregated_data_07.GS.vrpn.evt.mat');
% movefile('aggregated_data_BcateninCA.vrpn.evt.mat', 'aggregated_data_08.BC.vrpn.evt.mat');
% movefile('aggregated_data_HPNE.vrpn.evt.mat',       'aggregated_data_09.NE.vrpn.evt.mat');


%%% Panoptes rebuild channel analysis

% movefile('aggregated_data_ch01.vrpn.evt.mat',         'aggregated_data_01.ch01.vrpn.evt.mat');
% movefile('aggregated_data_ch02.vrpn.evt.mat',         'aggregated_data_02.ch02.vrpn.evt.mat');
% movefile('aggregated_data_ch03.vrpn.evt.mat',         'aggregated_data_03.ch03.vrpn.evt.mat');
% movefile('aggregated_data_ch04.vrpn.evt.mat',         'aggregated_data_04.ch04.vrpn.evt.mat');
% movefile('aggregated_data_ch05.vrpn.evt.mat',         'aggregated_data_05.ch05.vrpn.evt.mat');
% movefile('aggregated_data_ch06.vrpn.evt.mat',         'aggregated_data_06.ch06.vrpn.evt.mat');
% movefile('aggregated_data_ch07.vrpn.evt.mat',         'aggregated_data_07.ch07.vrpn.evt.mat');
% movefile('aggregated_data_ch08.vrpn.evt.mat',         'aggregated_data_08.ch08.vrpn.evt.mat');
% movefile('aggregated_data_ch09.vrpn.evt.mat',         'aggregated_data_09.ch09.vrpn.evt.mat');
% movefile('aggregated_data_ch10.vrpn.evt.mat',         'aggregated_data_10.ch10.vrpn.evt.mat');
% movefile('aggregated_data_ch11.vrpn.evt.mat',         'aggregated_data_11.ch11.vrpn.evt.mat');
% movefile('aggregated_data_ch12.vrpn.evt.mat',         'aggregated_data_12.ch12.vrpn.evt.mat');


%%% Spring 2015 Pancreatic Construct Experiments (jac edit)

% movefile('aggregated_data_noise.vrpn.evt.mat',         'aggregated_data_01.NF.vrpn.evt.mat');
% movefile('aggregated_data_HPDE.vrpn.evt.mat',       'aggregated_data_02.DE.vrpn.evt.mat');
% movefile('aggregated_data_HPDEcc.vrpn.evt.mat',     'aggregated_data_03.CC.vrpn.evt.mat');
% movefile('aggregated_data_myrPIK3CA.vrpn.evt.mat',  'aggregated_data_04.PI.vrpn.evt.mat');
% movefile('aggregated_data_YAP2SSA.vrpn.evt.mat',    'aggregated_data_05.YP.vrpn.evt.mat');
% movefile('aggregated_data_RhebQ64L.vrpn.evt.mat',   'aggregated_data_06.Rh.vrpn.evt.mat');
% movefile('aggregated_data_GSK3betaDN.vrpn.evt.mat', 'aggregated_data_07.GS.vrpn.evt.mat');
% movefile('aggregated_data_BcateninCA.vrpn.evt.mat', 'aggregated_data_08.BC.vrpn.evt.mat');
% movefile('aggregated_data_HPNE.vrpn.evt.mat', 'aggregated_data_03.NE.vrpn.evt.mat');
% movefile('aggregated_data_vec.vrpn.evt.mat', 'aggregated_data_04.VC.vrpn.evt.mat');









re_name_order = 'file_re_name_order is done.';

return;   % function

