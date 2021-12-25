function sig = Barker(fs, T, fc, length)

    barker = comm.BarkerCode('Length', length, 'SamplesPerFrame', length);
    barkercode = barker();
    N = fs * T;
    sig = zeros(1, N * length);

    for i = 1:length
        sig(((i - 1) * N + 1):(i * N)) = barkercode(i) * cos(2 * pi * fc * (1:N) / fs);
    end
    % plot features
    plot_ambiguity(fs,sig);
    figure();
    spectrogram(sig,256,250,256,fs,'yaxis');
    colorbar;
    figure();
    plot(linspace(0, T*length, N*length), sig);
    end
