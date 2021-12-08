%%%%理想波导


clear; clc; close all;

TESTPATH = 'C:\Users\rookie\Dropbox\code\matlab\Radar\at\Matlab\group\Test';
addpath(TESTPATH);
%% 1. Basic Parameters

c0 = 1500;
T = 20;                     % rmax = T * c0 / 2 = 9 km
fs = 16000;

fmin = 900;
fmax =1300;
fwin = [fmin, fmax];          %频段选择

% -------------------------------------------------------------------------
dt = 1/fs;
df = 1/T;                 %% 采样间隔

faxis = df : df : fs;
taxis = 0 : dt : T;

fin1 = find(faxis >= fwin(1), 1, 'first');       %频率范围
fin2 = find(faxis <= fwin(2), 1, 'last');

%% Environmental Parameters

water_depth = 50;
rmax = c0*T/2;
zs = 10;                 %%声源深度
dz = 1;

%% 2. calculate G(r|rs, f)  

mmode =20;                                 %%第m个模式

    zt = 40;           %%选择的深度
    R1 = 4500;         %%选择的range
    g20 = zeros(1,length(fmin : df : fmax));
    
    rcvz  = 0:1:water_depth;
    raxis = 0:150:rmax;
    
for ii = fin1 : fin2       %%%%有效部分
    
    disp(ii);
    
    freq = faxis(ii);
  
    k  = 2*pi*freq/1500;
    kr = sqrt(k^2- (mmode*pi/water_depth)^2);
    factor_hankel = kr*raxis;
    kz = mmode*pi/water_depth;
    H = besselh(0,factor_hankel);
    S_w = 100;
    
%     Mmax = 2*freq* water_depth/1500;
 
    pressure_id = -1i*S_w/(2*water_depth)*sin(kz*rcvz.')*sin(kz*zs)*H;
    
    i= ii-fmin/df; 
    
    i_zr = find(rcvz == zt);
    i_R = find(raxis == R1);                
    g20(:,i) = pressure_id(i_zr,i_R);    
    
    clear H; 
    clear  pressure_id;

end


%%%%%%%%%%%%
G = zeros(1,length(faxis));
G(:,900/df:1300/df) = g2400;
gt =fft(G);


%     set(0, 'CurrentFigure', figure(1)); clf(1);
    figure(1);plot(faxis,real(G),'linewidth',1.5);
%     figure(2);plot(taxis1,20*log10(abs(fftshift(gt))),'linewidth',1.5);
    figure(3);plot(taxis,20*log10(abs(gt)),'linewidth',1.5);
    
%     legend('20th-mode','1st-mode');
%     title('gt脉冲响应 ');    %LFM信号时域图
%     xlabel('Time(s)');ylabel('Intensity');
%     hold on;
%     legend('1st-mode','2nd-mode','3rd-mode','5th-mode','10th-mode','20th-mode');
%     xlim([16.92,17.0]);ylim([-130,-85]);
    
%% LFM信号生成

T=20;                                                                      %总时长
t1=5;                                                                       %start time of the chirp signal (secs)
tau=1;                                                                      %chirp信号持续时间
f1=1000;                                                                    %start frequency of the chirp
B=200;                                                                      %带宽
fs = 16000;
dt = 1/fs;
df = 1/T;                 %% 采样间隔

LFM_length = T*fs;
[LFM_sig, LFM_taxis] = dl_genLFM(T, fs, t1, tau, f1,B, 'tukey');    %LFM信号生成

LFM_f = ifft(LFM_sig);
LFM_faxis = linspace(-fs/2,fs/2,length(LFM_f));

G = zeros(1,length(LFM_faxis));
G(:,900/df:1300/df) = g20;
% gt = ifft(G);

%     set(0, 'CurrentFigure', figure(2)); clf(2);figure(2);
%     plot(LFM_faxis,20*log10(abs(fftshift(G))),'linewidth',1.5);
%     set(gca,'fontsize',16,'xlim',[-8000 8000]);
%     title('Green ');    %LFM信号时域图
%     xlabel('Frequency(Hz)');ylabel('Intensity(dB)');
    
Sf = G.*LFM_f;
sig_t =fft(Sf);

[matchsig, match_taxis] = dl_genLFM(1, fs, 0, 1,f1,B, 'tukey');    %LFM信号生成
    Q = sum(abs(matchsig).^2)/2;

    mfout = conv(sig_t, fliplr(conj(matchsig)), 'valid')/Q;
    mfout_taxis = 0:1/fs:(length(mfout)-1)*1/fs;
   
    [Emax,index]= max(20*log10(abs(mfout)));
    index =index*1/fs;
    mfout = 20*log10(abs(mfout));
%     mfout = mfout+590;
   
%     set(0, 'CurrentFigure', figure(3)); clf(3);
    figure(4);title('mfout');
    plot(mfout_taxis,mfout,'linewidth',1.5);
%     
    xlabel('Time(s)');ylabel('Intensity(dB)')
    set(gca,'Fontsize',12);caxis([50, 120]);
    hold on;
    legend('1st-mode','2nd-mode','3rd-mode','5th-mode','10th-mode','20th-mode');
%     xlim([4.9,5.1]);ylim([-150,50]);
    
    saveas(figure(1),'20th_gt.fig');
