clc;
clear;
close;

%% write env file
% function  myenv(FILENAME,FREQ,TOPOPT,MEDIA,BOTTOM,...
%       PSMIN,PSMAX,RMAX,NSD,SD,NRD,RD)
%  FILENAME:string ('Pekeris')
%  TOPOPT: string
% MEDIA: struct, .sigma, .zmax, .z, .cp, .cs, .rho, .ap, .as
% BOTTOM: struct, .opt, .sigma, .z, .cp, .cs, .rho, .ap, .as
% SD,RD: double arrays

FILENAME = 'Pekeris';
FREQ = 10;
TOPOPT = 'NVF';

MEDIA.nmesh = 500;
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

PSMIN = 1400;
PSMAX = 2000;
RMAX = 250;
NSD = 1;
SD = 500;
NRD = 1;
RD = 2000;

myenv(FILENAME, FREQ, TOPOPT, MEDIA, BOTTOM, ...
      PSMIN, PSMAX, RMAX, NSD, SD, NRD, RD);

%% write flp file
% function  myflp(FILENAME,  Opt, NModes, NProf, ...
%                 RProf, RMin, RMax, NSD, SD, NRD, RD)
%  Opt: string
%
Opt='RA';
NModes=9999;
NProf=1;
RProf=0;
NR=501;
RMin=200;
RMax=220;
NSD=1;
SD=500;
NRD=1;
RD=2500;
NRR=0;

myflp(FILENAME,  Opt, NModes, NProf, ...
                RProf, NR, RMin, RMax, NSD, SD, NRD, RD,NRR);

%% 信号生成
T=1;
N=1024;
fs=N/T;
t=linspace(0,1,N);
sig=cos(2*pi*FREQ*t);
plot(t,sig);

% 信号频谱
SIG=fft(sig);
P2 = abs(SIG/N);
plot(P2)
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:(N/2))/N;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
%% system计算和plot调用
FILENAME='Pekeris';
system('kraken %s',FILENAME);

%% 画图和保存