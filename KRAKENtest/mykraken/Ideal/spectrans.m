function [Pout] = spectrans(Pin, fs, argin)
    % fft实际单边谱和双边谱的转换
    figure();
    assert(argin == 1 | argin == 2);
    % single to double
    if argin == 1
        N = 2 * (length(Pin) - 1);
        Pl = Pin(2:end - 1) / 2;
        Pr = conj(fliplr(Pl));
        Pout = [Pin(1), Pl, Pin(N / 2 + 1), Pr];
        f = (1:N);
    % double to single
    else
        N = length(Pin);
        P2 = abs(Pin / N);
        P1 = P2(1:N / 2 + 1);
        P1(2:end - 1) = 2 * P1(2:end - 1);
        Pout = P1;
        f = fs * (0:(N / 2)) / N;
    end

    plot(f, Pout);
    ylabel('|P(f)|');
    if argin == 1
        title('Double-Sided Amplitude Spectrum');
        xlabel('K');
    else
        title('Single-Sided Amplitude Spectrum');
        xlabel('f (Hz)');
    end

end
