%% 程序
clear; clc; close all;
tic;

% TESTPATH = 'D:\phase2400\test\';
% addpath(TESTPATH);

%% 1. Basic Parameters

c0 = 1500;
T = 20;                     % rmax = T * c0 / 2 = 9 km
fs = 16000;

freq=1000;

% -------------------------------------------------------------------------
dt = 1/fs;
df = 1/T;                 %% 采样间隔

%% Environmental Parameters

water_depth =50;
zmax = 60;
dz = 1;
zs = 10;                 %%声源深度
rmax = c0*T/2;

rho1 = 1;                %%rho_w=1
attn1 = 0;

% rho2 = 1.9;              %%rho_b=1.9
% attn2 = 0.1;
% cb = 1900;

rho2 = 1.9;              %%rho_b=1.9
attn2 = 0.1;
cb = 1800;

%% SSPS
ssps.svpz = 0 : dz : water_depth;
ssps.svp = 1500 * ones(1,length(ssps.svpz));

set(0,'defaultfigurecolor','w')
figure(1); clf(1);
plot(ssps.svp, ssps.svpz,'linewidth',1.5);
set(gca, 'YDir', 'reverse');
title('Sound Speed profile','FontSize',12,'FontWeight','bold')
xlabel('Sound Speed (m/s)','FontSize',12,'FontWeight','bold');
ylabel('Water Depth (m)','FontSize',12,'FontWeight','bold');
saveas(figure(1),'ssp.jpg');

%% 2. calculate G(r|rs, f)         

    filename = sprintf('pekeris');
    
    system(sprintf('C:\\Users\\rookie\\Dropbox\\code\\matlab\\Radar\\at\\bin\\kraken.exe %s', filename));
     
%     Calculate Propagation Modes
    clear read_modes_bin;
    Modes = read_modes_bin([filename, '.mod'], 0);
    prop_modes = sum(real(Modes.k) > 2*pi*freq./cb);
    
    %%% ----------------Calculate Fields-----------------------------------
   
    
    flpfil = strcat(filename, '.flp');
    Option = 'RA';
    Position.r.range = 0:0.015:rmax/1e3;
    Position.r.depth = 0:0.1:zmax;
    Position.s.depth = zs;
    write_fieldflp( flpfil, Option, Position,4);
    system(sprintf('C:\\Users\\rookie\\Dropbox\\code\\matlab\\Radar\\at\\bin\\field.exe %s', filename));
   
    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure ] = read_shd( [filename, '.shd'] );
    pressure = squeeze(pressure);
    pressure = -real(pressure) + 1i*imag(pressure);
    
    figure(2); clf(2);
    imagesc(Pos.r.r, Pos.r.z, 20*log10(abs(pressure)));
    caxis([-80, -20]);
    title([num2str(freq),'(Hz)-deep-gtr'],'FontSize',12,'FontWeight','bold');
    xlabel('Range (m)','FontSize',12,'FontWeight','bold');
    ylabel('Depth (m)','FontSize',12,'FontWeight','bold');
    colorbar; colormap('jet');

toc;

