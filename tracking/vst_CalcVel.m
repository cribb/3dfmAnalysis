function outs = vst_CalcVel(fid, id, frame, xyz, sfactor)    
    if isempty(frame)
        outs = zeros(0,3);
        return
    end
    
    dxyz = CreateGaussScaleSpace(xyz,1,sfactor);
    outs = [fid, id, frame, dxyz];
return