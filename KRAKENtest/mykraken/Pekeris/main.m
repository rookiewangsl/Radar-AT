clc;
clear;
close all;
fclose all;

%% write env file
% function  myenv(FILENAME,FREQ,TOPOPT,MEDIA,BOTTOM,...
%       PSMIN,PSMAX,RMAX,NSD,SD,NRD,RD)
%  FILENAME:string ('Pekeris')
%  TOPOPT: string
% MEDIA: struct, .sigma, .zmax, .z, .cp, .cs, .rho, .ap, .as
% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
% SD,RD: double arrays

FILENAME = 'Pekeris';
% K = 1;
% % FREQ = logspace(1, 2, K);
% FREQ = 20;
% % FREQ = linspace(10, 30, K);
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
NR = 401;
global RMin
RMin = 0;
global RMax
RMax = 200;
NRD = 1000;
global RD
RD = [0 5000];
% myenv(FILENAME, FREQ(1), TOPOPT, MEDIA, BOTTOM, ...
%       PSMIN, PSMAX, RMAX, NSD, SD, NRD, RD);

%% write flp file
% function  myflp(FILENAME,  Opt, NModes, NProf, RProf, RMin, RMax, NSD, SD, NRD, RD)
%  Opt: string
Opt = 'RA';
NModes = 20;
NProf = 1;
RProf = 0;
NRR = 0;

myflp(FILENAME,  Opt, NModes, NProf, ...
      RProf, NR, RMin, RMax, NSD, SD, NRD, RD, NRR);

%% input signal
T = 1;
N = 1024;
fs = N / T;
t = linspace(0, T, N);

freq = [20];
sig = cos(2 * pi * freq.' * t);
% sig = exp(1i*2 * pi * freq.' * t);
sig = sum(sig, 1);

a = 8;
sig = [zeros(1, N), sig, zeros(1, a * N - 2 * N)];

N = a * N;
T = a * T;
t = linspace(0, T, N);

%% signal spectrum
sigf = fft(sig);

ks = find((abs(sigf) / max(abs(sigf))) > 0.2);
ks=ks(1:length(ks)/2);
fss = (ks - 1) * fs / N;

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

%% system计算和plot调用
% %
% % % include kraken.exe and field.exe
% kraken(FILENAME);
% % % field(FILENAME,modes) calculate the specified modes; produce a mat file
% % %     S=load([shdfilename,'.mat']);
% % %     grf(i)=getgrf(S.pressure,xs,ys);
% % %       field(FILENAME,4);
% figure();
% plotssp(FILENAME);
% plotmode(FILENAME, FREQ(1), [1 2 3 4]);
% % plotgrn(FILENAME)
%
% figure();
% plotshd(shdfilename);
% figure();
% plottld(shdfilename, xs);
% figure();
% plottlr(shdfilename, ys);

%% frequency response
% pressure(freq,theta,source,NRD,NR)
xs = 100;   % Range(km)
ys = 500;   % Depth(m)
shdfilename = [FILENAME, '.shd'];

K = length(fss);
pressure = zeros(1, 1, NRD, NR);
grf = zeros(1, K);

for i = 1:K
    myenv(FILENAME, fss(i), TOPOPT, MEDIA, BOTTOM, ...
          PSMIN, PSMAX, RMax, NSD, SD, NRD, RD);
    %     myflp(FILENAME,  Opt, NModes, NProf, ...
    %           RProf, NR, RMin, RMax, NSD, SD, NRD, RD, NRR);
    kraken (FILENAME);
    [~, ~, ~, ~, ~, pressure] = read_shd(shdfilename);
    grf(i) = getgrf(pressure, xs, ys);
    disp(i);
end
% save('grf.mat', 'grf');
% save('sigf.mat', 'sigf');

%% output
close all;
% load('sigf.mat', 'sigf');
% load('grf.mat', 'grf');

% position of grf in double-side spectrum
k = zeros(1, K);
g = zeros(1, N);
for i = 1:K
    k(i) = N * fss(i) / fs + 1;
    g(k(i)) = grf(i);
end
figure();
specgram(sig);
colorbar;
figure();
plot(abs(g));
figure();
plot(abs(sigf));

yf = g .* sigf;
figure();
plot(abs(yf));
yt = ifft(yf, 'symmetric');

figure();
plot(t, sig);
figure();
plot(t, yt);
