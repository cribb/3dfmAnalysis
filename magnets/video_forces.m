function v = video_forces(file, frame_rate, bead_radius, visc)

    d = load_video_tracking(file, frame_rate, [], [], 'rectangle', 'm', 0.0764);
    
    dt = 1/frame_rate;
    velocity = diff(d.video.r)/dt;
    
    force = 6 * pi * visc * bead_radius * velocity;
    
    figure;
    plot(d.video.time(2:end), force*1e12);
    title(['Forces on bead with radius ' num2str(bead_radius) 'm in Hercules']);
    xlabel('time (sec)');
    ylabel('Force (pN)');
    pretty_plot;

    for k=1:size(force,2)
        fprintf('\nTracked Particle #%d\n', k);
        fprintf('------------------------\n');
        fprintf('Average force:  %5.5f pN\n', (mean(force(:,k))*1e12));
        fprintf('RMS     force:  %5.5f pN\n', (rms(force(:,k))*1e12));
        fprintf('Maximum force:  %5.5f pN\n', (max(abs(force(:,k)))*1e12));
        fprintf('Minimum force:  %5.5f pN\n\n', (min(abs(force(:,k)))*1e12));
    end
    
    v = force;