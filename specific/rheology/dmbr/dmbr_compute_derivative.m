function rheo_table = dmbr_compute_derivative(rheo_table, scale)

    dmbr_constants;
    
    dt = mean(diff(rheo_table(:, TIME)));
    
    rheo_table(:,  SX) = CreateGaussScaleSpace(rheo_table(:,   X), 0, scale);
    rheo_table(:,  SY) = CreateGaussScaleSpace(rheo_table(:,   Y), 0, scale);
    rheo_table(:,  SJ) = CreateGaussScaleSpace(rheo_table(:,   J), 0, scale);
    rheo_table(:,  DX) = CreateGaussScaleSpace(rheo_table(:,   X), 1, 0.5)/dt;
    rheo_table(:,  DY) = CreateGaussScaleSpace(rheo_table(:,   Y), 1, 0.5)/dt;
    rheo_table(:,  DJ) = CreateGaussScaleSpace(rheo_table(:,   J), 1, 0.5)/dt;
    rheo_table(:, SDX) = CreateGaussScaleSpace(rheo_table(:,   X), 1, scale)/dt;
    rheo_table(:, SDY) = CreateGaussScaleSpace(rheo_table(:,   Y), 1, scale)/dt;
    rheo_table(:, SDJ) = CreateGaussScaleSpace(rheo_table(:,   J), 1, scale)/dt;

end

