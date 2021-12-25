clc;
clear;
close all;
fclose all;



%% write env file
% function  mykenv(FILENAME,FREQ,TOPOPT,MEDIA,BOTTOM,...
%       PSMIN,PSMAX,RMAX,NSD,SD,NRD,RD)
%  FILENAME:string ('Pekeris')
%  TOPOPT: string
% MEDIA: struct, .sigma, .zmax, .z, .cp, .cs, .rho, .ap, .as
% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
% SD,RD: double arrays

FILENAME = 'Pekeris';
xs = 100;   % Range(km)
ys = 500;   % Depth(m)
shdfilename = [FILENAME, '.shd'];

TOPOPT = 'NVF';
MEDIA.nmesh = 0;
MEDIA.sigma = 0.0;
MEDIA.zmax = 5000.0;
MEDIA.z = {0, 5000.0};
MEDIA.cp = {1500, 1500};

% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
BOTTOM.opt = 'A';
BOTTOM.sigma = 0;
BOTTOM.z = 5000;
BOTTOM.cp = 2000;
BOTTOM.cs = 0;
BOTTOM.rho = 2;

PSMIN = 1500;
PSMAX = 2000;
% RMAX = 200;
NSD = 1;
SD = 500;

% mesh
NR = 501;
global RMin
RMin = 0;
global RMax
RMax = 200;
NRD = 1001;
global RD
RD = [0 5000];
% mykenv(FILENAME, FREQ(1), TOPOPT, MEDIA, BOTTOM, ...
%       PSMIN, PSMAX, RMAX, NSD, SD, NRD, RD);

%% write flp file
% function  myflp(FILENAME,  Opt, NModes, NProf, RProf, RMin, RMax, NSD, SD, NRD, RD)
%  Opt: string
Opt = 'RA';
NModes = 20;
NProf = 1;
RProf = 0;
RR=0;

myflp(FILENAME,  Opt, NModes, NProf, ...
      RProf, NR, RMin, RMax, NSD, SD, NRD, RD, RR);

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
mykenv(FILENAME, freq, TOPOPT, MEDIA, BOTTOM, ...
          PSMIN, PSMAX, RMax, NSD, SD, NRD, RD);
kraken (FILENAME);
xs = 100;   % Range(km)
ys = 500;   % Depth(m)
plotmode(FILENAME, freq(1), [1 2 3 4]);
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
    mykenv(FILENAME, fss(i), TOPOPT, MEDIA, BOTTOM, ...
          PSMIN, PSMAX, RMax, NSD, SD, NRD, RD);
    kraken (FILENAME);
    [~, ~, ~, ~, ~, pressure] = read_shd(shdfilename);
    grf(i) = getgrf(pressure, xs, ys);
    disp(i);
end
save('grf.mat', 'grf');
save('sigf.mat', 'sigf');

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