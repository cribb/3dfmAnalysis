function v = calcD(d)
if ~isnumeric(d)
    v.Dx = (diff(d.stage.xs).^2)./(2*diff(d.stage.ts)); 
    v.Dy = (diff(d.stage.ys).^2)./(2*diff(d.stage.ts)); 
    v.Dz = (diff(d.stage.zs).^2)./(2*diff(d.stage.ts)); 
else
    v = (diff(d).^2)./(2*diff(d));
end

