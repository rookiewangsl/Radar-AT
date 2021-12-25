clc;
clear;
close all;
fclose all;



%% write env file
% function  mybenv(FILENAME, FREQ, TOPOPT, MEDIA, BOTTOM, ...
%                 NSD, SD, NRD, RD,NR,RMin,RMax,RunType,NBEAMS,ALPHA,SZR)
%  FILENAME:string ('Pekeris')
%  TOPOPT: string
% MEDIA: struct, .sigma, .zmax, .z, .cp, .cs, .rho, .ap, .as
% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
% SD,RD,ALPHA: double arrays
% RunType: string
% SZR: [STEP(m)  ZBOX (m) RBOX (m)]

FILENAME = 'Ideal';
% xs = 100;   % Range(km)
% ys = 500;   % Depth(m)
shdfilename = [FILENAME, '.shd'];

TOPOPT = 'SVN';
MEDIA.nmesh = 0;
MEDIA.sigma = 0.0;
MEDIA.zmax = 5000.0;
MEDIA.z = {0, 5000.0};
MEDIA.cp = {1500, 1500};

% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
BOTTOM.opt = 'V';
BOTTOM.sigma = 0;
% BOTTOM.z = 5000;
% BOTTOM.cp = 2000;
% BOTTOM.cs = 0;
% BOTTOM.rho = 2;

% mesh
NSD = 1;
SD = 500;

NRD = 1000;
global RD
RD = [0 5000];
NR = 500;
global RMin
RMin = 0;
global RMax
RMax = 100;
RunType='C';
NBEAMS=100;
ALPHA=[-11 11];
SZR=[200 5500 101];


%% input signal
T = 1;
N = 1024;
fs = N / T;
t = linspace(0, T, N);

freq = [20];
sig = cos(2 * pi * freq.' * t);
% sig = exp(1i*2 * pi * freq.' * t);
sig = sum(sig, 1);

a = 6;
sig = [zeros(1, N), sig, zeros(1, a * N - 2 * N)];

N = a * N;
T = a * T;
t = linspace(0, T, N);

%% signal spectrum
sigf = fft(sig);

ks = find((abs(sigf) / max(abs(sigf))) > 0.1);
ks=ks(1:length(ks)/2);
fss = (ks - 1) * fs / N;

%% plot shd in 20HZ
mybenv(FILENAME, freq(1), TOPOPT, MEDIA, BOTTOM, ...
                NSD, SD, NRD, RD,NR,RMin,RMax,RunType,NBEAMS,ALPHA,SZR);
bellhop (FILENAME);
xs = 50;   % Range(km)
ys = 500;   % Depth(m)
figure();
plotshd(shdfilename);
figure();
plottld(shdfilename, xs);
figure();
plottlr(shdfilename, ys);

%% single side band
% P2 = abs(sigf / N);
% P1 = P2(1:N / 2 + 1);
% P1( 2 : end - 1) = 2 * P1( 2 : end - 1);

% f = fs * (0:(N / 2)) / N;
% figure()
% plot(f, P1);
% title('Single-Sided Amplitude Spectrum');
% xlabel('f (Hz)');
% % xlim([0, 200]);
% ylabel('|P1(f)|');

%% Frequency Response (Green function)
% pressure(freq,theta,source,NRD,NR)
K = length(fss);
pressure = zeros(1, 1, NRD, NR);
grf = zeros(1, K);

for i = 1:K
    mybenv(FILENAME, fss(i), TOPOPT, MEDIA, BOTTOM, ...
                NSD, SD, NRD, RD,NR,RMin,RMax,RunType,NBEAMS,ALPHA,SZR);
    %     myflp(FILENAME,  Opt, NModes, NProf, ...
    %           RProf, NR, RMin, RMax, NSD, SD, NRD, RD, NRR);
    bellhop (FILENAME);
    [~, ~, ~, ~, ~, pressure] = read_shd(shdfilename);
    grf(i) = getgrf(pressure, xs, ys);
    disp(i);
end
% save('grf.mat', 'grf');
% save('sigf.mat', 'sigf');

%% Output
% close all;
% load('sigf.mat', 'sigf');
% load('grf.mat', 'grf');

% position of grf in double-side spectrum
k = zeros(1, K);
g = zeros(1, N);
for i = 1:K
    k(i) = N * fss(i) / fs + 1;
    g(k(i)) = grf(i);
end

yf = g .* sigf;
yt = ifft(yf, 'symmetric');

%% figures
figure();
specgram(sig);
colorbar;

figure();
plot(t, sig);
figure();
plot(t, yt);
figure();
spectrogram(yt, 256, 250, 256, fs, 'yaxis');
colorbar;
figure()
plotray(FILENAME);