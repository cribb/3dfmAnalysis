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
    
    fprintf('\nAverage force:  %5.2f pN\n', (mean(force)*1e12));
    fprintf('RMS     force:  %5.2f pN\n', (rms(force)*1e12));
    fprintf('Maximum force:  %5.2f pN\n', (max(abs(force))*1e12));
    fprintf('Minimum force:  %5.2f pN\n\n', (min(abs(force))*1e12));
    
    v = force;
    
    