function outs = vst_CalcVel(id, frame, xyz, sfactor)    
    if isempty(frame)
        outs = zeros(0,3);
        return
    end
    
    dxyz = CreateGaussScaleSpace(xyz,1,sfactor);
    outs = [id, frame, dxyz];
return