function [rmsdisp, rmsdisp_err] = pan_compute_rmsdisp_heatmap(mymsd, mymsd_err)

rmsdisp = sqrt(10.^mymsd);
rmsdisp_err = sqrt(10.^(mymsd+mymsd_err)) - rmsdisp;