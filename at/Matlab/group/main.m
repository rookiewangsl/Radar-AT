clear;
clc;
%% signal
freq = 1000;
N = 1024;
t = linspace(0, 1, N); % 1s,1024
sig = exp(1i * freq * t); % CW
spectrogram(sig);
saveas(gcf,'sig.jpg');

