function outs = vst_CalcVel(fid, frame, id, xyz, sfactor)    
    if isempty(frame)
        outs = zeros(0,3);
        return
    end
    
    dxyz = CreateGaussScaleSpace(xyz,1,sfactor);
    outs = [fid, frame, id, dxyz];
return